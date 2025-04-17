///|
fn main {
  @mcp.Server::new()
  ..with_stdio_transport()
  ..with_new_tool("hello", "Say hello to a person", say_hello)
  ..with_new_prompt("prompt_test", "This is a test prompt", prompt_test)
  ..with_new_resource(
    "test://resource", "resource_test", "This is a test resource", "application/json",
    resource_test,
  )
  ..with_new_resource(
    "file://app_logs", "app_logs", "The app logs", "text/plain", app_logs,
  )
  .run()
}

///|
struct Content {
  title : String // `json:"title" jsonschema:"required,description=The title to submit"`
  description : String? // `json:"description" jsonschema:"description=The description to submit"`
} derive(Show, Eq, ToJson, FromJson)

///|
struct SayHelloArguments {
  submitter : String //  `json:"submitter" jsonschema:"required,description=The name of the host calling this tool (openai, google, claude, vscode, etc)"`
  content : Content // `json:"content" jsonschema:"required,description=The content of the message"`
} derive(Show, Eq, ToJson, FromJson)

///|
fn say_hello(json : Json?) -> @mcp.CallToolResult {
  guard json is Some(json) else {
    return @mcp.new_call_tool_error_result("Invalid JSON")
  }
  let args : Result[SayHelloArguments, _] = @json.from_json?(json)
  guard args is Ok(args) else {
    return @mcp.new_call_tool_error_result("Invalid arguments")
  }
  let greeting = @mcp.new_call_tool_text_result("Hello, \{args.submitter}!")
  @mcp.CallToolResult::new([greeting])
}

///|
fn prompt_test(msg : @mcp.PromptMessage) -> @mcp.GetPromptResult {
  ...
}

///|
fn resource_test(req : @mcp.ReadResourceRequest) -> @mcp.ReadResourceResult {
  ...
}

///|
fn app_logs(req : @mcp.ReadResourceRequest) -> @mcp.ReadResourceResult {
  ...
}
