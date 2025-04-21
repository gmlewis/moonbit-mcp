package main

import (
	"encoding/json"
	"fmt"
	"log"
	"sort"
	"strings"
)

type skipType int

const (
	skipButComment = iota
	totallyIgnore
)

type patchFunc func(*Definition)

var patches = map[string]patchFunc{
	"EmptyResult": func(d *Definition) {
		d.Description = "A response that indicates success but carries no data."
	},
	"ClientResult": func(d *Definition) {
		d.AnyOf[0] = &Definition{Ref: "#/definitions/EmptyResult"}
	},
	"ServerResult": func(d *Definition) {
		d.AnyOf[0] = &Definition{Ref: "#/definitions/EmptyResult"}
	},
}

var structsToSkip = map[string]skipType{
	"JSONRPCBatchRequest":  totallyIgnore,
	"JSONRPCBatchResponse": totallyIgnore,
	"JSONRPCError":         totallyIgnore,
	"JSONRPCMessage":       totallyIgnore,
	"JSONRPCNotification":  totallyIgnore,
	"JSONRPCRequest":       totallyIgnore,
	"JSONRPCResponse":      totallyIgnore,
	"@jsonrpc2.ID":         totallyIgnore, // `ResultId` converted to `@jsonrpc2.ID`
}

func (s *Schema) convert(d *Definition, out *outBufsT, name string) string {
	tsSource, ok := s.tsDefs.Get(name)
	if !ok {
		log.Printf("unable to find tsSource for name %q", name)
	}

	name = safeStructName(name)
	d.name = name
	var prefix string
	if v, ok := structsToSkip[name]; ok {
		if v == totallyIgnore {
			return ""
		}
		prefix = "// "
	}
	if f, ok := patches[name]; ok {
		f(d)
	}

	if len(d.Properties) == 0 && len(d.AnyOf) > 0 {
		return d.convertEnumAnyOf(out, name, prefix)
	}
	if len(d.Enum) > 0 {
		return d.convertEnumStrings(out, name, prefix)
	}
	if len(d.Properties) == 0 {
		return s.convertType(d, out, name, prefix)
	}

	if d.AdditionalProperties != nil || d.AdditionalPropertiesBool != nil || d.AdditionalPropertiesSchema != nil {
		log.Fatalf("%v has additionalProperies!", name)
	}

	lines := []string{prefix + "///|"}
	if d.Description != "" {
		desc := d.cleanDescription(prefix)
		lines = append(lines, fmt.Sprintf(prefix+"/// %v: %v", name, desc))
	}
	lines = append(lines, fmt.Sprintf(prefix+"pub(all) struct %v {", name))

	newLines := []string{
		prefix + "///|",
		fmt.Sprintf(prefix+"pub fn %v::new(", name),
	}

	selfVar := "self"
	if len(d.Properties) == 0 {
		selfVar = "_self"
	}
	toJSONLines := []string{
		prefix + "///|",
		fmt.Sprintf(prefix+"pub impl ToJson for %v with to_json(%v) {", name, selfVar),
		prefix + "  let obj = {}",
	}

	var fromJSONLastLineFields []string
	objVar := "obj"
	if len(d.Properties) == 0 {
		objVar = "_obj"
	}
	fromJSONLines := []string{
		prefix + "///|",
		fmt.Sprintf(prefix+"pub impl @json.FromJson for %v with from_json(json, path) {", name),
		fmt.Sprintf(prefix+"  guard json is Object(%v) else {", objVar),
		prefix + `    raise @json.JsonDecodeError((path, "expected object"))`,
		prefix + "  }",
	}

	props := d.sortedProps(tsSource)

	jsonRPCConsts := map[string]string{}
	for _, propName := range props {
		prop := d.Properties[propName]
		if prop.Description != "" {
			desc := prop.cleanDescription(prefix + "  ")
			comment := fmt.Sprintf(prefix+"  /// %v", desc)
			lines = append(lines, comment)
			newLines = append(newLines, comment)
		}

		if prop.AdditionalProperties != nil || prop.AdditionalPropertiesBool != nil || prop.AdditionalPropertiesSchema != nil {
			valueType := "Json"
			if m, ok := prop.AdditionalProperties.(map[string]any); ok && m["type"] == "string" {
				valueType = "String"
			}
			lines = append(lines, fmt.Sprintf(prefix+"  %v : Map[String, %v]?", propName, valueType))
			newLines = append(newLines, fmt.Sprintf(prefix+"  %v? : Map[String, %v],", propName, valueType))

			toJSONLines = append(toJSONLines,
				fmt.Sprintf(prefix+"  if self.%v is Some(v) {", propName),
				fmt.Sprintf(prefix+"    obj[%q] = v.to_json()", propName),
				prefix+"  }",
			)
			fromJSONLastLineFields = append(fromJSONLastLineFields, propName)
			fromJSONLines = append(fromJSONLines,
				fmt.Sprintf(prefix+`  let %v : Map[String, %v]? = match obj[%[1]q] {`, propName, valueType),
				prefix+"    Some(v) =>",
				prefix+"      match @json.from_json?(v) {",
				prefix+"        Ok(v) => Some(v)",
				prefix+"        Err(e) => raise e",
				prefix+"      }",
				prefix+"    None => None",
				prefix+"  }",
			)
			continue
		}

		if len(prop.Const) > 0 {
			value, err := json.Marshal(prop.Const)
			must(err)
			jsonRPCConsts[propName] = string(value)
			if propName != "method" {
				toJSONLines = append(toJSONLines, fmt.Sprintf(prefix+"  obj[%q] = %s.to_json()", propName, value))
				fromJSONLines = append(fromJSONLines,
					fmt.Sprintf(prefix+"  guard obj[%q] == Some(String(%s)) else {", propName, value),
					fmt.Sprintf(prefix+`    raise @json.JsonDecodeError((path, "expected '%v'='%v'"))`, propName, strings.ReplaceAll(string(value), `"`, "")),
					prefix+"  }")
			}
			lines = append(lines, fmt.Sprintf(prefix+`  /// JSON-RPC: %q = %s`, propName, value))
			continue
		}

		safeName := safePropName(propName)
		mbtType := s.moonBitType(d, out, propName, prop)
		lines = append(lines, fmt.Sprintf(prefix+"  %v : %v", safeName, mbtType))
		fromJSONLastLineFields = append(fromJSONLastLineFields, safeName)

		if strings.HasSuffix(mbtType, "?") {
			var injectToDouble string
			if mbtType == "Int64?" {
				injectToDouble = ".to_double()"
			}
			toJSONLines = append(toJSONLines,
				fmt.Sprintf(prefix+"  if self.%v is Some(v) {", propName),
				fmt.Sprintf(prefix+"    obj[%q] = v%v.to_json()", propName, injectToDouble),
				"  }")
			fromJSONLines = append(fromJSONLines,
				fmt.Sprintf(prefix+"  let %v : %v = match obj[%[1]q] {", propName, mbtType),
				prefix+"    Some(v) =>",
				prefix+"      match @json.from_json?(v) {")
			if mbtType == "Int64?" {
				fromJSONLines = append(fromJSONLines,
					prefix+`Ok(Number(v)) => Some(v.to_int64())`,
					prefix+`_ => raise @json.JsonDecodeError((path, "expected number; got \{v}"))`)
			} else {
				fromJSONLines = append(fromJSONLines,
					prefix+"        Ok(v) => Some(v)",
					prefix+"        Err(e) => raise e")
			}
			fromJSONLines = append(fromJSONLines,
				prefix+"      }",
				prefix+"    None => None",
				prefix+"  }")
			newLines = append(newLines, fmt.Sprintf(prefix+"  %v? : %v,", safeName, strings.TrimSuffix(mbtType, "?")))
		} else {
			toJSONLines = append(toJSONLines, fmt.Sprintf(prefix+"  obj[%q] = self.%v.to_json()", propName, safeName))
			fromJSONLines = append(fromJSONLines,
				fmt.Sprintf(prefix+"  guard obj[%q] is Some(json) else {", propName),
				fmt.Sprintf(prefix+`    raise @json.JsonDecodeError((path, "expected field '%v'"))`, propName),
				prefix+"  }",
				fmt.Sprintf(prefix+"  let v : Result[%v, _] = @json.from_json?(json)", mbtType),
				fmt.Sprintf(prefix+"  guard v is Ok(%v) else {", safeName),
				fmt.Sprintf(prefix+`    raise @json.JsonDecodeError((path, "expected field '%v'"))`, propName),
				prefix+"  }",
			)
			newLines = append(newLines, fmt.Sprintf(prefix+"  %v : %v,", safeName, mbtType))
		}
	}

	toJSONLines = append(toJSONLines, prefix+"  obj.to_json()", "}")
	fromJSONLines = append(fromJSONLines,
		prefix+"  { "+strings.Join(fromJSONLastLineFields, ", ")+" }",
		prefix+"}")
	lines = append(lines,
		prefix+"} derive(Show, Eq)")
	out.typesJSONFile.WriteString("\n" + strings.Join(toJSONLines, "\n") + "\n")
	out.typesJSONFile.WriteString("\n" + strings.Join(fromJSONLines, "\n") + "\n")

	newLines = append(newLines,
		fmt.Sprintf(prefix+") -> %v {", name),
		prefix+"  { "+strings.Join(fromJSONLastLineFields, ", ")+" }",
		prefix+"}")
	out.typesNewFile.WriteString("\n" + strings.Join(newLines, "\n") + "\n")

	// generate any helper methods
	d.genHelperMethods(jsonRPCConsts)

	return strings.Join(lines, "\n")
}

func (d *Definition) sortedProps(tsSource string) []string {
	if tsSource != "" {
		log.Printf("sortedProps:\n%v", tsSource)
	}
	props := make([]string, 0, len(d.Properties))
	for key := range d.Properties {
		props = append(props, key)
	}
	sort.Strings(props)
	return props
}
