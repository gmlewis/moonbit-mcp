///|
fn main {
  let now = @mcp.unix_nanos()
  println("Current time in nanoseconds since epoch: \{now}")
  @mcp.write_stderr(
    "This line should only go to stderr.\nSleeping for 2 seconds...\n",
  )
  @mcp.sleep(2)
  @mcp.write_stderr("Done sleeping.\n")

  //
  let stdio = @mcp.StdioTransport::new()
  stdio
  ..with_close_handler(close_handler)
  ..with_error_handler(error_handler)
  ..with_message_handler(message_handler)

  //
  guard stdio.start() is None else { abort("Failed to start transport") }

  // Send a call
  guard stdio.send_request(@mcp.Request::new("method1")) is (id, None) else {
    abort("Failed to send message")
  }
  @mcp.write_stderr("Sent request with ID: \{id}\n")

  // Send a notification
  guard stdio.send_notification(@mcp.Notification::new("method2")) is None else {
    abort("Failed to send message")
  }

  // Send a response
  guard stdio.send_response(@jsonrpc2.ID::number(1), @mcp.EmptyResult::new())
    is None else {
    abort("Failed to send message")
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
fn message_handler(message : @jsonrpc2.Message) -> Unit {
  println("Message: \{message}")
}
