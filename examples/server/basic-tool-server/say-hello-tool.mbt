///|
struct SayHelloTool {
  tool : @mcp.Tool
}

///|
struct SayHelloArguments {
  submitter : String
} derive(Show, Eq, ToJson, FromJson)

///|
fn SayHelloTool::new(name : String) -> SayHelloTool {
  let description = "Say hello to a person"
  let properties = {
    "submitter": {
      "type": "string",
      "description": "The name of the host calling this tool (openai, google, claude, vscode, etc)",
    }.to_json(),
  }
  let required = ["submitter"]
  let input_schema = @mcp.ToolInputSchema::new(properties~, required~)
  let tool = @mcp.Tool::new(name, input_schema, description~)
  SayHelloTool::{ tool, }
}

///|
impl @mcp.MCPTool for SayHelloTool with as_tool(self) {
  self.tool
}

///|
impl @mcp.MCPTool for SayHelloTool with call_tool(_self, json) {
  say_hello(json)
}

///|
fn say_hello(json : Json?) -> @mcp.CallToolResult {
  guard json is Some(json) else {
    return @mcp.CallToolResult::new([@mcp.TextContent::new("Invalid JSON")])
  }
  let args : Result[SayHelloArguments, _] = @json.from_json?(json)
  guard args is Ok(args) else {
    return @mcp.CallToolResult::new([@mcp.TextContent::new("Invalid arguments")])
  }
  let greeting = @mcp.TextContent::new("Hello, \{args.submitter}!")
  @mcp.CallToolResult::new([greeting])
}
