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
pub impl ToJson for CompleteRequestParamsRef with to_json(self) {
  match self {
    PromptReference(v) => v.to_json()
    ResourceReference(v) => v.to_json()
  }
}

///|
pub impl @json.FromJson for CompleteRequestParamsRef with from_json(json, path) {
  let v : Result[PromptReference, _] = @json.from_json?(json)
  if v is Ok(v) {
    return PromptReference(v)
  }
  let v : Result[ResourceReference, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ResourceReference(v)
  }
  raise @json.JsonDecodeError((path, "expected prompt or resource reference"))
}

///|
pub impl ToJson for IncludeContext with to_json(self) {
  match self {
    AllServers => "allServers".to_json()
    None => "none".to_json()
    ThisServer => "thisServer".to_json()
  }
}

///|
pub impl @json.FromJson for IncludeContext with from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError((path, "expected string"))
  }
  match s {
    "allServers" => AllServers
    "none" => None
    "thisServer" => ThisServer
    _ =>
      raise @json.JsonDecodeError(
        (path, "expected allServers, none or thisServer"),
      )
  }
}

///|
pub impl ToJson for CreateMessageResultContent with to_json(self) {
  match self {
    TextContent(v) => v.to_json()
    ImageContent(v) => v.to_json()
    AudioContent(v) => v.to_json()
  }
}

///|
pub impl @json.FromJson for CreateMessageResultContent with from_json(
  json,
  path
) {
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
  raise @json.JsonDecodeError((path, "expected text, image or audio content"))
}

///|
pub impl ToJson for EmbeddedResourceResource with to_json(self) {
  match self {
    TextResourceContents(v) => v.to_json()
    BlobResourceContents(v) => v.to_json()
  }
}

///|
pub impl @json.FromJson for EmbeddedResourceResource with from_json(json, path) {
  let v : Result[TextResourceContents, _] = @json.from_json?(json)
  if v is Ok(v) {
    return TextResourceContents(v)
  }
  let v : Result[BlobResourceContents, _] = @json.from_json?(json)
  if v is Ok(v) {
    return BlobResourceContents(v)
  }
  raise @json.JsonDecodeError((path, "expected text or blob resource"))
}

///|
pub impl ToJson for LoggingLevel with to_json(self) {
  match self {
    Alert => "alert".to_json()
    Critical => "critical".to_json()
    Debug => "debug".to_json()
    Emergency => "emergency".to_json()
    Error => "error".to_json()
    Info => "info".to_json()
    Notice => "notice".to_json()
    Warning => "warning".to_json()
  }
}

///|
pub impl @json.FromJson for LoggingLevel with from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError((path, "expected string"))
  }
  match s {
    "alert" => Alert
    "critical" => Critical
    "debug" => Debug
    "emergency" => Emergency
    "error" => Error
    "info" => Info
    "notice" => Notice
    "warning" => Warning
    _ =>
      raise @json.JsonDecodeError(
        (
          path, "expected alert, critical, debug, emergency, error, info, notice or warning",
        ),
      )
  }
}

///|
pub impl ToJson for PromptMessageContent with to_json(self) {
  match self {
    TextContent(v) => v.to_json()
    ImageContent(v) => v.to_json()
    AudioContent(v) => v.to_json()
    EmbeddedResource(v) => v.to_json()
  }
}

///|
pub impl @json.FromJson for PromptMessageContent with from_json(json, path) {
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
pub impl ToJson for ReadResourceResultContents with to_json(self) {
  match self {
    TextResourceContents(v) => v.to_json()
    BlobResourceContents(v) => v.to_json()
  }
}

///|
pub impl @json.FromJson for ReadResourceResultContents with from_json(
  json,
  path
) {
  let v : Result[TextResourceContents, _] = @json.from_json?(json)
  if v is Ok(v) {
    return TextResourceContents(v)
  }
  let v : Result[BlobResourceContents, _] = @json.from_json?(json)
  if v is Ok(v) {
    return BlobResourceContents(v)
  }
  raise @json.JsonDecodeError((path, "expected text or blob resource"))
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

///|
pub impl ToJson for SamplingMessageContent with to_json(self) {
  match self {
    TextContent(v) => v.to_json()
    ImageContent(v) => v.to_json()
    AudioContent(v) => v.to_json()
  }
}

///|
pub impl @json.FromJson for SamplingMessageContent with from_json(json, path) {
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
  raise @json.JsonDecodeError((path, "expected text, image or audio content"))
}

///|
pub impl ToJson for ServerNotification with to_json(self) {
  match self {
    CancelledNotification(v) => v.to_json()
    ProgressNotification(v) => v.to_json()
    ResourceListChangedNotification(v) => v.to_json()
    ResourceUpdatedNotification(v) => v.to_json()
    PromptListChangedNotification(v) => v.to_json()
    ToolListChangedNotification(v) => v.to_json()
    LoggingMessageNotification(v) => v.to_json()
  }
}

///|
pub impl @json.FromJson for ServerNotification with from_json(json, path) {
  let v : Result[CancelledNotification, _] = @json.from_json?(json)
  if v is Ok(v) {
    return CancelledNotification(v)
  }
  let v : Result[ProgressNotification, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ProgressNotification(v)
  }
  let v : Result[ResourceListChangedNotification, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ResourceListChangedNotification(v)
  }
  let v : Result[ResourceUpdatedNotification, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ResourceUpdatedNotification(v)
  }
  let v : Result[PromptListChangedNotification, _] = @json.from_json?(json)
  if v is Ok(v) {
    return PromptListChangedNotification(v)
  }
  let v : Result[ToolListChangedNotification, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ToolListChangedNotification(v)
  }
  let v : Result[LoggingMessageNotification, _] = @json.from_json?(json)
  if v is Ok(v) {
    return LoggingMessageNotification(v)
  }
  raise @json.JsonDecodeError((path, "expected server notification"))
}

///|
pub impl ToJson for ServerRequest with to_json(self) {
  match self {
    PingRequest(v) => v.to_json()
    CreateMessageRequest(v) => v.to_json()
    ListRootsRequest(v) => v.to_json()
  }
}

///|
pub impl @json.FromJson for ServerRequest with from_json(json, path) {
  let v : Result[PingRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return PingRequest(v)
  }
  let v : Result[CreateMessageRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return CreateMessageRequest(v)
  }
  let v : Result[ListRootsRequest, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ListRootsRequest(v)
  }
  raise @json.JsonDecodeError((path, "expected server request"))
}

///|
pub impl ToJson for ServerResult with to_json(self) {
  match self {
    CustomResult(v) => v.to_json()
    InitializeResult(v) => v.to_json()
    ListResourcesResult(v) => v.to_json()
    ReadResourceResult(v) => v.to_json()
    ListPromptsResult(v) => v.to_json()
    GetPromptResult(v) => v.to_json()
    ListToolsResult(v) => v.to_json()
    CallToolResult(v) => v.to_json()
    CompleteResult(v) => v.to_json()
  }
}

///|
pub impl @json.FromJson for ServerResult with from_json(json, path) {
  let v : Result[InitializeResult, _] = @json.from_json?(json)
  if v is Ok(v) {
    return InitializeResult(v)
  }
  let v : Result[ListResourcesResult, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ListResourcesResult(v)
  }
  let v : Result[ReadResourceResult, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ReadResourceResult(v)
  }
  let v : Result[ListPromptsResult, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ListPromptsResult(v)
  }
  let v : Result[GetPromptResult, _] = @json.from_json?(json)
  if v is Ok(v) {
    return GetPromptResult(v)
  }
  let v : Result[ListToolsResult, _] = @json.from_json?(json)
  if v is Ok(v) {
    return ListToolsResult(v)
  }
  let v : Result[CallToolResult, _] = @json.from_json?(json)
  if v is Ok(v) {
    return CallToolResult(v)
  }
  let v : Result[CompleteResult, _] = @json.from_json?(json)
  if v is Ok(v) {
    return CompleteResult(v)
  }
  let v : Result[CustomResult, _] = @json.from_json?(json)
  if v is Ok(v) {
    return CustomResult(v)
  }
  raise @json.JsonDecodeError((path, "expected server result"))
}
