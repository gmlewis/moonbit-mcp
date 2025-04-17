///|
fn main {
  let stdio = @mcp.StdioTransport::new()
    ..with_close_handler(close_handler)
    ..with_error_handler(error_handler)
    ..with_message_handler(message_handler)

  //
  let ctx = @mcp.Context::new().with_timeout(1000)
  stdio.start(ctx) |> ignore()

  // Send a call
  guard stdio.send_request(ctx, @mcp.Request::new("method1")) is None else {
    println("Failed to send message")
  }

  // Send a notification
  guard stdio.send_notification(ctx, @mcp.Notification::new("method2")) is None else {
    println("Failed to send message")
  }

  // Send a response
  guard stdio.send_response(
      ctx,
      @jsonrpc2.ID::number(1),
      @mcp.CustomResult::new(),
    )
    is None else {
    println("Failed to send message")
  }

  //
  stdio.close() |> ignore()
}

///|
fn close_handler() -> Unit {
  println("close_handler called")
}

///|
fn error_handler(error : @mcp.TransportError) -> Unit {
  println("Error: \{error}")
}

///|
fn message_handler(_ctx : @mcp.Context, message : @jsonrpc2.Message) -> Unit {
  println("Message: \{message}")
}
