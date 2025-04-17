///|
pub struct Server {
  prompts : Map[String, PromptFunc]
  resources : Map[String, ResourceFunc]
  tools : Map[String, ServerTool]
  mut transport : &Transport
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
  let transport = StdioTransport::new()
  Server::{ prompts, resources, tools, transport }
}

///|
pub fn Server::with_stdio_transport(self : Server, stdio : &Transport) -> Unit {
  self.transport = stdio
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
pub fn Server::run(_self : Server) -> Unit {
  ...
}
