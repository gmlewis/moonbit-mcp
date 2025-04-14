// -*- compile-command: "go run main.go"; -*-

// schema-to-types reads the official MCP schema.json file and generates
// corresponding MoonBit types.
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"slices"
	"sort"
	"strings"
)

var (
	schemaURL = flag.String("schema", "https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-03-26/schema.json", "Browser GitHub URL to latest MCP schema")
)

const (
	githubPrefix = "https://github.com/"
	rawPrefix    = "https://raw.githubusercontent.com/"
)

func main() {
	log.SetFlags(0)
	flag.Parse()

	url := *schemaURL
	if url == "" {
		log.Fatal("Must supply -schema")
	}
	if strings.HasPrefix(url, githubPrefix) {
		url = rawPrefix + strings.Replace(url[len(githubPrefix):], "/blob/", "/refs/heads/", 1)
	}

	resp, err := http.Get(url)
	must(err)
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	must(err)

	var schema *Schema
	must(json.Unmarshal(body, &schema))

	// Generate types from the schema
	keys := make([]string, 0, len(schema.Definitions))
	for key := range schema.Definitions {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	for _, key := range keys {
		def := schema.Definitions[key]
		mbt := def.convert(key)
		if mbt == "" {
			continue
		}
		fmt.Printf("\n%v\n", mbt)
		for _, helper := range def.helperStructsAndMethods {
			fmt.Printf("\n%v\n", helper)
		}
	}

	log.Printf("Done.")
}

type skipType int

const (
	skipButComment = iota
	totallyIgnore
)

var structsToSkip = map[string]skipType{
	// "CallToolRequest": skipButComment,
	// "CallToolResult":       skipButComment,
	// "ClientNotification":   skipButComment,
	// "ClientRequest":        skipButComment,
	// "ClientResult":         skipButComment,
	// "CompleteRequest":      skipButComment,
	// "CompleteResult":       skipButComment,
	"EmptyResult":          totallyIgnore,
	"JSONRPCBatchRequest":  totallyIgnore,
	"JSONRPCBatchResponse": totallyIgnore,
	"JSONRPCError":         totallyIgnore,
	"JSONRPCMessage":       totallyIgnore,
	"JSONRPCNotification":  totallyIgnore,
	"JSONRPCRequest":       totallyIgnore,
	"JSONRPCResponse":      totallyIgnore,
}

func (d *Definition) convert(name string) string {
	name = safeStructName(name)
	d.name = name
	var prefix string
	if v, ok := structsToSkip[name]; ok {
		if v == totallyIgnore {
			return ""
		}
		prefix = "// "
	}

	if len(d.Properties) == 0 && len(d.AnyOf) > 0 || len(d.Enum) > 0 {
		return d.convertEnum(name, prefix)
	}

	lines := []string{}
	if d.Description != "" {
		lines = append(lines, fmt.Sprintf(prefix+"///| %v: %v", name, strings.Replace(d.Description, "\n", "\n"+prefix+"/// ", -1)))
	} else {
		lines = append(lines, "///|")
	}
	lines = append(lines, fmt.Sprintf(prefix+"pub(all) struct %v {", name))

	props := make([]string, 0, len(d.Properties))
	for key := range d.Properties {
		props = append(props, key)
	}
	sort.Strings(props)
	jsonRPCConsts := map[string]string{}
	for _, propName := range props {
		prop := d.Properties[propName]
		if prop.Description != "" {
			lines = append(lines, fmt.Sprintf(prefix+"  /// %v", strings.Replace(prop.Description, "\n", "\n"+prefix+"  /// ", -1)))
		}
		if len(prop.Const) > 0 {
			value, err := json.Marshal(prop.Const)
			must(err)
			jsonRPCConsts[propName] = string(value)
			lines = append(lines, fmt.Sprintf(prefix+`  /// JSON-RPC: %q = %s`, propName, value))
			continue
		}
		lines = append(lines, fmt.Sprintf(prefix+"  %v : %v", safePropName(propName), d.moonBitType(propName, prop)))
	}

	lines = append(lines, prefix+"} derive(Show, Eq, FromJson, ToJson)")

	// generate any helper methods
	d.genHelperMethods(jsonRPCConsts)

	return strings.Join(lines, "\n")
}

func (d *Definition) convertEnum(name, prefix string) string {
	lines := []string{
		prefix + "///|",
		fmt.Sprintf(prefix+"pub enum %v {", name),
	}

	// two different kinds of enums: anyOf:
	for _, def := range d.AnyOf {
		refType, _ := def.refType(name, nil)
		refType = strings.TrimSuffix(refType, "?")
		lines = append(lines, fmt.Sprintf(prefix+"  %v(%[1]v)", refType))
	}
	// or explicit enum:
	for _, rawEnum := range d.Enum {
		enumBuf, err := json.Marshal(rawEnum)
		must(err)
		noQuotesValue := strings.ReplaceAll(string(enumBuf), `"`, "")
		// lines = append(lines, fmt.Sprintf(prefix+"  %v_%v // = %v", name, titleCase(noQuotesValue), string(enumBuf)))
		enumName := titleCase(noQuotesValue)
		// special case: change "None" to "NoServers" for `IncludeContext`:
		if enumName == "None" {
			enumName = "NoServers"
		}
		lines = append(lines, fmt.Sprintf(prefix+"  %v // = %v", enumName, string(enumBuf)))
	}

	lines = append(lines, prefix+"} derive(Show, Eq)")
	return strings.Join(lines, "\n")
}

var reservedKeywords = map[string]string{
	"method": "method_",
	"ref":    "ref_",
	"type":   "type_",
}

func safeStructName(s string) string {
	switch s {
	case "Result":
		return "CustomResult"
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

func (d *Definition) moonBitType(propName string, prop *Definition) string {
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
				enumBody := prop.Items.convertEnum(enumName, "")
				d.helperStructsAndMethods = append(d.helperStructsAndMethods, enumBody)
				// return fmt.Sprintf("Array[%v]", enumName) + suffix + " // " + strings.Join(anyOf, " | ")
				return fmt.Sprintf("Array[%v]", enumName) + " // " + strings.Join(anyOf, " | ")
			}
			// return fmt.Sprintf("Array[%v]", arrayType) + suffix + " // " + strings.Join(anyOf, " | ")
			return fmt.Sprintf("Array[%v]", arrayType) + " // " + strings.Join(anyOf, " | ")
		}
		// arrayType := prop.moonBitType(propName, prop.Items)
		arrayType := strings.TrimSuffix(prop.moonBitType(propName, prop.Items), "?")
		return fmt.Sprintf("Array[%v]", arrayType) + suffix
	case `"string"`:
		if len(prop.Enum) > 0 {
			enumName := titleCase(propName)
			enumBody := prop.convertEnum(enumName, "")
			d.helperStructsAndMethods = append(d.helperStructsAndMethods, enumBody)
			return enumName + suffix
		}
		return "String" + suffix
	case `"object"`:
		if len(prop.Properties) == 0 {
			return "Json" + suffix
		}
		subTypeName := d.name + titleCase(propName)
		subType := prop.convert(subTypeName)
		d.helperStructsAndMethods = append(d.helperStructsAndMethods, subType)
		d.helperStructsAndMethods = append(d.helperStructsAndMethods, prop.helperStructsAndMethods...)
		return subTypeName + suffix
	case "null":
		refType, anyOf := prop.refType(propName, d.Required)
		if len(anyOf) > 0 {
			enumName := d.name + titleCase(propName)
			enumBody := prop.convertEnum(enumName, "")
			d.helperStructsAndMethods = append(d.helperStructsAndMethods, enumBody)
			return enumName
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

func (d *Definition) genHelperMethods(jsonRPCConsts map[string]string) {
	switch {
	case strings.HasSuffix(d.name, "Request"):
		d.genRequestHelperMethods(jsonRPCConsts)
	case strings.HasSuffix(d.name, "Notification"):
		d.genNotificationHelperMethods(jsonRPCConsts)
	case strings.HasSuffix(d.name, "Result"):
		d.genResultHelperMethods(jsonRPCConsts)
	}
}

func (d *Definition) genRequestHelperMethods(jsonRPCConsts map[string]string) {
	method, hasConstMethod := jsonRPCConsts["method"]
	if !hasConstMethod {
		method = "self.method_"
	}

	lines := []string{
		"///|",
		fmt.Sprintf("pub impl MCPCall for %v with to_call(self, id) {", d.name),
		fmt.Sprintf("  @jsonrpc2.new_call(id, %v, self.params.to_json())", method),
		"}",
		"",
		"///|",
		fmt.Sprintf("pub fn %v::from_message(msg : @jsonrpc2.Message) -> (@jsonrpc2.ID, %[1]v)?  {", d.name),
		"  guard msg is Request(req) else { return None }",
		"  guard req.id is Some(id) else { return None }",
	}

	if hasConstMethod {
		lines = append(lines,
			fmt.Sprintf("  guard req.method_ == %v else { return None }", method),
			`  let json = { "params" : req.params }.to_json()`,
		)
	} else {
		lines = append(lines, `  let json = { "method_": req.method_.to_json(), "params": req.params }.to_json()`)
	}

	lines = append(lines,
		fmt.Sprintf("  let v : Result[%v, _] = @json.from_json?(json)", d.name),
		"  guard v is Ok(request) else { return None }",
		"  Some((id, request))",
		"}",
	)

	d.helperStructsAndMethods = append(d.helperStructsAndMethods, strings.Join(lines, "\n"))
}

func (d *Definition) genNotificationHelperMethods(jsonRPCConsts map[string]string) {
	method, hasConstMethod := jsonRPCConsts["method"]
	if !hasConstMethod {
		method = "self.method_"
	}

	lines := []string{
		"///|",
		fmt.Sprintf("pub impl MCPNotification for %v with to_notification(self) {", d.name),
		fmt.Sprintf("  @jsonrpc2.new_notification(%v, self.params.to_json())", method),
		"}",
		"",
		"///|",
		fmt.Sprintf("pub fn %v::from_message(msg : @jsonrpc2.Message) -> %[1]v?  {", d.name),
		"  guard msg is Request(req) else { return None }",
		"  guard req.id is None else { return None }",
	}

	if hasConstMethod {
		lines = append(lines,
			fmt.Sprintf("  guard req.method_ == %v else { return None }", method),
			`  let json = { "params" : req.params }.to_json()`,
		)
	} else {
		lines = append(lines, `  let json = { "method_": req.method_.to_json(), "params": req.params }.to_json()`)
	}

	lines = append(lines,
		fmt.Sprintf("  let v : Result[%v, _] = @json.from_json?(json)", d.name),
		"  guard v is Ok(notification) else { return None }",
		"  Some(notification)",
		"}",
	)

	d.helperStructsAndMethods = append(d.helperStructsAndMethods, strings.Join(lines, "\n"))
}

func (d *Definition) genResultHelperMethods(jsonRPCConsts map[string]string) {
	lines := []string{
		"///|",
		fmt.Sprintf("pub impl MCPResponse for %v with to_response(self, id) {", d.name),
		"  @jsonrpc2.new_response(id, Ok(self.to_json()))",
		"}",
		"",
		"///|",
		fmt.Sprintf("pub fn %v::from_message(msg : @jsonrpc2.Message) -> (@jsonrpc2.ID, %[1]v)?  {", d.name),
		"  guard msg is Response(res) else { return None }",
		"  guard res.result is Ok(json) else { return None }",
		fmt.Sprintf("  let v : Result[%v, _] = @json.from_json?(json)", d.name),
		"  guard v is Ok(result) else { return None }",
		"  Some((res.id, result))",
		"}",
	}

	d.helperStructsAndMethods = append(d.helperStructsAndMethods, strings.Join(lines, "\n"))
}

func titleCase(s string) string {
	if s == "" {
		return s
	}
	return strings.ToUpper(s[0:1]) + s[1:]
}

func must(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

type Schema struct {
	Schema      string                 `json:"$schema"`
	Definitions map[string]*Definition `json:"definitions"`
}

type Definition struct {
	AdditionalProperties     any                    `json:"additionalProperties,omitempty"`
	AnyOf                    []*Definition          `json:"anyOf,omitempty"`
	Ref                      string                 `json:"$ref,omitempty"`
	Description              string                 `json:"description,omitempty"`
	Format                   string                 `json:"format,omitempty"`
	Properties               map[string]*Definition `json:"properties,omitempty"`
	Required                 []string               `json:"required,omitempty"`
	Items                    *Definition            `json:"items,omitempty"`
	Enum                     []json.RawMessage      `json:"enum,omitempty"`
	Const                    json.RawMessage        `json:"const,omitempty"`
	Maximum                  *int                   `json:"maximum,omitempty"`
	Minimum                  *int                   `json:"minimum,omitempty"`
	AdditionalPropertiesBool *bool                  `json:"-"`
	// Handle specific cases where 'additionalProperties' is a boolean
	AdditionalPropertiesSchema *Definition     `json:"-"`
	Type                       json.RawMessage `json:"type,omitempty"`

	// these are used internally for generating FromJson and ToJson
	name       string `json:"-"`
	isRequired bool   `json:"-"`
	// these are added to the auto-generated source following the structs
	helperStructsAndMethods []string `json:"-"`
}

// MarshalJSON handles the serialization of AdditionalProperties which can be a bool or a schema
func (d *Definition) MarshalJSON() ([]byte, error) {
	type Alias Definition
	aux := &struct {
		*Alias
	}{
		Alias: (*Alias)(d),
	}

	if d.AdditionalPropertiesBool != nil {
		aux.AdditionalProperties = *d.AdditionalPropertiesBool
	} else if d.AdditionalPropertiesSchema != nil {
		aux.AdditionalProperties = d.AdditionalPropertiesSchema
	}

	return json.Marshal(aux)
}
