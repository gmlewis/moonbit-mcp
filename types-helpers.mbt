///|
pub fn raw_audio(self : AudioContent) -> Bytes raise Error {
  @base64.std_decode2bytes(self.data)
}

///|
pub fn raw_data(self : BlobResourceContents) -> Bytes raise Error {
  @base64.std_decode2bytes(self.blob)
}

///|
pub fn raw_image(self : ImageContent) -> Bytes raise Error {
  @base64.std_decode2bytes(self.data)
}
