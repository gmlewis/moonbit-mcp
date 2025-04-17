///|
pub struct Server {}

///|
pub fn Server::new() -> Server {
  ...
  Server::{  }
}

///|
pub fn Server::with_stdio_transport(_self : Server) -> Unit {
  ...
}

///|
pub(all) type ToolFunc (Json?) -> CallToolResult

///|
pub fn Server::with_new_tool(
  _self : Server,
  name : String,
  description : String,
  tool_func : ToolFunc
) -> Unit {
  ...
}

///|
pub(all) type PromptFunc (PromptMessage) -> GetPromptResult

///|
pub fn Server::with_new_prompt(
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
pub fn Server::with_new_resource(
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
