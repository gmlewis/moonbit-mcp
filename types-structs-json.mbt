// ///|
// pub impl ToJson for Annotations with to_json(self) {
//   let obj = {}
//   if self.audience is Some(audience) {
//     obj["audience"] = audience.to_json()
//   }
//   if self.priority is Some(priority) {
//     obj["priority"] = priority.to_json()
//   }
//   obj.to_json()
// }

// ///|
// pub impl @json.FromJson for Annotations with from_json(json, path) {
//   guard json is Object(obj) else {
//     raise @json.JsonDecodeError((path, "expected object"))
//   }
//   let audience : Array[Role]? = if obj["audience"] is Some(json) {
//     let v : Result[Array[Role], _] = @json.from_json?(json)
//     if v is Ok(roles) {
//       Some(roles)
//     } else {
//       None
//     }
//   } else {
//     None
//   }
//   let priority = if obj["priority"] is Some(Number(n)) { Some(n) } else { None }
//   { audience, priority }
// }

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

// ///|
// pub impl ToJson for AudioContent with to_json(self) {
//   let obj = {
//     "type": "audio".to_json(),
//     "data": self.data.to_json(),
//     "mimeType": self.mimeType.to_json(),
//   }
//   if self.annotations is Some(annotations) {
//     obj["annotations"] = annotations.to_json()
//   }
//   obj.to_json()
// }

// ///|
// pub impl @json.FromJson for AudioContent with from_json(json, path) {
//   guard json is Object(obj) else {
//     raise @json.JsonDecodeError((path, "expected object"))
//   }
//   match obj {
//     {
//       "type": String("audio"),
//       "data": String(data),
//       "mimeType": String(mime_type),
//       ..
//     } => {
//       let annotations : Annotations? = if obj["annotations"] is Some(json) {
//         let v : Result[Annotations, _] = @json.from_json?(json)
//         if v is Ok(annotations) {
//           Some(annotations)
//         } else {
//           None
//         }
//       } else {
//         None
//       }
//       { annotations, data, mimeType: mime_type }
//     }
//     _ => raise @json.JsonDecodeError((path, "expected type, data and mimeType"))
//   }
// }

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

// ///|
// pub impl ToJson for BlobResourceContents with to_json(self) {
//   let obj = { "blob": self.blob.to_json(), "uri": self.uri.to_json() }
//   if self.mimeType is Some(mime_type) {
//     obj["mimeType"] = mime_type.to_json()
//   }
//   obj.to_json()
// }

// ///|
// pub impl @json.FromJson for BlobResourceContents with from_json(json, path) {
//   guard json is Object(obj) else {
//     raise @json.JsonDecodeError((path, "expected object"))
//   }
//   match obj {
//     { "blob": String(blob), "uri": String(uri), .. } => {
//       let mime_type : String? = if obj["mimeType"] is Some(String(mime_type)) {
//         Some(mime_type)
//       } else {
//         None
//       }
//       { blob, mimeType: mime_type, uri }
//     }
//     _ => raise @json.JsonDecodeError((path, "expected blob, uri and mimeType"))
//   }
// }

///|
// priv type! MessageError String derive(Show, Eq)

// ///|
// pub impl ToJson for CallToolRequestParams with to_json(self) {
//   let obj = { "name": self.name.to_json() }
//   if self.arguments is Some(arguments) {
//     obj["arguments"] = arguments.to_json()
//   }
//   obj.to_json()
// }

// ///|
// pub impl @json.FromJson for CallToolRequestParams with from_json(json, path) {
//   guard json is Object(obj) else {
//     raise @json.JsonDecodeError((path, "expected object"))
//   }
//   match obj {
//     { "name": String(name), .. } => {
//       let arguments : Json? = if obj["arguments"] is Some(json) {
//         Some(json)
//       } else {
//         None
//       }
//       { arguments, name }
//     }
//     _ => raise @json.JsonDecodeError((path, "expected name and arguments"))
//   }
// }
