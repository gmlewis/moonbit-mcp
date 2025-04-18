// AUTO-GENERATED BY cmd/schema-to-types - DO NOT EDIT
// Generated from: https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-03-26/schema.json

///|
pub fn Annotations::new(
  /// Describes who the intended customer of this object or data is.
  ///
  /// It can include multiple entries to indicate content useful for multiple audiences (e.g., `["user", "assistant"]`).
  audience? : Array[Role],
  /// Describes how important this data is for operating the server.
  ///
  /// A value of 1 means "most important," and indicates that the data is
  /// effectively required, while 0 means "least important," and indicates that
  /// the data is entirely optional.
  priority? : Double
) -> Annotations {
  Annotations::{ audience, priority }
}

///|
pub fn AudioContent::new(
  /// Optional annotations for the client.
  annotations? : Annotations,
  /// The base64-encoded audio data.
  data : String,
  /// The MIME type of the audio. Different providers may support different audio types.
  mimeType : String
) -> AudioContent {
  AudioContent::{ annotations, data, mimeType }
}

///|
pub fn BlobResourceContents::new(
  /// A base64-encoded string representing the binary data of the item.
  blob : String,
  /// The MIME type of this resource, if known.
  mimeType? : String,
  /// The URI of this resource.
  uri : String
) -> BlobResourceContents {
  BlobResourceContents::{ blob, mimeType, uri }
}

///|
pub fn CallToolRequestParams::new(
  arguments? : Json,
  name : String
) -> CallToolRequestParams {
  CallToolRequestParams::{ arguments, name }
}

///|
pub fn CallToolRequest::new(params : CallToolRequestParams) -> CallToolRequest {
  CallToolRequest::{ params, }
}

///|
pub fn CallToolResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json,
  content : Array[&CallToolResultContent],
  /// Whether the tool call ended in an error.
  ///
  /// If not set, this is assumed to be false (the call was successful).
  isError? : Bool
) -> CallToolResult {
  CallToolResult::{ _meta, content, isError }
}

///|
pub fn CancelledNotificationParams::new(
  /// An optional string describing the reason for the cancellation. This MAY be logged or presented to the user.
  reason? : String,
  /// The ID of the request to cancel.
  ///
  /// This MUST correspond to the ID of a request previously issued in the same direction.
  requestId : @jsonrpc2.ID
) -> CancelledNotificationParams {
  CancelledNotificationParams::{ reason, requestId }
}

///|
pub fn CancelledNotification::new(
  params : CancelledNotificationParams
) -> CancelledNotification {
  CancelledNotification::{ params, }
}

///|
pub fn ClientCapabilitiesRoots::new(
  /// Whether the client supports notifications for changes to the roots list.
  listChanged? : Bool
) -> ClientCapabilitiesRoots {
  ClientCapabilitiesRoots::{ listChanged, }
}

///|
pub fn ClientCapabilities::new(
  /// Experimental, non-standard capabilities that the client supports.
  experimental? : Json,
  /// Present if the client supports listing roots.
  roots? : ClientCapabilitiesRoots,
  /// Present if the client supports sampling from an LLM.
  sampling? : Json
) -> ClientCapabilities {
  ClientCapabilities::{ experimental, roots, sampling }
}

///|
pub fn CompleteRequestParamsArgument::new(
  /// The name of the argument
  name : String,
  /// The value of the argument to use for completion matching.
  value : String
) -> CompleteRequestParamsArgument {
  CompleteRequestParamsArgument::{ name, value }
}

///|
pub fn CompleteRequestParams::new(
  /// The argument's information
  argument : CompleteRequestParamsArgument,
  ref_ : &CompleteRequestParamsRef
) -> CompleteRequestParams {
  CompleteRequestParams::{ argument, ref_ }
}

///|
pub fn CompleteRequest::new(params : CompleteRequestParams) -> CompleteRequest {
  CompleteRequest::{ params, }
}

///|
pub fn CompleteResultCompletion::new(
  /// Indicates whether there are additional completion options beyond those provided in the current response, even if the exact total is unknown.
  hasMore? : Bool,
  /// The total number of completion options available. This can exceed the number of values actually sent in the response.
  total? : Int64,
  /// An array of completion values. Must not exceed 100 items.
  values : Array[String]
) -> CompleteResultCompletion {
  CompleteResultCompletion::{ hasMore, total, values }
}

///|
pub fn CompleteResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json,
  completion : CompleteResultCompletion
) -> CompleteResult {
  CompleteResult::{ _meta, completion }
}

///|
pub fn CreateMessageRequestParams::new(
  /// A request to include context from one or more MCP servers (including the caller), to be attached to the prompt. The client MAY ignore this request.
  includeContext? : IncludeContext,
  /// The maximum number of tokens to sample, as requested by the server. The client MAY choose to sample fewer tokens than requested.
  maxTokens : Int64,
  messages : Array[SamplingMessage],
  /// Optional metadata to pass through to the LLM provider. The format of this metadata is provider-specific.
  metadata? : Json,
  /// The server's preferences for which model to select. The client MAY ignore these preferences.
  modelPreferences? : ModelPreferences,
  stopSequences? : Array[String],
  /// An optional system prompt the server wants to use for sampling. The client MAY modify or omit this prompt.
  systemPrompt? : String,
  temperature? : Double
) -> CreateMessageRequestParams {
  CreateMessageRequestParams::{
    includeContext,
    maxTokens,
    messages,
    metadata,
    modelPreferences,
    stopSequences,
    systemPrompt,
    temperature,
  }
}

///|
pub fn CreateMessageRequest::new(
  params : CreateMessageRequestParams
) -> CreateMessageRequest {
  CreateMessageRequest::{ params, }
}

///|
pub fn CreateMessageResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json,
  content : &CreateMessageResultContent,
  /// The name of the model that generated the message.
  model : String,
  role : Role,
  /// The reason why sampling stopped, if known.
  stopReason? : String
) -> CreateMessageResult {
  CreateMessageResult::{ _meta, content, model, role, stopReason }
}

///|
pub fn Cursor::new() -> Cursor {
  Cursor::{  }
}

///|
pub fn EmbeddedResource::new(
  /// Optional annotations for the client.
  annotations? : Annotations,
  resource : &EmbeddedResourceResource
) -> EmbeddedResource {
  EmbeddedResource::{ annotations, resource }
}

///|
pub fn GetPromptRequestParams::new(
  /// Arguments to use for templating the prompt.
  arguments? : Json,
  /// The name of the prompt or prompt template.
  name : String
) -> GetPromptRequestParams {
  GetPromptRequestParams::{ arguments, name }
}

///|
pub fn GetPromptRequest::new(
  params : GetPromptRequestParams
) -> GetPromptRequest {
  GetPromptRequest::{ params, }
}

///|
pub fn GetPromptResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json,
  /// An optional description for the prompt.
  description? : String,
  messages : Array[PromptMessage]
) -> GetPromptResult {
  GetPromptResult::{ _meta, description, messages }
}

///|
pub fn ImageContent::new(
  /// Optional annotations for the client.
  annotations? : Annotations,
  /// The base64-encoded image data.
  data : String,
  /// The MIME type of the image. Different providers may support different image types.
  mimeType : String
) -> ImageContent {
  ImageContent::{ annotations, data, mimeType }
}

///|
pub fn Implementation::new(name : String, version : String) -> Implementation {
  Implementation::{ name, version }
}

///|
pub fn InitializeRequestParams::new(
  capabilities : ClientCapabilities,
  clientInfo : Implementation,
  /// The latest version of the Model Context Protocol that the client supports. The client MAY decide to support older versions as well.
  protocolVersion : String
) -> InitializeRequestParams {
  InitializeRequestParams::{ capabilities, clientInfo, protocolVersion }
}

///|
pub fn InitializeRequest::new(
  params : InitializeRequestParams
) -> InitializeRequest {
  InitializeRequest::{ params, }
}

///|
pub fn InitializeResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json,
  capabilities : ServerCapabilities,
  /// Instructions describing how to use the server and its features.
  ///
  /// This can be used by clients to improve the LLM's understanding of available tools, resources, etc. It can be thought of like a "hint" to the model. For example, this information MAY be added to the system prompt.
  instructions? : String,
  /// The version of the Model Context Protocol that the server wants to use. This may not match the version that the client requested. If the client cannot support this version, it MUST disconnect.
  protocolVersion : String,
  serverInfo : Implementation
) -> InitializeResult {
  InitializeResult::{
    _meta,
    capabilities,
    instructions,
    protocolVersion,
    serverInfo,
  }
}

///|
pub fn InitializedNotificationParams::new(
  /// This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.
  _meta? : Json
) -> InitializedNotificationParams {
  InitializedNotificationParams::{ _meta, }
}

///|
pub fn InitializedNotification::new(
  params? : InitializedNotificationParams
) -> InitializedNotification {
  InitializedNotification::{ params, }
}

///|
pub fn ListPromptsRequestParams::new(
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor? : String
) -> ListPromptsRequestParams {
  ListPromptsRequestParams::{ cursor, }
}

///|
pub fn ListPromptsRequest::new(
  params? : ListPromptsRequestParams
) -> ListPromptsRequest {
  ListPromptsRequest::{ params, }
}

///|
pub fn ListPromptsResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json,
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor? : String,
  prompts : Array[Prompt]
) -> ListPromptsResult {
  ListPromptsResult::{ _meta, nextCursor, prompts }
}

///|
pub fn ListResourceTemplatesRequestParams::new(
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor? : String
) -> ListResourceTemplatesRequestParams {
  ListResourceTemplatesRequestParams::{ cursor, }
}

///|
pub fn ListResourceTemplatesRequest::new(
  params? : ListResourceTemplatesRequestParams
) -> ListResourceTemplatesRequest {
  ListResourceTemplatesRequest::{ params, }
}

///|
pub fn ListResourceTemplatesResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json,
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor? : String,
  resourceTemplates : Array[ResourceTemplate]
) -> ListResourceTemplatesResult {
  ListResourceTemplatesResult::{ _meta, nextCursor, resourceTemplates }
}

///|
pub fn ListResourcesRequestParams::new(
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor? : String
) -> ListResourcesRequestParams {
  ListResourcesRequestParams::{ cursor, }
}

///|
pub fn ListResourcesRequest::new(
  params? : ListResourcesRequestParams
) -> ListResourcesRequest {
  ListResourcesRequest::{ params, }
}

///|
pub fn ListResourcesResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json,
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor? : String,
  resources : Array[Resource]
) -> ListResourcesResult {
  ListResourcesResult::{ _meta, nextCursor, resources }
}

///|
pub fn ListRootsRequestParams_meta::new(
  /// If specified, the caller is requesting out-of-band progress notifications for this request (as represented by notifications/progress). The value of this parameter is an opaque token that will be attached to any subsequent notifications. The receiver is not obligated to provide these notifications.
  progressToken? : ProgressToken
) -> ListRootsRequestParams_meta {
  ListRootsRequestParams_meta::{ progressToken, }
}

///|
pub fn ListRootsRequestParams::new(
  _meta? : ListRootsRequestParams_meta
) -> ListRootsRequestParams {
  ListRootsRequestParams::{ _meta, }
}

///|
pub fn ListRootsRequest::new(
  params? : ListRootsRequestParams
) -> ListRootsRequest {
  ListRootsRequest::{ params, }
}

///|
pub fn ListRootsResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json,
  roots : Array[Root]
) -> ListRootsResult {
  ListRootsResult::{ _meta, roots }
}

///|
pub fn ListToolsRequestParams::new(
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor? : String
) -> ListToolsRequestParams {
  ListToolsRequestParams::{ cursor, }
}

///|
pub fn ListToolsRequest::new(
  params? : ListToolsRequestParams
) -> ListToolsRequest {
  ListToolsRequest::{ params, }
}

///|
pub fn ListToolsResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json,
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor? : String,
  tools : Array[Tool]
) -> ListToolsResult {
  ListToolsResult::{ _meta, nextCursor, tools }
}

///|
pub fn LoggingMessageNotificationParams::new(
  /// The data to be logged, such as a string message or an object. Any JSON serializable type is allowed here.
  data : Json,
  /// The severity of this log message.
  level : LoggingLevel,
  /// An optional name of the logger issuing this message.
  logger? : String
) -> LoggingMessageNotificationParams {
  LoggingMessageNotificationParams::{ data, level, logger }
}

///|
pub fn LoggingMessageNotification::new(
  params : LoggingMessageNotificationParams
) -> LoggingMessageNotification {
  LoggingMessageNotification::{ params, }
}

///|
pub fn ModelHint::new(
  /// A hint for a model name.
  ///
  /// The client SHOULD treat this as a substring of a model name; for example:
  ///  - `claude-3-5-sonnet` should match `claude-3-5-sonnet-20241022`
  ///  - `sonnet` should match `claude-3-5-sonnet-20241022`, `claude-3-sonnet-20240229`, etc.
  ///  - `claude` should match any Claude model
  ///
  /// The client MAY also map the string to a different provider's model name or a different model family, as long as it fills a similar niche; for example:
  ///  - `gemini-1.5-flash` could match `claude-3-haiku-20240307`
  name? : String
) -> ModelHint {
  ModelHint::{ name, }
}

///|
pub fn ModelPreferences::new(
  /// How much to prioritize cost when selecting a model. A value of 0 means cost
  /// is not important, while a value of 1 means cost is the most important
  /// factor.
  costPriority? : Double,
  /// Optional hints to use for model selection.
  ///
  /// If multiple hints are specified, the client MUST evaluate them in order
  /// (such that the first match is taken).
  ///
  /// The client SHOULD prioritize these hints over the numeric priorities, but
  /// MAY still use the priorities to select from ambiguous matches.
  hints? : Array[ModelHint],
  /// How much to prioritize intelligence and capabilities when selecting a
  /// model. A value of 0 means intelligence is not important, while a value of 1
  /// means intelligence is the most important factor.
  intelligencePriority? : Double,
  /// How much to prioritize sampling speed (latency) when selecting a model. A
  /// value of 0 means speed is not important, while a value of 1 means speed is
  /// the most important factor.
  speedPriority? : Double
) -> ModelPreferences {
  ModelPreferences::{ costPriority, hints, intelligencePriority, speedPriority }
}

///|
pub fn NotificationParams::new(
  /// This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.
  _meta? : Json
) -> NotificationParams {
  NotificationParams::{ _meta, }
}

///|
pub fn Notification::new(
  method_ : String,
  params? : NotificationParams
) -> Notification {
  Notification::{ method_, params }
}

///|
pub fn PaginatedRequestParams::new(
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor? : String
) -> PaginatedRequestParams {
  PaginatedRequestParams::{ cursor, }
}

///|
pub fn PaginatedRequest::new(
  method_ : String,
  params? : PaginatedRequestParams
) -> PaginatedRequest {
  PaginatedRequest::{ method_, params }
}

///|
pub fn PaginatedResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json,
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor? : String
) -> PaginatedResult {
  PaginatedResult::{ _meta, nextCursor }
}

///|
pub fn PingRequestParams_meta::new(
  /// If specified, the caller is requesting out-of-band progress notifications for this request (as represented by notifications/progress). The value of this parameter is an opaque token that will be attached to any subsequent notifications. The receiver is not obligated to provide these notifications.
  progressToken? : ProgressToken
) -> PingRequestParams_meta {
  PingRequestParams_meta::{ progressToken, }
}

///|
pub fn PingRequestParams::new(
  _meta? : PingRequestParams_meta
) -> PingRequestParams {
  PingRequestParams::{ _meta, }
}

///|
pub fn PingRequest::new(params? : PingRequestParams) -> PingRequest {
  PingRequest::{ params, }
}

///|
pub fn ProgressNotificationParams::new(
  /// An optional message describing the current progress.
  message? : String,
  /// The progress thus far. This should increase every time progress is made, even if the total is unknown.
  progress : Double,
  /// The progress token which was given in the initial request, used to associate this notification with the request that is proceeding.
  progressToken : ProgressToken,
  /// Total number of items to process (or total progress required), if known.
  total? : Double
) -> ProgressNotificationParams {
  ProgressNotificationParams::{ message, progress, progressToken, total }
}

///|
pub fn ProgressNotification::new(
  params : ProgressNotificationParams
) -> ProgressNotification {
  ProgressNotification::{ params, }
}

///|
pub fn ProgressToken::new() -> ProgressToken {
  ProgressToken::{  }
}

///|
pub fn Prompt::new(
  /// A list of arguments to use for templating the prompt.
  arguments? : Array[PromptArgument],
  /// An optional description of what this prompt provides
  description? : String,
  /// The name of the prompt or prompt template.
  name : String
) -> Prompt {
  Prompt::{ arguments, description, name }
}

///|
pub fn PromptArgument::new(
  /// A human-readable description of the argument.
  description? : String,
  /// The name of the argument.
  name : String,
  /// Whether this argument must be provided.
  required? : Bool
) -> PromptArgument {
  PromptArgument::{ description, name, required }
}

///|
pub fn PromptListChangedNotificationParams::new(
  /// This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.
  _meta? : Json
) -> PromptListChangedNotificationParams {
  PromptListChangedNotificationParams::{ _meta, }
}

///|
pub fn PromptListChangedNotification::new(
  params? : PromptListChangedNotificationParams
) -> PromptListChangedNotification {
  PromptListChangedNotification::{ params, }
}

///|
pub fn PromptMessage::new(
  content : &PromptMessageContent,
  role : Role
) -> PromptMessage {
  PromptMessage::{ content, role }
}

///|
pub fn PromptReference::new(
  /// The name of the prompt or prompt template
  name : String
) -> PromptReference {
  PromptReference::{ name, }
}

///|
pub fn ReadResourceRequestParams::new(
  /// The URI of the resource to read. The URI can use any protocol; it is up to the server how to interpret it.
  uri : String
) -> ReadResourceRequestParams {
  ReadResourceRequestParams::{ uri, }
}

///|
pub fn ReadResourceRequest::new(
  params : ReadResourceRequestParams
) -> ReadResourceRequest {
  ReadResourceRequest::{ params, }
}

///|
pub fn ReadResourceResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json,
  contents : Array[&ReadResourceResultContents]
) -> ReadResourceResult {
  ReadResourceResult::{ _meta, contents }
}

///|
pub fn RequestParams_meta::new(
  /// If specified, the caller is requesting out-of-band progress notifications for this request (as represented by notifications/progress). The value of this parameter is an opaque token that will be attached to any subsequent notifications. The receiver is not obligated to provide these notifications.
  progressToken? : ProgressToken
) -> RequestParams_meta {
  RequestParams_meta::{ progressToken, }
}

///|
pub fn RequestParams::new(_meta? : RequestParams_meta) -> RequestParams {
  RequestParams::{ _meta, }
}

///|
pub fn Request::new(method_ : String, params? : RequestParams) -> Request {
  Request::{ method_, params }
}

///|
pub fn Resource::new(
  /// Optional annotations for the client.
  annotations? : Annotations,
  /// A description of what this resource represents.
  ///
  /// This can be used by clients to improve the LLM's understanding of available resources. It can be thought of like a "hint" to the model.
  description? : String,
  /// The MIME type of this resource, if known.
  mimeType? : String,
  /// A human-readable name for this resource.
  ///
  /// This can be used by clients to populate UI elements.
  name : String,
  /// The size of the raw resource content, in bytes (i.e., before base64 encoding or any tokenization), if known.
  ///
  /// This can be used by Hosts to display file sizes and estimate context window usage.
  size? : Int64,
  /// The URI of this resource.
  uri : String
) -> Resource {
  Resource::{ annotations, description, mimeType, name, size, uri }
}

///|
pub fn ResourceContents::new(
  /// The MIME type of this resource, if known.
  mimeType? : String,
  /// The URI of this resource.
  uri : String
) -> ResourceContents {
  ResourceContents::{ mimeType, uri }
}

///|
pub fn ResourceListChangedNotificationParams::new(
  /// This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.
  _meta? : Json
) -> ResourceListChangedNotificationParams {
  ResourceListChangedNotificationParams::{ _meta, }
}

///|
pub fn ResourceListChangedNotification::new(
  params? : ResourceListChangedNotificationParams
) -> ResourceListChangedNotification {
  ResourceListChangedNotification::{ params, }
}

///|
pub fn ResourceReference::new(
  /// The URI or URI template of the resource.
  uri : String
) -> ResourceReference {
  ResourceReference::{ uri, }
}

///|
pub fn ResourceTemplate::new(
  /// Optional annotations for the client.
  annotations? : Annotations,
  /// A description of what this template is for.
  ///
  /// This can be used by clients to improve the LLM's understanding of available resources. It can be thought of like a "hint" to the model.
  description? : String,
  /// The MIME type for all resources that match this template. This should only be included if all resources matching this template have the same type.
  mimeType? : String,
  /// A human-readable name for the type of resource this template refers to.
  ///
  /// This can be used by clients to populate UI elements.
  name : String,
  /// A URI template (according to RFC 6570) that can be used to construct resource URIs.
  uriTemplate : String
) -> ResourceTemplate {
  ResourceTemplate::{ annotations, description, mimeType, name, uriTemplate }
}

///|
pub fn ResourceUpdatedNotificationParams::new(
  /// The URI of the resource that has been updated. This might be a sub-resource of the one that the client actually subscribed to.
  uri : String
) -> ResourceUpdatedNotificationParams {
  ResourceUpdatedNotificationParams::{ uri, }
}

///|
pub fn ResourceUpdatedNotification::new(
  params : ResourceUpdatedNotificationParams
) -> ResourceUpdatedNotification {
  ResourceUpdatedNotification::{ params, }
}

///|
pub fn CustomResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Json
) -> CustomResult {
  CustomResult::{ _meta, }
}

///|
pub fn Root::new(
  /// An optional name for the root. This can be used to provide a human-readable
  /// identifier for the root, which may be useful for display purposes or for
  /// referencing the root in other parts of the application.
  name? : String,
  /// The URI identifying the root. This *must* start with file:// for now.
  /// This restriction may be relaxed in future versions of the protocol to allow
  /// other URI schemes.
  uri : String
) -> Root {
  Root::{ name, uri }
}

///|
pub fn RootsListChangedNotificationParams::new(
  /// This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.
  _meta? : Json
) -> RootsListChangedNotificationParams {
  RootsListChangedNotificationParams::{ _meta, }
}

///|
pub fn RootsListChangedNotification::new(
  params? : RootsListChangedNotificationParams
) -> RootsListChangedNotification {
  RootsListChangedNotification::{ params, }
}

///|
pub fn SamplingMessage::new(
  content : &SamplingMessageContent,
  role : Role
) -> SamplingMessage {
  SamplingMessage::{ content, role }
}

///|
pub fn ServerCapabilitiesPrompts::new(
  /// Whether this server supports notifications for changes to the prompt list.
  listChanged? : Bool
) -> ServerCapabilitiesPrompts {
  ServerCapabilitiesPrompts::{ listChanged, }
}

///|
pub fn ServerCapabilitiesResources::new(
  /// Whether this server supports notifications for changes to the resource list.
  listChanged? : Bool,
  /// Whether this server supports subscribing to resource updates.
  subscribe? : Bool
) -> ServerCapabilitiesResources {
  ServerCapabilitiesResources::{ listChanged, subscribe }
}

///|
pub fn ServerCapabilitiesTools::new(
  /// Whether this server supports notifications for changes to the tool list.
  listChanged? : Bool
) -> ServerCapabilitiesTools {
  ServerCapabilitiesTools::{ listChanged, }
}

///|
pub fn ServerCapabilities::new(
  /// Present if the server supports argument autocompletion suggestions.
  completions? : Json,
  /// Experimental, non-standard capabilities that the server supports.
  experimental? : Json,
  /// Present if the server supports sending log messages to the client.
  logging? : Json,
  /// Present if the server offers any prompt templates.
  prompts? : ServerCapabilitiesPrompts,
  /// Present if the server offers any resources to read.
  resources? : ServerCapabilitiesResources,
  /// Present if the server offers any tools to call.
  tools? : ServerCapabilitiesTools
) -> ServerCapabilities {
  ServerCapabilities::{
    completions,
    experimental,
    logging,
    prompts,
    resources,
    tools,
  }
}

///|
pub fn SetLevelRequestParams::new(
  /// The level of logging that the client wants to receive from the server. The server should send all logs at this level and higher (i.e., more severe) to the client as notifications/message.
  level : LoggingLevel
) -> SetLevelRequestParams {
  SetLevelRequestParams::{ level, }
}

///|
pub fn SetLevelRequest::new(params : SetLevelRequestParams) -> SetLevelRequest {
  SetLevelRequest::{ params, }
}

///|
pub fn SubscribeRequestParams::new(
  /// The URI of the resource to subscribe to. The URI can use any protocol; it is up to the server how to interpret it.
  uri : String
) -> SubscribeRequestParams {
  SubscribeRequestParams::{ uri, }
}

///|
pub fn SubscribeRequest::new(
  params : SubscribeRequestParams
) -> SubscribeRequest {
  SubscribeRequest::{ params, }
}

///|
pub fn TextContent::new(
  /// Optional annotations for the client.
  annotations? : Annotations,
  /// The text content of the message.
  text : String
) -> TextContent {
  TextContent::{ annotations, text }
}

///|
pub fn TextResourceContents::new(
  /// The MIME type of this resource, if known.
  mimeType? : String,
  /// The text of the item. This must only be set if the item can actually be represented as text (not binary data).
  text : String,
  /// The URI of this resource.
  uri : String
) -> TextResourceContents {
  TextResourceContents::{ mimeType, text, uri }
}

///|
pub fn ToolInputSchema::new(
  properties? : Json,
  required? : Array[String]
) -> ToolInputSchema {
  ToolInputSchema::{ properties, required }
}

///|
pub fn Tool::new(
  /// Optional additional tool information.
  annotations? : ToolAnnotations,
  /// A human-readable description of the tool.
  ///
  /// This can be used by clients to improve the LLM's understanding of available tools. It can be thought of like a "hint" to the model.
  description? : String,
  /// A JSON Schema object defining the expected parameters for the tool.
  inputSchema : ToolInputSchema,
  /// The name of the tool.
  name : String
) -> Tool {
  Tool::{ annotations, description, inputSchema, name }
}

///|
pub fn ToolAnnotations::new(
  /// If true, the tool may perform destructive updates to its environment.
  /// If false, the tool performs only additive updates.
  ///
  /// (This property is meaningful only when `readOnlyHint == false`)
  ///
  /// Default: true
  destructiveHint? : Bool,
  /// If true, calling the tool repeatedly with the same arguments
  /// will have no additional effect on the its environment.
  ///
  /// (This property is meaningful only when `readOnlyHint == false`)
  ///
  /// Default: false
  idempotentHint? : Bool,
  /// If true, this tool may interact with an "open world" of external
  /// entities. If false, the tool's domain of interaction is closed.
  /// For example, the world of a web search tool is open, whereas that
  /// of a memory tool is not.
  ///
  /// Default: true
  openWorldHint? : Bool,
  /// If true, the tool does not modify its environment.
  ///
  /// Default: false
  readOnlyHint? : Bool,
  /// A human-readable title for the tool.
  title? : String
) -> ToolAnnotations {
  ToolAnnotations::{
    destructiveHint,
    idempotentHint,
    openWorldHint,
    readOnlyHint,
    title,
  }
}

///|
pub fn ToolListChangedNotificationParams::new(
  /// This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.
  _meta? : Json
) -> ToolListChangedNotificationParams {
  ToolListChangedNotificationParams::{ _meta, }
}

///|
pub fn ToolListChangedNotification::new(
  params? : ToolListChangedNotificationParams
) -> ToolListChangedNotification {
  ToolListChangedNotification::{ params, }
}

///|
pub fn UnsubscribeRequestParams::new(
  /// The URI of the resource to unsubscribe from.
  uri : String
) -> UnsubscribeRequestParams {
  UnsubscribeRequestParams::{ uri, }
}

///|
pub fn UnsubscribeRequest::new(
  params : UnsubscribeRequestParams
) -> UnsubscribeRequest {
  UnsubscribeRequest::{ params, }
}
