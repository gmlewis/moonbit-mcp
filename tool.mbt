///|
pub(open) trait MCPTool {
  as_tool(Self) -> Tool
  call_tool(Self, Json?) -> CallToolResult
}

///|
pub impl MCPTool for Tool with as_tool(self) {
  self
}

///|
pub impl MCPTool for Tool with call_tool(self, params) {
  ...
}
