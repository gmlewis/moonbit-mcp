package main

import (
	_ "embed"
	"encoding/json"
	"testing"

	"github.com/google/go-cmp/cmp"
)

//go:embed testdata/2025-03-26/schema.json
var schema20250326 []byte

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
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json
) -> EmptyResult {
  Result_::new(
    _meta?,
  )
}
`,
			wantMBT: `///|
/// A response that indicates success but carries no data.
pub type EmptyResult Result_ derive(Show, Eq, FromJson, ToJson)`,
		},
	}

	var schema *Schema
	if err := json.Unmarshal(schema20250326, &schema); err != nil {
		t.Fatal(err)
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			got := schema.Definitions[tt.name]
			gotOutBufs := &outBufsT{}
			gotMBT := got.convert(gotOutBufs, tt.name)

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
