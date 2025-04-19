///|
fn main {
  @mcp.Server::new(name="Basic", version="0.1.0")
  ..tool(@mcp.tool(name="add", properties={"a":
  ..tool("hello", SayHelloTool::new())
  ..prompt("prompt_test", PromptTest::new())
  ..resource("greeting", Resource::new("greeting://{name}"))
  ..resource(
    "resource_test",
    Resource::new(
      "test://resource", "This is a test resource", "application/json",
    ),
  )
  ..resource(
    "app_logs",
    Resource::new("file://app_logs", "The app logs", "text/plain"),
  )
  .connect(@mcp.StdioTransport::new())
}
// ..prompt("prompt_test", "This is a test prompt", prompt_test)

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
