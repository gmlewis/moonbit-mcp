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
		fmt.Printf("\n%v\n", def.convert(key))
	}

	log.Printf("Done.")
}

func (d *Definition) convert(name string) string {
	lines := []string{
		fmt.Sprintf("///| %v: %v", name, strings.Replace(d.Description, "\n", "\n/// ", -1)),
		fmt.Sprintf("pub(all) struct %v {", name),
	}

	props := make([]string, 0, len(d.Properties))
	for key := range d.Properties {
		props = append(props, key)
	}
	sort.Strings(props)
	for _, propName := range props {
		prop := d.Properties[propName]
		lines = append(lines, fmt.Sprintf("  // %v", strings.Replace(prop.Description, "\n", "\n  // ", -1)))
		lines = append(lines, fmt.Sprintf("  %v : %v", propName, moonBitType(propName, prop)))
	}

	lines = append(lines, "} derive(Show, Eq, FromJson, ToJson)")
	return strings.Join(lines, "\n")
}

func moonBitType(propName string, prop *Definition) string {
	typ := prop.Type
	v, err := json.Marshal(typ)
	must(err)
	switch string(v) {
	case `"boolean"`:
		return "Bool"
	case `"number"`:
		return "Double"
	case `"array"`:
		return "Array[]" // todo
	case `"string"`:
		return "String"
	case `"object"`:
		return "Object" // todo
	case "null":
		if prop.Ref != "" {
			return prop.Ref
		}
		log.Fatalf("missing type and $ref for '%v'", propName)
	default:
		log.Fatalf("unhandled mooonBitType: %v", string(v))
	}
	return ""
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
