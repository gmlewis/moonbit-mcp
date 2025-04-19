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
		return "CustomResult"
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

func (d *Definition) moonBitType(out *outBufsT, propName string, prop *Definition) string {
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
		arrayType := strings.TrimSuffix(prop.moonBitType(out, propName, prop.Items), "?")
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
		subType := prop.convert(out, subTypeName)
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
	default:
		log.Fatalf("unhandled mooonBitType: %v", string(v))
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
