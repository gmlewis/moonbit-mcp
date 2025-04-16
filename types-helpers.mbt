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

// TODO: Any struct with `Int64` needs custom ToJson and FromJson due
// to MoonBit's handling of Int64 as strings.
