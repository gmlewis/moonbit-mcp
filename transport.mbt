///|
pub trait Transport {
  /// Read one line from stdin as a String (including the newline).
  read_line(Self) -> String!@io.IOError
  /// Write a string to stdout.
  write(Self, String) -> Unit
}

///|
pub struct StdioTransport {}

///|
pub fn StdioTransport::new() -> StdioTransport {
  StdioTransport::{  }
}

///|
pub impl Transport for StdioTransport with read_line(_self) {
  let buf = @io.Buffer::new()
  for {
    let byte = get_char()
    let (_, err) = buf.write_byte(byte)
    guard err is None else { raise err.unwrap() }
    if byte == b'\n' {
      break
    }
  }
  buf.to_string()
}

///|
pub impl Transport for StdioTransport with write(_self, s) {
  let bytes = @base64.str2bytes(s)
  for i in 0..<bytes.length() {
    put_char(bytes[i])
  }
}
