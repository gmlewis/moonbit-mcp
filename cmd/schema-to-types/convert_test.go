package main

import (
	_ "embed"
	"encoding/json"
	"testing"

	"github.com/google/go-cmp/cmp"
)

//go:embed testdata/2025-03-26/schema.json
var jsonSchema20250326 []byte

func TestConvert(t *testing.T) {
	t.Parallel()
	tests := []struct {
		name                   string
		want                   *Definition
		wantTypesFile          string
		wantTypesJSONEnumsFile string
		wantTypesJSONFile      string
		wantTypesNewFile       string
		wantMBT                string
	}{
		{
			name: "Cursor",
			want: &Definition{
				Description: "An opaque token used to represent a cursor for pagination.",
				Type:        json.RawMessage(`"string"`),
				name:        "Cursor",
			},
			wantMBT: `///|
/// An opaque token used to represent a cursor for pagination.
pub type Cursor String derive(Show, Eq, FromJson, ToJson)`,
		},
		{
			name: "EmptyResult",
			want: &Definition{
				Description: "A response that indicates success but carries no data.",
				Ref:         "#/definitions/Result",
				name:        "EmptyResult",
				helperStructsAndMethods: []string{`///|
pub impl MCPResponse for EmptyResult with to_response(self, id) {
  @jsonrpc2.new_response(id, Ok(self.to_json()))
}

///|
pub fn EmptyResult::from_message(msg : @jsonrpc2.Message) -> (@jsonrpc2.ID, EmptyResult)?  {
  guard msg is Response(res) else { return None }
  guard res.result is Ok(json) else { return None }
  let v : Result[EmptyResult, _] = @json.from_json?(json)
  guard v is Ok(result) else { return None }
  Some((res.id, result))
}`},
			},
			wantTypesNewFile: `
///|
pub fn EmptyResult::new(
) -> EmptyResult {
  Result_({})
}
`,
			wantMBT: `///|
/// A response that indicates success but carries no data.
pub type EmptyResult Result_ derive(Show, Eq, FromJson, ToJson)`,
		},
		{
			name: "GetPromptRequest",
			want: &Definition{
				Description: "Used by the client to get a prompt provided by the server.",
				Properties: map[string]*Definition{
					"method": {
						Const: json.RawMessage(`"prompts/get"`),
						Type:  json.RawMessage(`"string"`),
					},
					"params": {
						Properties: map[string]*Definition{
							"arguments": {
								Description: "Arguments to use for templating the prompt.",
								Type:        json.RawMessage(`"object"`),
								AdditionalProperties: map[string]string{
									"type": "string",
								},
							},
							"name": {
								Description: "The name of the prompt or prompt template.",
								Type:        json.RawMessage(`"string"`),
							},
						},
						Required: []string{"name"},
						Type:     json.RawMessage(`"object"`),
					},
				},
				Required:   []string{"method", "params"},
				Type:       json.RawMessage(`"object"`),
				name:       "GetPromptRequest",
				isRequired: true,
				helperStructsAndMethods: []string{
					`///|
pub(all) struct GetPromptRequestParams {
  /// Arguments to use for templating the prompt.
  arguments : Map[String, String]?
  /// The name of the prompt or prompt template.
  name : String
} derive(Show, Eq)`,
					`///|
pub impl MCPRequest for GetPromptRequest with to_call(self, id) {
  @jsonrpc2.new_call(id, "prompts/get", self.params.to_json())
}

///|
pub fn GetPromptRequest::from_message(msg : @jsonrpc2.Message) -> (@jsonrpc2.ID, GetPromptRequest)?  {
  guard msg is Request(req) else { return None }
  guard req.id is Some(id) else { return None }
  guard req.method_ == "prompts/get" else { return None }
  let json = { "params" : req.params }.to_json()
  let v : Result[GetPromptRequest, _] = @json.from_json?(json)
  guard v is Ok(request) else { return None }
  Some((id, request))
}`,
				},
			},
			wantTypesJSONFile: `
///|
pub impl ToJson for GetPromptRequestParams with to_json(self) {
  let obj = {}
  if self.arguments is Some(v) {
    obj["arguments"] = v.to_json()
  }
  obj["name"] = self.name.to_json()
  obj.to_json()
}

///|
pub impl @json.FromJson for GetPromptRequestParams with from_json(json, path) {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "expected object"))
  }
  let arguments : Map[String, String]? = match obj["arguments"] {
    Some(v) =>
      match @json.from_json?(v) {
        Ok(v) => Some(v)
        Err(e) => raise e
      }
    None => None
  }
  guard obj["name"] is Some(json) else {
    raise @json.JsonDecodeError((path, "expected field 'name'"))
  }
  let v : Result[String, _] = @json.from_json?(json)
  guard v is Ok(name) else {
    raise @json.JsonDecodeError((path, "expected field 'name'"))
  }
  { arguments, name }
}

///|
pub impl ToJson for GetPromptRequest with to_json(self) {
  let obj = {}
  obj["params"] = self.params.to_json()
  obj.to_json()
}

///|
pub impl @json.FromJson for GetPromptRequest with from_json(json, path) {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "expected object"))
  }
  guard obj["params"] is Some(json) else {
    raise @json.JsonDecodeError((path, "expected field 'params'"))
  }
  let v : Result[GetPromptRequestParams, _] = @json.from_json?(json)
  guard v is Ok(params) else {
    raise @json.JsonDecodeError((path, "expected field 'params'"))
  }
  { params }
}
`,
			wantTypesNewFile: `
///|
pub fn GetPromptRequestParams::new(
  /// Arguments to use for templating the prompt.
  arguments? : Map[String, String],
  /// The name of the prompt or prompt template.
  name : String,
) -> GetPromptRequestParams {
  { arguments, name }
}

///|
pub fn GetPromptRequest::new(
  params : GetPromptRequestParams,
) -> GetPromptRequest {
  { params }
}
`,
			wantMBT: `///|
/// GetPromptRequest: Used by the client to get a prompt provided by the server.
pub(all) struct GetPromptRequest {
  /// JSON-RPC: "method" = "prompts/get"
  params : GetPromptRequestParams
} derive(Show, Eq)`,
		},
	}

	var schema *Schema
	if err := json.Unmarshal(jsonSchema20250326, &schema); err != nil {
		t.Fatal(err)
	}
	defs, _ := chunkify(string(tsSchema20250326))
	schema.tsDefs = defs

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			got := schema.Definitions[tt.name]
			gotOutBufs := &outBufsT{}
			gotMBT := schema.convert(got, gotOutBufs, tt.name)

			// Definitions is not comparable with cmp.Diff without a custom diff method.
			// Therefore, check the serialization of it along with any extra fields.
			gotJSON, err := json.MarshalIndent(got, "", "  ")
			if err != nil {
				t.Fatal(err)
			}
			wantJSON, err := json.MarshalIndent(tt.want, "", "  ")
			if err != nil {
				t.Fatal(err)
			}

			if diff := cmp.Diff(wantJSON, gotJSON); diff != "" {
				t.Logf("%v Definition: got:\n%s", tt.name, gotJSON)
				t.Errorf("%v Definition mismatch (-want +got):\n%v", tt.name, diff)
			}

			// Now check the extra fields.
			if diff := cmp.Diff(tt.want.AdditionalPropertiesBool, got.AdditionalPropertiesBool); diff != "" {
				t.Logf("%v AdditionalPropertiesBool: got:\n%s", tt.name, gotJSON)
				t.Errorf("%v AdditionalPropertiesBool mismatch (-want +got):\n%v", tt.name, diff)
			}

			if diff := cmp.Diff(tt.want.AdditionalPropertiesSchema, got.AdditionalPropertiesSchema); diff != "" {
				t.Logf("%v AdditionalPropertiesSchema: got:\n%s", tt.name, gotJSON)
				t.Errorf("%v AdditionalPropertiesSchema mismatch (-want +got):\n%v", tt.name, diff)
			}

			if diff := cmp.Diff(tt.want.name, got.name); diff != "" {
				t.Logf("%v name: got:\n%s", tt.name, gotJSON)
				t.Errorf("%v name mismatch (-want +got):\n%v", tt.name, diff)
			}

			if diff := cmp.Diff(tt.want.isRequired, got.isRequired); diff != "" {
				t.Logf("%v isRequired: got:\n%s", tt.name, gotJSON)
				t.Errorf("%v isRequired mismatch (-want +got):\n%v", tt.name, diff)
			}

			if diff := cmp.Diff(tt.want.helperStructsAndMethods, got.helperStructsAndMethods); diff != "" {
				t.Logf("%v helperStructsAndMethods: got:\n%s", tt.name, gotJSON)
				t.Errorf("%v helperStructsAndMethods mismatch (-want +got):\n%v", tt.name, diff)
			}

			// Check outBufsT
			if diff := cmp.Diff(tt.wantTypesFile, gotOutBufs.typesFile.String()); diff != "" {
				t.Errorf("%v typesFile mismatch (-want +got):\n%v", tt.name, diff)
			}
			if diff := cmp.Diff(tt.wantTypesJSONEnumsFile, gotOutBufs.typesJSONEnumsFile.String()); diff != "" {
				t.Errorf("%v typesJSONEnumsFile mismatch (-want +got):\n%v", tt.name, diff)
			}
			if diff := cmp.Diff(tt.wantTypesJSONFile, gotOutBufs.typesJSONFile.String()); diff != "" {
				t.Errorf("%v typesJSONFile mismatch (-want +got):\n%v", tt.name, diff)
			}
			if diff := cmp.Diff(tt.wantTypesNewFile, gotOutBufs.typesNewFile.String()); diff != "" {
				t.Errorf("%v typesNewFile mismatch (-want +got):\n%v", tt.name, diff)
			}

			// Check moonBit source
			if diff := cmp.Diff(tt.wantMBT, gotMBT); diff != "" {
				t.Errorf("%v moonBit mismatch (-want +got):\n%v", tt.name, diff)
			}
		})
	}
}
