///|
const DEFAULT_PING_PERIOD_SECONDS = 5

///|
const DEFAULT_PING_TIMEOUT_MILLIS = 1_000 // 1 second

///|
const DEFAULT_TIMEOUT_MILLIS = 10_000 // 10 seconds

///|
const MAX_TIMEOUT_MILLIS = 600_000 // 10 minutes

///|
struct Server {
  name : String
  version : String
  prompts : Map[String, ServerPrompt]
  resources : Map[String, ServerResource]
  tools : Map[String, ServerTool]
  mut transport : &Transport?
  in_flight_requests : Map[Int64, Context]

  // timeouts
  mut default_timeout_millis : Int
  mut max_timeout_millis : Int
  mut ping_period_seconds : Int
  mut ping_timeout_millis : Int
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
  let default_timeout_millis = DEFAULT_TIMEOUT_MILLIS
  let max_timeout_millis = MAX_TIMEOUT_MILLIS
  let ping_period_seconds = DEFAULT_PING_PERIOD_SECONDS
  let ping_timeout_millis = DEFAULT_PING_TIMEOUT_MILLIS
  Server::{
    name,
    version,
    prompts,
    resources,
    tools,
    transport,
    in_flight_requests: {},
    default_timeout_millis,
    max_timeout_millis,
    ping_period_seconds,
    ping_timeout_millis,
  }
}

///|
/// with_ping_period_seconds sets the period of pings to the client.
/// A value of 0 disables pings.
pub fn Server::with_ping_period_seconds(self : Server, seconds : Int) -> Unit {
  self.ping_period_seconds = seconds
}

///|
/// with_ping_timeout_millis sets the timeout for pings to the client.
pub fn Server::with_ping_timeout_millis(self : Server, millis : Int) -> Unit {
  self.ping_timeout_millis = millis
}

///|
/// with_timeout sets the default timeout for requests.
pub fn Server::with_timeout_millis(self : Server, millis : Int) -> Unit {
  self.default_timeout_millis = millis
}

///|
/// with_max_timeout sets the maximum timeout for requests.
pub fn Server::with_max_timeout(self : Server, millis : Int) -> Unit {
  self.max_timeout_millis = millis
}

///|
pub(all) type ToolFunc async (Map[String, Json]) -> CallToolResult noraise

///|
pub fn Server::tool(
  self : Server,
  tool : &MCPTool,
  func : ToolFunc,
  list_changed~ : Bool = false,
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
  list_changed~ : Bool = false,
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
  list_changed~ : Bool = false,
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
  .with_message_handler(fn(msg) { self.message_handler(msg) })

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
fn Server::message_handler(_self : Server, message : @jsonrpc2.Message) -> Unit {
  write_stderr("Message: \{message}\n")
}

///|
pub fn bad_params(params : Map[String, Json]) -> CallToolResult {
  let json = params.to_json().stringify()
  let msg = "Invalid JSON: \{json}"
  write_stderr(msg)
  CallToolResult::new([TextContent::new(msg)])
}
