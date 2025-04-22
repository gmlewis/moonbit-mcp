///|
struct Server {
  name : String
  version : String
  prompts : Map[String, ServerPrompt]
  resources : Map[String, ServerResource]
  tools : Map[String, ServerTool]
  mut transport : &Transport?
}

///|
pub struct ServerPrompt {
  prompt : &MCPPrompt
  list_changed : Bool
}

///|
pub struct ServerResource {
  resource : &MCPResource
  list_changed : Bool
}

///|
pub struct ServerTool {
  tool : &MCPTool
  list_changed : Bool
}

///|
pub fn Server::new(name~ : String, version~ : String) -> Server {
  let prompts = {}
  let resources = {}
  let tools = {}
  let transport = None
  Server::{ name, version, prompts, resources, tools, transport }
}

///|
pub(all) type ToolFunc async (Map[String, Json]) -> CallToolResult

///|
pub fn Server::tool(
  self : Server,
  tool : &MCPTool,
  func : ToolFunc,
  list_changed~ : Bool = false
) -> Unit {
  let t = tool.as_tool()
  self.tools[t.name] = ServerTool::{ tool, list_changed }
}

///|
pub(all) type PromptFunc (PromptMessage) -> GetPromptResult

///|
pub fn Server::prompt(
  self : Server,
  name : String,
  prompt : &MCPPrompt,
  list_changed~ : Bool = false
  // description : String,
) -> Unit {
  self.prompts[name] = ServerPrompt::{ prompt, list_changed }
}

///|
pub(all) type ResourceFunc (ReadResourceRequest) -> ReadResourceResult

///|
pub fn Server::resource(
  self : Server,
  name : String,
  resource : &MCPResource,
  list_changed~ : Bool = false
  // uri : String,
  // description : String,
  // mime_type : String,
  // resource_func : ResourceFunc
) -> Unit {
  self.resources[name] = ServerResource::{ resource, list_changed }
}

///|
pub fn Server::connect(self : Server, transport : &Transport) -> Unit {
  self.transport = Some(transport)

  // create the handlers and register the tools, prompts, and resources.
  transport
  ..with_close_handler(fn() { self.close_handler() })
  ..with_error_handler(fn(e) { self.error_handler(e) })
  .with_message_handler(fn(ctx, msg) { self.message_handler(ctx, msg) })

  //
  guard transport.start() is None else {
    write_stderr("Failed to start transport\n")
    return
  }

}

///|
fn Server::close_handler(_self : Server) -> Unit {
  write_stderr("close_handler called\n")
}

///|
fn Server::error_handler(_self : Server, error : TransportError) -> Unit {
  write_stderr("Error: \{error}\n")
}

///|
fn Server::message_handler(
  _self : Server,
  _ctx : Context,
  message : @jsonrpc2.Message
) -> Unit {
  write_stderr("Message: \{message}\n")
}

///|
pub fn bad_params(params : Map[String, Json]) -> CallToolResult {
  let json = @json.stringify(params.to_json())
  let msg = "Invalid JSON: \{json}"
  write_stderr(msg)
  CallToolResult::new([TextContent::new(msg)])
}
