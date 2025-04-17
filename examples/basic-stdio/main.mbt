///|
fn main {
  let stdio = @mcp.StdioTransport::new()
    ..with_close_handler(close_handler)
    ..with_error_handler(error_handler)
    ..with_message_handler(message_handler)

  //
  let ctx = @mcp.Context::new()
  stdio.start(ctx) |> ignore()

  // Send a call
  let params = { "key1": "value1" }.to_json()
  guard stdio.send(
      ctx,
      @jsonrpc2.new_call(@jsonrpc2.ID::number(1), "method1", params),
    )
    is None else {
    println("Failed to send message")
  }

  // Send a notification
  let params = { "key2": "value2" }.to_json()
  guard stdio.send(ctx, @jsonrpc2.new_notification("method2", params)) is None else {
    println("Failed to send message")
  }

  // Send a response
  let result = Ok(params)
  guard stdio.send(ctx, @jsonrpc2.new_response(@jsonrpc2.ID::number(1), result))
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
