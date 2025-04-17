///|
fn main {
  @mcp.set_raw_mode()
  let stdio = @mcp.StdioTransport::new()

  // Read and write a byte
  stdio.write("Enter a character: ")
  let byte = @mcp.get_char()
  stdio.write("\nYou entered: ")
  @mcp.put_char(byte)
  stdio.write("\n")

  // Read and write a line
  stdio.write("Enter a line: ")
  let line = try {
    stdio.read_line!()
  } catch {
    err => return println(err.to_string())
  }
  stdio.write("\nYou entered: ")
  stdio.write(line)

  //
  @mcp.restore_terminal()
}
