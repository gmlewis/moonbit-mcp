///|
pub fn raw_audio(self : AudioContent) -> Bytes!Error {
  @base64.std_decode2bytes!(self.data)
}

///|
pub fn raw_data(self : BlobResourceContents) -> Bytes!Error {
  @base64.std_decode2bytes!(self.blob)
}

///|
pub fn raw_image(self : ImageContent) -> Bytes!Error {
  @base64.std_decode2bytes!(self.data)
}

///|
pub fn new_call_tool_text_result(
  annotations? : Annotations,
  text : String
) -> CallToolResultContent {
  CallToolResultContent::TextContent(TextContent::new(annotations?, text))
}

///|
pub fn new_call_tool_error_result(
  annotations? : Annotations,
  text : String
) -> CallToolResult {
  CallToolResult::new(isError=true, [
    CallToolResultContent::TextContent(TextContent::new(annotations?, text)),
  ])
}
