///|
/// An MCPRequest represents types that can be serialized to and from
/// JSON-RPC "call" messages.
pub(open) trait MCPRequest {
  to_call(Self, @jsonrpc2.ID) -> @jsonrpc2.Message
}

///|
/// An MCPNotification represents types that can be serialized to and from
/// JSON-RPC "notification" messages.
pub(open) trait MCPNotification {
  to_notification(Self) -> @jsonrpc2.Message
}

///|
/// An MCPResponse represents types that can be serialized to and from
/// JSON-RPC "response" messages.
pub(open) trait MCPResponse {
  to_response(Self, @jsonrpc2.ID) -> @jsonrpc2.Message
}
