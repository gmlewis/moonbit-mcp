///|
const DEFAULT_PING_FREQUENCY_SECONDS = 5

///|
const DEFAULT_PING_TIMEOUT_MILLIS = 1_000 // 1 second

///|
const DEFAULT_TIMEOUT_MILLIS = 10_000 // 10 seconds

///|
const MAX_TIMEOUT_MILLIS = 600_000 // 10 minutes

///|
pub struct Context {
  start_time_unix_nanos : Int64
  timeout_millis : Int?
}

///|
pub fn Context::new() -> Context {
  let start_time_unix_nanos = unix_nanos()
  Context::{ start_time_unix_nanos, timeout_millis: None }
}

///|
pub fn Context::with_timeout(self : Context, timeout_millis : Int) -> Context {
  let start_time_unix_nanos = unix_nanos()
  Context::{
    ..self,
    start_time_unix_nanos,
    timeout_millis: Some(timeout_millis),
  }
}

///|
fn Context::now(self : Context) -> Context {
  let start_time_unix_nanos = unix_nanos()
  Context::{ ..self, start_time_unix_nanos, }
}

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
  send_request(Self, Context, &MCPRequest) -> TransportError?
  /// Sends an MCPNotification.
  send_notification(Self, Context, &MCPNotification) -> TransportError?
  /// Sends an MCPResponse with the provided ID.
  send_response(Self, Context, @jsonrpc2.ID, &MCPResponse) -> TransportError?

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
  with_message_handler(Self, (Context, @jsonrpc2.Message) -> Unit) -> Unit

  // with_ping_frequency_seconds sets the frequency of pings to the server.
  // A value of 0 disables pings.
  with_ping_frequency_seconds(Self, Int) -> Unit

  // with_ping_timeout_millis sets the timeout for pings to the server.
  with_ping_timeout_millis(Self, Int) -> Unit

  // with_timeout sets the default timeout for requests.
  with_timeout(Self, Int) -> Unit

  /// with_max_timeout sets the maximum timeout for requests.
  with_max_timeout(Self, Int) -> Unit
}

///|
struct StdioTransport {
  mut default_timeout_millis : Int
  mut max_timeout_millis : Int
  mut ping_frequency_seconds : Int
  mut ping_timeout_millis : Int
  mut last_id : Int64
  mut close_handler : (() -> Unit)?
  mut error_handler : ((TransportError) -> Unit)?
  mut message_handler : ((Context, @jsonrpc2.Message) -> Unit)?
  mut reader : &@jsonrpc2.Reader?
  mut writer : &@jsonrpc2.Writer?
  in_flight_requests : Map[Int64, Context]
  uv : @uv.Loop?
}

///|
pub fn StdioTransport::new() -> StdioTransport {
  let default_timeout_millis = DEFAULT_TIMEOUT_MILLIS
  let max_timeout_millis = MAX_TIMEOUT_MILLIS
  let ping_frequency_seconds = DEFAULT_PING_FREQUENCY_SECONDS
  let ping_timeout_millis = DEFAULT_PING_TIMEOUT_MILLIS
  let close_handler = None
  let error_handler = None
  let message_handler = None
  let reader = None
  let writer = None
  let in_flight_requests = {}
  let uv = try {
    Some(@uv.Loop::new!())
  } catch {
    e => {
      write_stderr("Failed to create uv loop: \{e}\n")
      None
    }
  }
  let self = StdioTransport::{
    default_timeout_millis,
    max_timeout_millis,
    ping_frequency_seconds,
    ping_timeout_millis,
    last_id: 0,
    close_handler,
    error_handler,
    message_handler,
    reader,
    writer,
    in_flight_requests,
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
  self.start_ping()
  None
}

///|
pub impl Transport for StdioTransport with close(self) {
  if self.close_handler is Some(handler) {
    handler()
  }
  if self.uv is Some(uv) {
    try {
      uv.close!()
    } catch {
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
pub impl Transport for StdioTransport with with_ping_frequency_seconds(
  self,
  seconds
) {
  self.ping_frequency_seconds = seconds
}

///|
pub impl Transport for StdioTransport with with_ping_timeout_millis(
  self,
  timeout
) {
  self.ping_timeout_millis = timeout
}

///|
pub impl Transport for StdioTransport with with_timeout(self, timeout) {
  self.default_timeout_millis = timeout
}

///|
pub impl Transport for StdioTransport with with_max_timeout(self, timeout) {
  self.max_timeout_millis = timeout
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
pub impl Transport for StdioTransport with send_request(self, context, message) {
  self.last_id += 1
  let id = @jsonrpc2.ID::number(self.last_id)
  let context = if context.timeout_millis is None {
    context.with_timeout(self.default_timeout_millis)
  } else {
    context.now()
  }
  self.in_flight_requests[self.last_id] = context
  self.send(context, message.to_call(id))
}

///|
pub impl Transport for StdioTransport with send_notification(
  self,
  context,
  message
) {
  self.send(context, message.to_notification())
}

///|
pub impl Transport for StdioTransport with send_response(
  self,
  context,
  id,
  message
) {
  self.send(context, message.to_response(id))
}

///|
fn StdioTransport::send(
  self : StdioTransport,
  _context : Context,
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

///|
fn StdioTransport::start_ping(self : StdioTransport) -> Unit {
  if self.ping_frequency_seconds == 0 {
    return
  }
  // run_async(fn() { self.ping_worker!() })
  // let ping = @jsonrpc2.Message::new_ping()
  // let ctx = Context::new().with_timeout(self.ping_timeout_millis)
  // self.send(ctx, ping)
}

///|
async fn StdioTransport::ping_worker(_self : StdioTransport) -> Unit {
  // let ping = @jsonrpc2.Message::new_ping()
  // let ctx = Context::new().with_timeout(DEFAULT_PING_TIMEOUT_MILLIS)
  // let transport = StdioTransport::new()
  // transport.send(ctx, ping)
}
