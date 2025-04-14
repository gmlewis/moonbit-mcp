///|
/// Read one line from stdin as a String (including the newline).
pub fn read_line() -> String!@io.IOError {
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
/// Write a string to stdout.
pub fn write(s : String) -> Unit {
  let bytes = @base64.str2bytes(s)
  for i in 0..<bytes.length() {
    put_char(bytes[i])
  }
}
