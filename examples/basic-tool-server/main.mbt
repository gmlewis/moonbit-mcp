///|
fn main {
  @mcp.Server::new()
  ..with_stdio_transport()
  ..with_tool(SayHelloTool::new())
  ..with_prompt("prompt_test", "This is a test prompt", prompt_test)
  ..with_resource(
    "test://resource", "resource_test", "This is a test resource", "application/json",
    resource_test,
  )
  ..with_resource(
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
