package main

import (
	"encoding/json"
)

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
