///|
struct Server {
  prompts : Map[String, PromptFunc]
  resources : Map[String, ResourceFunc]
  tools : Map[String, ServerTool]
  mut transport : &Transport?
}

///|
pub struct ServerTool {
  tool : &MCPTool
  list_changed : Bool
}

///|
pub fn Server::new() -> Server {
  let prompts = {}
  let resources = {}
  let tools = {}
  let transport = None
  Server::{ prompts, resources, tools, transport }
}

///|
pub fn Server::with_stdio_transport(self : Server, stdio : &Transport) -> Unit {
  self.transport = Some(stdio)
}

///|
pub fn Server::with_tool(
  self : Server,
  tool : &MCPTool,
  list_changed~ : Bool = false
) -> Unit {
  let t = tool.as_tool()
  self.tools[t.name] = ServerTool::{ tool, list_changed }
}

///|
pub(all) type PromptFunc (PromptMessage) -> GetPromptResult

///|
pub fn Server::with_prompt(
  _self : Server,
  name : String,
  description : String,
  prompt_func : PromptFunc
) -> Unit {
  ...
}

///|
pub(all) type ResourceFunc (ReadResourceRequest) -> ReadResourceResult

///|
pub fn Server::with_resource(
  _self : Server,
  uri : String,
  name : String,
  description : String,
  mime_type : String,
  resource_func : ResourceFunc
) -> Unit {
  ...
}

///|
pub fn Server::run(self : Server) -> Unit {
  guard self.transport is Some(transport) else {
    write_stderr("Transport not set\n")
    return
  }

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
fn Server::close_handler(self : Server) -> Unit {
  write_stderr("close_handler called\n")
}

///|
fn Server::error_handler(self : Server, error : TransportError) -> Unit {
  write_stderr("Error: \{error}\n")
}

///|
fn Server::message_handler(
  self : Server,
  _ctx : Context,
  message : @jsonrpc2.Message
) -> Unit {
  write_stderr("Message: \{message}\n")
}
