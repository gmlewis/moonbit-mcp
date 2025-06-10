///|
pub type! TransportError String derive(Show, Eq)

///| Transport describes the minimal contract for a MCP transport that a client or server can communicate over.
pub trait Transport {
  /// Starts processing messages on the transport, including any connection steps that might need to be taken.
  ///
  /// This method should only be called after callbacks are installed, or else messages may be lost.
  ///
  /// NOTE: This method should not be called explicitly when using Client, Server, or Protocol classes,
  /// as they will implicitly call start().
  start(Self) -> TransportError?

  /// Sends an MCPRequest.
  send_request(Self, &MCPRequest) -> (@jsonrpc2.ID, TransportError?)
  /// Sends an MCPNotification.
  send_notification(Self, &MCPNotification) -> TransportError?
  /// Sends an MCPResponse with the provided ID.
  send_response(Self, @jsonrpc2.ID, &MCPResponse) -> TransportError?

  /// Closes the connection.
  close(Self) -> TransportError?

  /// with_close_handler sets the callback for when the connection is closed for any reason.
  /// This should be invoked when Close() is called as well.
  with_close_handler(Self, () -> Unit) -> Unit

  /// with_error_handler sets the callback for when an error occurs.
  /// Note that errors are not necessarily fatal; they are used for reporting any kind of exceptional condition out of band.
  with_error_handler(Self, (TransportError) -> Unit) -> Unit

  /// with_message_handler sets the callback for when a message (call, notification, or response) is received over the connection.
  /// Partially deserializes the messages to pass a @jsonrpc2.Message
  with_message_handler(Self, (@jsonrpc2.Message) -> Unit) -> Unit
}

///|
struct StdioTransport {
  mut last_id : Int64
  mut close_handler : (() -> Unit)?
  mut error_handler : ((TransportError) -> Unit)?
  mut message_handler : ((@jsonrpc2.Message) -> Unit)?
  mut reader : &@jsonrpc2.Reader?
  mut writer : &@jsonrpc2.Writer?
  uv : @uv.Loop?
}

///|
pub fn StdioTransport::new() -> StdioTransport {
  let close_handler = None
  let error_handler = None
  let message_handler = None
  let reader = None
  let writer = None
  let uv = try Some(@uv.Loop::new!()) catch {
    e => {
      write_stderr("Failed to create uv loop: \{e}\n")
      None
    }
  }
  let self = StdioTransport::{
    last_id: 0,
    close_handler,
    error_handler,
    message_handler,
    reader,
    writer,
    uv,
  }
  let reader = @jsonrpc2.line_framer().reader(self)
  let writer = @jsonrpc2.line_framer().writer(self)
  self.reader = Some(reader)
  self.writer = Some(writer)
  self
}

///|
pub impl Transport for StdioTransport with start(self) {
  set_raw_mode()
  guard self.uv is Some(uv) else {
    return Some(TransportError("uv loop is not initialized"))
  }
  None
}

///|
pub impl Transport for StdioTransport with close(self) {
  if self.close_handler is Some(handler) {
    handler()
  }
  if self.uv is Some(uv) {
    try uv.close!() catch {
      e => write_stderr("Failed to close uv loop: \{e}\n")
    }
  }
  restore_terminal()
  None
}

///|
pub impl Transport for StdioTransport with with_close_handler(self, handler) {
  self.close_handler = Some(handler)
}

///|
pub impl Transport for StdioTransport with with_error_handler(self, handler) {
  self.error_handler = Some(handler)
}

///|
pub impl Transport for StdioTransport with with_message_handler(self, handler) {
  self.message_handler = Some(handler)
}

///|
pub impl @io.ByteReader for StdioTransport with read_byte(_self) {
  let byte = get_char()
  (byte, None)
}

///|
pub impl @io.Writer for StdioTransport with write(_self, bytes) {
  for i in 0..<bytes.length() {
    put_char(bytes[i])
  }
  (bytes.length(), None)
}

///|
pub impl Transport for StdioTransport with send_request(self, message) {
  self.last_id += 1
  let id = @jsonrpc2.ID::number(self.last_id)
  let err = self.send(message.to_call(id))
  (id, err)
}

///|
pub impl Transport for StdioTransport with send_notification(self, message) {
  self.send(message.to_notification())
}

///|
pub impl Transport for StdioTransport with send_response(self, id, message) {
  self.send(message.to_response(id))
}

///|
fn StdioTransport::send(
  self : StdioTransport,
  message : @jsonrpc2.Message
) -> TransportError? {
  let result = self.writer.unwrap().write(message)
  guard result is (_, None) else {
    if self.error_handler is Some(handler) {
      handler(TransportError(result.1.to_string()))
    }
    return Some(TransportError("Failed to send message: \{result.1}"))
  }
  None
}
