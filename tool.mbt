///|
pub(open) trait MCPTool {
  as_tool(Self) -> Tool
  call_tool(Self, Json?) -> CallToolResult
}
