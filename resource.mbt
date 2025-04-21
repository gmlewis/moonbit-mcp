///|
pub(open) trait MCPResource {
  as_resource(Self) -> Resource
  call_resource(Self, Json?) -> ReadResourceResult
}
