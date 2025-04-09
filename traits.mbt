///| An MCPCall represents types that can be serialized to and from
/// JSON-RPC "call" messages.
pub trait MCPCall {
  to_call(Self, @jsonrpc2.ID) -> @jsonrpc2.Message
}

///| An MCPNotification represents types that can be serialized to and from
/// JSON-RPC "notification" messages.
pub trait MCPNotification {
  to_notification(Self) -> @jsonrpc2.Message
}

///| An MCPResponse represents types that can be serialized to and from
/// JSON-RPC "response" messages.
pub trait MCPResponse {
  to_response(Self, @jsonrpc2.ID) -> @jsonrpc2.Message
}
