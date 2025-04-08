///| An MCPCaller represents types that can be serialized to and from
/// JSON-RPC "call" messages.
pub trait MCPCaller {
  to_call(Self) -> @jsonrpc2.Message
  from_message(@jsonrpc2.Message) -> Self?
}

///| An MCPNotification represents types that can be serialized to and from
/// JSON-RPC "notification" messages.
pub trait MCPNotification {
  to_notification(Self) -> @jsonrpc2.Message
  from_message(@jsonrpc2.Message) -> Self?
}

///| An MCPResponse represents types that can be serialized to and from
/// JSON-RPC "response" messages.
pub trait MCPResponse {
  to_response(Self) -> @jsonrpc2.Message
  from_message(@jsonrpc2.Message) -> Self?
}
