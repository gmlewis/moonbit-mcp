package main

import (
	"encoding/json"
	"fmt"
	"log"
	"slices"
	"strings"
)

var reservedKeywords = map[string]string{
	"method": "method_",
	"ref":    "ref_",
	"type":   "type_",
}

func safeStructName(s string) string {
	switch s {
	case "Result":
		return "Result_"
	case "RequestId":
		// Here we are renaming a RequestId to the @jsonrpc.ID type.
		return "@jsonrpc2.ID"
	default:
		return s
	}
}

func safePropName(s string) string {
	if v, ok := reservedKeywords[s]; ok {
		return v
	}
	return s
}

func (s *Schema) moonBitType(d *Definition, out *outBufsT, propName string, prop *Definition) string {
	var suffix string
	if slices.Contains(d.Required, propName) {
		d.isRequired = true
	} else {
		suffix = "?"
	}

	typ := prop.Type
	v, err := json.Marshal(typ)
	must(err)
	switch string(v) {
	case `"boolean"`:
		return "Bool" + suffix
	case `"number"`:
		return "Double" + suffix
	case `"integer"`:
		return "Int64" + suffix
	case `"array"`:
		if len(prop.Items.AnyOf) > 0 {
			arrayType, anyOf := prop.Items.refType(propName, nil)
			if len(anyOf) > 0 {
				enumName := d.name + titleCase(propName)
				enumBody := prop.Items.convertEnumAnyOf(out, enumName, "")
				d.helperStructsAndMethods = append(d.helperStructsAndMethods, enumBody)
				return fmt.Sprintf("Array[&%v]", enumName)
			}
			return fmt.Sprintf("Array[%v]", arrayType)
		}
		arrayType := strings.TrimSuffix(s.moonBitType(prop, out, propName, prop.Items), "?")
		return fmt.Sprintf("Array[%v]", arrayType) + suffix
	case `"string"`:
		if len(prop.Enum) > 0 {
			enumName := titleCase(propName)
			enumBody := prop.convertEnumStrings(out, enumName, "")
			d.helperStructsAndMethods = append(d.helperStructsAndMethods, enumBody)
			return enumName + suffix
		}
		return "String" + suffix
	case `"object"`:
		if len(prop.Properties) == 0 {
			return "Json" + suffix
		}
		subTypeName := d.name + titleCase(propName)
		subType := s.convert(prop, out, subTypeName)
		d.helperStructsAndMethods = append(d.helperStructsAndMethods, subType)
		d.helperStructsAndMethods = append(d.helperStructsAndMethods, prop.helperStructsAndMethods...)
		return subTypeName + suffix
	case "null":
		refType, anyOf := prop.refType(propName, d.Required)
		if len(anyOf) > 0 {
			enumName := d.name + titleCase(propName)
			enumBody := prop.convertEnumAnyOf(out, enumName, "")
			d.helperStructsAndMethods = append(d.helperStructsAndMethods, enumBody)
			return "&" + enumName
		}
		return refType
	case `["string","integer"]`:
		d.helperStructsAndMethods = append(d.helperStructsAndMethods, fmt.Sprintf(`
///|
pub fn %v::string(s : String) -> %[1]v {
  String(s)
}

///|
pub fn %[1]v::number(n : Int) -> %[1]v {
  Number(n)
}
`, propName))
		return fmt.Sprintf(`pub enum %v {
  String(String)
  Number(Int)
} derive(Show, Eq, FromJson, ToJson)
`, propName)
	default:
		log.Fatalf("prop %q unhandled mooonBitType: %v", propName, string(v))
	}
	return ""
}

func (d *Definition) refType(propName string, required []string) (refType string, anyOf []string) {
	if d != nil && len(d.AnyOf) > 0 {
		for _, def := range d.AnyOf {
			typ, _ := def.refType(propName, nil)
			anyOf = append(anyOf, typ)
		}
	} else if d == nil || d.Ref == "" {
		// special exception: "data" => Json
		if propName == "data" {
			return "Json", nil
		}
		log.Fatalf("nil definition or missing refType for propName %q", propName)
	}
	parts := strings.Split(d.Ref, "/")
	typeName := safeStructName(parts[len(parts)-1])
	if slices.Contains(required, propName) {
		d.isRequired = true
		return typeName, anyOf
	}
	// optional - not required
	return typeName + "?", anyOf
}

func titleCase(s string) string {
	if s == "" {
		return s
	}
	return strings.ToUpper(s[0:1]) + s[1:]
}

func (d *Definition) cleanDescription(prefix string) string {
	desc := strings.Replace(d.Description, "\n", "\n"+prefix+"/// ", -1)
	// clean up trailing whitespace within description:
	return strings.Replace(desc, " \n", "\n", -1)
}

func (s *Schema) convertType(d *Definition, out *outBufsT, propName, prefix string) string {
	// strip the trailing ? since this is a top-level type and doesn't have
	// "properties" or "required" fields.
	typ := s.moonBitType(d, out, propName, d)
	lines := []string{prefix + "///|"}
	if d.Description != "" {
		desc := d.cleanDescription(prefix)
		lines = append(lines, fmt.Sprintf(prefix+"/// %v", desc))
	}

	if strings.HasSuffix(typ, "?") {
		typ = strings.TrimSuffix(typ, "?")
		lines = append(lines, fmt.Sprintf(prefix+"pub type %v %v derive(Show, Eq, FromJson, ToJson)", propName, typ))
		if typ != "String" {
			underlyingType, ok := s.Definitions[strings.TrimSuffix(typ, "_")]
			if !ok {
				log.Fatalf("%v: unhandled underlying type %v", propName, typ)
			}
			newLines := []string{
				prefix + "///|",
				fmt.Sprintf(prefix+"pub fn %v::new(", propName),
			}

			tsSource, ok := s.tsDefs.Get(propName)
			if !ok {
				log.Fatalf("unable to find tsSource for propName %q", propName)
			}
			props := underlyingType.sortedProps(tsSource)
			for _, name := range props {
				prop := underlyingType.Properties[name]
				log.Printf("GML: underlyingType.Properties: %q: %#v", name, prop)
			}

			newLines = append(newLines, fmt.Sprintf(prefix+") -> %v {", propName))

			for _, name := range props {
				prop := underlyingType.Properties[name]
				log.Printf("GML: underlyingType.Properties: %q: %#v", name, prop)
			}

			newLines = append(newLines,
				fmt.Sprintf(prefix+"  %v::new(", typ),
				prefix+"  )",
				prefix+"}",
			)
			out.typesNewFile.WriteString("\n" + strings.Join(newLines, "\n") + "\n")
			d.genHelperMethods(nil)
		}
	} else {
		// handle enum
		lines = append(lines, typ)
	}

	return strings.Join(lines, "\n")
}
