///|
fn main {
  @mcp.set_raw_mode()

  // Read and write a byte
  @mcp.write("Enter a character: ")
  let byte = @mcp.get_char()
  @mcp.write("\nYou entered: ")
  @mcp.put_char(byte)
  @mcp.write("\n")

  // Read and write a line
  @mcp.write("Enter a line: ")
  let line = try {
    @mcp.read_line!()
  } catch {
    err => return println(err.to_string())
  }
  @mcp.write("\nYou entered: ")
  @mcp.write(line)

  //
  @mcp.restore_terminal()
}
