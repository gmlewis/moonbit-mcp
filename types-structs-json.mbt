///|
pub fn AudioContent::new(
  raw_audio : FixedArray[Byte],
  mime_type : String,
  annotations? : Annotations
) -> AudioContent {
  let data = @base64.std_encode2str(raw_audio)
  { annotations, data, mimeType: mime_type }
}

///|
pub fn raw_audio(self : AudioContent) -> Bytes!Error {
  @base64.std_decode2bytes!(self.data)
}

///|
pub fn BlobResourceContents::new(
  raw_data : FixedArray[Byte],
  uri : String,
  mime_type? : String
) -> BlobResourceContents {
  let blob = @base64.std_encode2str(raw_data)
  { blob, mimeType: mime_type, uri }
}

///|
pub fn raw_data(self : BlobResourceContents) -> Bytes!Error {
  @base64.std_decode2bytes!(self.blob)
}

///|
pub fn ImageContent::new(
  raw_image : FixedArray[Byte],
  mime_type : String,
  annotations? : Annotations
) -> ImageContent {
  let data = @base64.std_encode2str(raw_image)
  { annotations, data, mimeType: mime_type }
}

///|
pub fn raw_image(self : ImageContent) -> Bytes!Error {
  @base64.std_decode2bytes!(self.data)
}

// TODO: Any struct with `Int64` needs custom ToJson and FromJson due
// to MoonBit's handling of Int64 as strings.
