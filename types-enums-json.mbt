///|
pub impl ToJson for CallToolResultContent with to_json(self) {
  match self {
    TextContent(v) => v.to_json()
    ImageContent(v) => v.to_json()
    AudioContent(v) => v.to_json()
    EmbeddedResource(v) => v.to_json()
  }
}

///|
pub impl @json.FromJson for CallToolResultContent with from_json(json, path) {
  let v : Result[TextContent, _] = @json.from_json?(json)
  if v is Ok(v) {
    return TextContent(v)
  }
  let v : Result[ImageContent, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ImageContent(v)
  }
  let v : Result[AudioContent, _] = @json.from_json?(json)
  if v is Ok(v) {
    return AudioContent(v)
  }
  let v : Result[EmbeddedResource, _] = @json.from_json?(json)
  if v is Ok(v) {
    return EmbeddedResource(v)
  }
  raise @json.JsonDecodeError(
    (path, "expected text, image, audio or embedded resource"),
  )
}

///|
pub impl ToJson for ClientNotification with to_json(self) {
  match self {
    CancelledNotification(v) => v.to_json()
    InitializedNotification(v) => v.to_json()
    ProgressNotification(v) => v.to_json()
    RootsListChangedNotification(v) => v.to_json()
  }
}

///|
pub impl @json.FromJson for ClientNotification with from_json(json, path) {
  let v : Result[CancelledNotification, _] = @json.from_json?(json)
  if v is Ok(v) {
    return CancelledNotification(v)
  }
  let v : Result[InitializedNotification, _] = @json.from_json?(json)
  if v is Ok(v) {
    return InitializedNotification(v)
  }
  let v : Result[ProgressNotification, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ProgressNotification(v)
  }
  let v : Result[RootsListChangedNotification, _] = @json.from_json?(json)
  if v is Ok(v) {
    return RootsListChangedNotification(v)
  }
  raise @json.JsonDecodeError((path, "expected client notification"))
}

///|
pub impl ToJson for ClientRequest with to_json(self) {
  match self {
    InitializeRequest(v) => v.to_json()
    PingRequest(v) => v.to_json()
    ListResourcesRequest(v) => v.to_json()
    ReadResourceRequest(v) => v.to_json()
    SubscribeRequest(v) => v.to_json()
    UnsubscribeRequest(v) => v.to_json()
    ListPromptsRequest(v) => v.to_json()
    GetPromptRequest(v) => v.to_json()
    ListToolsRequest(v) => v.to_json()
    CallToolRequest(v) => v.to_json()
    SetLevelRequest(v) => v.to_json()
    CompleteRequest(v) => v.to_json()
  }
}

///|
pub impl @json.FromJson for ClientRequest with from_json(json, path) {
  let v : Result[InitializeRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return InitializeRequest(v)
  }
  let v : Result[PingRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return PingRequest(v)
  }
  let v : Result[ListResourcesRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ListResourcesRequest(v)
  }
  let v : Result[ReadResourceRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ReadResourceRequest(v)
  }
  let v : Result[SubscribeRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return SubscribeRequest(v)
  }
  let v : Result[UnsubscribeRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return UnsubscribeRequest(v)
  }
  let v : Result[ListPromptsRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ListPromptsRequest(v)
  }
  let v : Result[GetPromptRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return GetPromptRequest(v)
  }
  let v : Result[ListToolsRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ListToolsRequest(v)
  }
  let v : Result[CallToolRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return CallToolRequest(v)
  }
  let v : Result[SetLevelRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return SetLevelRequest(v)
  }
  let v : Result[CompleteRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return CompleteRequest(v)
  }
  raise @json.JsonDecodeError((path, "expected client request"))
}

///|
pub impl ToJson for ClientResult with to_json(self) {
  match self {
    CustomResult(v) => v.to_json()
    CreateMessageResult(v) => v.to_json()
    ListRootsResult(v) => v.to_json()
  }
}

///|
pub impl @json.FromJson for ClientResult with from_json(json, path) {
  let v : Result[CustomResult, _] = @json.from_json?(json)
  if v is Ok(v) {
    return CustomResult(v)
  }
  let v : Result[CreateMessageResult, _] = @json.from_json?(json)
  if v is Ok(v) {
    return CreateMessageResult(v)
  }
  let v : Result[ListRootsResult, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ListRootsResult(v)
  }
  raise @json.JsonDecodeError((path, "expected client result"))
}

///|
pub impl ToJson for Role with to_json(self) {
  match self {
    Assistant => "assistant".to_json()
    User => "user".to_json()
  }
}

///|
pub impl @json.FromJson for Role with from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError((path, "expected string"))
  }
  match s {
    "assistant" => Assistant
    "user" => User
    _ => raise @json.JsonDecodeError((path, "expected assistant or user"))
  }
}
