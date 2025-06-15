package main

import (
	"encoding/json"
	"fmt"
	"log"
	"strings"
)

func (d *Definition) convertEnumAnyOf(out *outBufsT, name, prefix string) string {
	if len(d.AnyOf) == 0 || len(d.Enum) > 0 {
		log.Fatalf("PROGRAMMING ERROR: convertEnumAnyOf: d.AnyOf=nil, d.Enum=%+v", d.Enum)
	}

	lines := []string{
		prefix + "///|",
		fmt.Sprintf(prefix+"pub trait %v: Show + ToJson {", name),
		prefix + "  unused(Self) -> Unit // compiler workaround",
		prefix + "}",
		"",
		prefix + "///|",
		fmt.Sprintf(prefix+"pub impl Eq for &%v with op_equal(_self, _other) {", name),
		prefix + "  false // unused - compiler workaround",
		prefix + "}",
	}

	var fromJSONOptions []string
	fromJSONLines := []string{
		prefix + "///|",
		fmt.Sprintf(prefix+"pub impl @json.FromJson for &%v with from_json(json, path) {", name),
	}

	for _, def := range d.AnyOf {
		refType, _ := def.refType(name, nil)
		refType = strings.TrimSuffix(refType, "?")
		implLines := []string{
			prefix + "///|",
			fmt.Sprintf(prefix+"pub impl %v for %v with unused(_self) {", name, refType),
			prefix,
			prefix + "}",
		}
		out.typesJSONEnumsFile.WriteString("\n" + strings.Join(implLines, "\n") + "\n")
		fromJSONOptions = append(fromJSONOptions, refType)
		fromJSONLines = append(fromJSONLines,
			fmt.Sprintf(prefix+"  let v : Result[%v, _] = try? @json.from_json(json)", refType),
			prefix+"  if v is Ok(v) {",
			prefix+"    return v",
			prefix+"  }",
		)
	}

	fromJSONLines = append(fromJSONLines,
		prefix+"  raise @json.JsonDecodeError(",
		fmt.Sprintf(prefix+`    (path, "expected one of: %v; got: \{@json.stringify(json)}"),`, strings.Join(fromJSONOptions, ", ")),
		prefix+"  )")
	fromJSONLines = append(fromJSONLines, prefix+"}")
	out.typesJSONEnumsFile.WriteString("\n" + strings.Join(fromJSONLines, "\n") + "\n")

	return strings.Join(lines, "\n")
}

func (d *Definition) convertEnumStrings(out *outBufsT, name, prefix string) string {
	if len(d.Enum) == 0 || len(d.AnyOf) > 0 {
		log.Fatalf("PROGRAMMING ERROR: convertEnumStrings: d.Enum=nil, d.AnyOf=%+v", d.AnyOf)
	}

	lines := []string{
		prefix + "///|",
		fmt.Sprintf(prefix+"pub(all) enum %v {", name),
	}

	toJSONLines := []string{
		prefix + "///|",
		fmt.Sprintf(prefix+"pub impl ToJson for %v with to_json(self) {", name),
		prefix + "  match self {",
	}

	var fromJSONOptions []string
	fromJSONLines := []string{
		prefix + "///|",
		fmt.Sprintf(prefix+"pub impl @json.FromJson for %v with from_json(json, path) {", name),
	}

	fromJSONOptions = make([]string, 0, len(d.Enum))
	fromJSONLines = append(fromJSONLines,
		prefix+"  guard json is String(s) else {",
		prefix+`    raise @json.JsonDecodeError((path, "expected string"))`,
		prefix+"  }",
		prefix+"  match s {",
	)

	for _, rawEnum := range d.Enum {
		enumBuf, err := json.Marshal(rawEnum)
		must(err)
		noQuotesValue := strings.ReplaceAll(string(enumBuf), `"`, "")
		enumName := titleCase(noQuotesValue)
		// special case: change "None" to "NoServers" for `IncludeContext`:
		if enumName == "None" {
			enumName = "NoServers"
		}
		lines = append(lines, fmt.Sprintf(prefix+"  %v // = %v", enumName, string(enumBuf)))
		toJSONLines = append(toJSONLines, fmt.Sprintf(prefix+"    %v => %s.to_json(),", enumName, string(enumBuf)))
		fromJSONOptions = append(fromJSONOptions, noQuotesValue)
		fromJSONLines = append(fromJSONLines, fmt.Sprintf(prefix+"    %q => %v", noQuotesValue, enumName))
	}

	lines = append(lines, prefix+"} derive(Show, Eq)")

	toJSONLines = append(toJSONLines, prefix+"  }")
	toJSONLines = append(toJSONLines, prefix+"}")
	out.typesJSONEnumsFile.WriteString("\n" + strings.Join(toJSONLines, "\n") + "\n")

	fromJSONLines = append(fromJSONLines,
		prefix+"  _ =>",
		prefix+"  raise @json.JsonDecodeError(",
		fmt.Sprintf(prefix+`    (path, "expected one of: '%v'; got '\{s}'"),`, strings.Join(fromJSONOptions, "', '")),
		prefix+"  )",
		prefix+"}")
	fromJSONLines = append(fromJSONLines, prefix+"}")
	out.typesJSONEnumsFile.WriteString("\n" + strings.Join(fromJSONLines, "\n") + "\n")

	return strings.Join(lines, "\n")
}
