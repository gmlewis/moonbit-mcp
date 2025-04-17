///|
pub struct Server {
  tools : Map[String, &MCPTool]
  mut transport : &Transport
}

///|
pub fn Server::new() -> Server {
  let tools = {}
  let transport = StdioTransport::new()
  Server::{ tools, transport }
}

///|
pub fn Server::with_stdio_transport(self : Server) -> Unit {
  self.transport = StdioTransport::new()
}

///|
pub fn Server::with_tool(self : Server, tool : &MCPTool) -> Unit {
  let t = tool.as_tool()
  self.tools[t.name] = tool
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
