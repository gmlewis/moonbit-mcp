// AUTO-GENERATED BY cmd/schema-to-types - DO NOT EDIT
// Generated from: https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-03-26

////////////////////////////////////////////////////////////////////////////////
// JSON-RPC types
////////////////////////////////////////////////////////////////////////////////

///|
pub fn Request::new(method_ : String, params? : Map[String, Json]) -> Request {
  { method_, params }
}

///|
pub fn Notification::new(
  method_ : String,
  params? : Map[String, Json],
) -> Notification {
  { method_, params }
}

////////////////////////////////////////////////////////////////////////////////
// Empty result
////////////////////////////////////////////////////////////////////////////////

///|
pub fn EmptyResult::new() -> EmptyResult {
  Result_({})
}

////////////////////////////////////////////////////////////////////////////////
// Cancellation
////////////////////////////////////////////////////////////////////////////////

///|
pub fn CancelledNotificationParams::new(
  /// The ID of the request to cancel.
  ///
  /// This MUST correspond to the ID of a request previously issued in the same direction.
  requestId : @jsonrpc2.ID,
  /// An optional string describing the reason for the cancellation. This MAY be logged or presented to the user.
  reason? : String,
) -> CancelledNotificationParams {
  { requestId, reason }
}

///|
pub fn CancelledNotification::new(
  params : CancelledNotificationParams,
) -> CancelledNotification {
  { params, }
}

////////////////////////////////////////////////////////////////////////////////
// Initialization
////////////////////////////////////////////////////////////////////////////////

///|
pub fn InitializeRequestParams::new(
  /// The latest version of the Model Context Protocol that the client supports. The client MAY decide to support older versions as well.
  protocolVersion : String,
  capabilities : ClientCapabilities,
  clientInfo : Implementation,
) -> InitializeRequestParams {
  { protocolVersion, capabilities, clientInfo }
}

///|
pub fn InitializeRequest::new(
  params : InitializeRequestParams,
) -> InitializeRequest {
  { params, }
}

///|
pub fn InitializeResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Map[String, Json],
  /// The version of the Model Context Protocol that the server wants to use. This may not match the version that the client requested. If the client cannot support this version, it MUST disconnect.
  protocolVersion : String,
  capabilities : ServerCapabilities,
  serverInfo : Implementation,
  /// Instructions describing how to use the server and its features.
  ///
  /// This can be used by clients to improve the LLM's understanding of available tools, resources, etc. It can be thought of like a "hint" to the model. For example, this information MAY be added to the system prompt.
  instructions? : String,
) -> InitializeResult {
  { _meta, protocolVersion, capabilities, serverInfo, instructions }
}

///|
pub fn InitializedNotification::new(
  params? : Map[String, Json],
) -> InitializedNotification {
  { params, }
}

///|
pub fn ClientCapabilitiesRoots::new(
  /// Whether the client supports notifications for changes to the roots list.
  listChanged? : Bool,
) -> ClientCapabilitiesRoots {
  { listChanged, }
}

///|
pub fn ClientCapabilities::new(
  /// Experimental, non-standard capabilities that the client supports.
  experimental? : Map[String, Json],
  /// Present if the client supports listing roots.
  roots? : ClientCapabilitiesRoots,
  /// Present if the client supports sampling from an LLM.
  sampling? : Map[String, Json],
) -> ClientCapabilities {
  { experimental, roots, sampling }
}

///|
pub fn ServerCapabilitiesPrompts::new(
  /// Whether this server supports notifications for changes to the prompt list.
  listChanged? : Bool,
) -> ServerCapabilitiesPrompts {
  { listChanged, }
}

///|
pub fn ServerCapabilitiesResources::new(
  /// Whether this server supports notifications for changes to the resource list.
  listChanged? : Bool,
  /// Whether this server supports subscribing to resource updates.
  subscribe? : Bool,
) -> ServerCapabilitiesResources {
  { listChanged, subscribe }
}

///|
pub fn ServerCapabilitiesTools::new(
  /// Whether this server supports notifications for changes to the tool list.
  listChanged? : Bool,
) -> ServerCapabilitiesTools {
  { listChanged, }
}

///|
pub fn ServerCapabilities::new(
  /// Experimental, non-standard capabilities that the server supports.
  experimental? : Map[String, Json],
  /// Present if the server supports sending log messages to the client.
  logging? : Map[String, Json],
  /// Present if the server supports argument autocompletion suggestions.
  completions? : Map[String, Json],
  /// Present if the server offers any prompt templates.
  prompts? : ServerCapabilitiesPrompts,
  /// Present if the server offers any resources to read.
  resources? : ServerCapabilitiesResources,
  /// Present if the server offers any tools to call.
  tools? : ServerCapabilitiesTools,
) -> ServerCapabilities {
  { experimental, logging, completions, prompts, resources, tools }
}

///|
pub fn Implementation::new(name : String, version : String) -> Implementation {
  { name, version }
}

////////////////////////////////////////////////////////////////////////////////
// Ping
////////////////////////////////////////////////////////////////////////////////

///|
pub fn PingRequest::new(params? : Map[String, Json]) -> PingRequest {
  { params, }
}

////////////////////////////////////////////////////////////////////////////////
// Progress notifications
////////////////////////////////////////////////////////////////////////////////

///|
pub fn ProgressNotificationParams::new(
  /// The progress thus far. This should increase every time progress is made, even if the total is unknown.
  progress : Double,
  /// The progress token which was given in the initial request, used to associate this notification with the request that is proceeding.
  progressToken : ProgressToken,
  /// Total number of items to process (or total progress required), if known.
  total? : Double,
  /// An optional message describing the current progress.
  message? : String,
) -> ProgressNotificationParams {
  { progress, progressToken, total, message }
}

///|
pub fn ProgressNotification::new(
  params : ProgressNotificationParams,
) -> ProgressNotification {
  { params, }
}

////////////////////////////////////////////////////////////////////////////////
// Pagination
////////////////////////////////////////////////////////////////////////////////

///|
pub fn PaginatedRequestParams::new(
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor? : String,
) -> PaginatedRequestParams {
  { cursor, }
}

///|
pub fn PaginatedRequest::new(
  method_ : String,
  params? : PaginatedRequestParams,
) -> PaginatedRequest {
  { method_, params }
}

///|
pub fn PaginatedResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Map[String, Json],
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor? : String,
) -> PaginatedResult {
  { _meta, nextCursor }
}

////////////////////////////////////////////////////////////////////////////////
// Resources
////////////////////////////////////////////////////////////////////////////////

///|
pub fn ListResourcesRequestParams::new(
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor? : String,
) -> ListResourcesRequestParams {
  { cursor, }
}

///|
pub fn ListResourcesRequest::new(
  params? : ListResourcesRequestParams,
) -> ListResourcesRequest {
  { params, }
}

///|
pub fn ListResourcesResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Map[String, Json],
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor? : String,
  resources : Array[Resource],
) -> ListResourcesResult {
  { _meta, nextCursor, resources }
}

///|
pub fn ListResourceTemplatesRequestParams::new(
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor? : String,
) -> ListResourceTemplatesRequestParams {
  { cursor, }
}

///|
pub fn ListResourceTemplatesRequest::new(
  params? : ListResourceTemplatesRequestParams,
) -> ListResourceTemplatesRequest {
  { params, }
}

///|
pub fn ListResourceTemplatesResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Map[String, Json],
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor? : String,
  resourceTemplates : Array[ResourceTemplate],
) -> ListResourceTemplatesResult {
  { _meta, nextCursor, resourceTemplates }
}

///|
pub fn ReadResourceRequestParams::new(
  /// The URI of the resource to read. The URI can use any protocol; it is up to the server how to interpret it.
  uri : String,
) -> ReadResourceRequestParams {
  { uri, }
}

///|
pub fn ReadResourceRequest::new(
  params : ReadResourceRequestParams,
) -> ReadResourceRequest {
  { params, }
}

///|
pub fn ReadResourceResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Map[String, Json],
  contents : Array[&ReadResourceResultContents],
) -> ReadResourceResult {
  { _meta, contents }
}

///|
pub fn ResourceListChangedNotification::new(
  params? : Map[String, Json],
) -> ResourceListChangedNotification {
  { params, }
}

///|
pub fn SubscribeRequestParams::new(
  /// The URI of the resource to subscribe to. The URI can use any protocol; it is up to the server how to interpret it.
  uri : String,
) -> SubscribeRequestParams {
  { uri, }
}

///|
pub fn SubscribeRequest::new(
  params : SubscribeRequestParams,
) -> SubscribeRequest {
  { params, }
}

///|
pub fn UnsubscribeRequestParams::new(
  /// The URI of the resource to unsubscribe from.
  uri : String,
) -> UnsubscribeRequestParams {
  { uri, }
}

///|
pub fn UnsubscribeRequest::new(
  params : UnsubscribeRequestParams,
) -> UnsubscribeRequest {
  { params, }
}

///|
pub fn ResourceUpdatedNotificationParams::new(
  /// The URI of the resource that has been updated. This might be a sub-resource of the one that the client actually subscribed to.
  uri : String,
) -> ResourceUpdatedNotificationParams {
  { uri, }
}

///|
pub fn ResourceUpdatedNotification::new(
  params : ResourceUpdatedNotificationParams,
) -> ResourceUpdatedNotification {
  { params, }
}

///|
pub fn Resource::new(
  /// The URI of this resource.
  uri : String,
  /// A human-readable name for this resource.
  ///
  /// This can be used by clients to populate UI elements.
  name : String,
  /// A description of what this resource represents.
  ///
  /// This can be used by clients to improve the LLM's understanding of available resources. It can be thought of like a "hint" to the model.
  description? : String,
  /// The MIME type of this resource, if known.
  mimeType? : String,
  /// Optional annotations for the client.
  annotations? : Annotations,
  /// The size of the raw resource content, in bytes (i.e., before base64 encoding or any tokenization), if known.
  ///
  /// This can be used by Hosts to display file sizes and estimate context window usage.
  size? : Int64,
) -> Resource {
  { uri, name, description, mimeType, annotations, size }
}

///|
pub fn ResourceTemplate::new(
  /// A URI template (according to RFC 6570) that can be used to construct resource URIs.
  uriTemplate : String,
  /// A human-readable name for the type of resource this template refers to.
  ///
  /// This can be used by clients to populate UI elements.
  name : String,
  /// A description of what this template is for.
  ///
  /// This can be used by clients to improve the LLM's understanding of available resources. It can be thought of like a "hint" to the model.
  description? : String,
  /// The MIME type for all resources that match this template. This should only be included if all resources matching this template have the same type.
  mimeType? : String,
  /// Optional annotations for the client.
  annotations? : Annotations,
) -> ResourceTemplate {
  { uriTemplate, name, description, mimeType, annotations }
}

///|
pub fn ResourceContents::new(
  /// The URI of this resource.
  uri : String,
  /// The MIME type of this resource, if known.
  mimeType? : String,
) -> ResourceContents {
  { uri, mimeType }
}

///|
pub fn TextResourceContents::new(
  /// The MIME type of this resource, if known.
  mimeType? : String,
  /// The URI of this resource.
  uri : String,
  /// The text of the item. This must only be set if the item can actually be represented as text (not binary data).
  text : String,
) -> TextResourceContents {
  { mimeType, uri, text }
}

///|
pub fn BlobResourceContents::new(
  /// The MIME type of this resource, if known.
  mimeType? : String,
  /// The URI of this resource.
  uri : String,
  /// A base64-encoded string representing the binary data of the item.
  blob : String,
) -> BlobResourceContents {
  { mimeType, uri, blob }
}

////////////////////////////////////////////////////////////////////////////////
// Prompts
////////////////////////////////////////////////////////////////////////////////

///|
pub fn ListPromptsRequestParams::new(
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor? : String,
) -> ListPromptsRequestParams {
  { cursor, }
}

///|
pub fn ListPromptsRequest::new(
  params? : ListPromptsRequestParams,
) -> ListPromptsRequest {
  { params, }
}

///|
pub fn ListPromptsResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Map[String, Json],
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor? : String,
  prompts : Array[Prompt],
) -> ListPromptsResult {
  { _meta, nextCursor, prompts }
}

///|
pub fn GetPromptRequestParams::new(
  /// The name of the prompt or prompt template.
  name : String,
  /// Arguments to use for templating the prompt.
  arguments? : Map[String, String],
) -> GetPromptRequestParams {
  { name, arguments }
}

///|
pub fn GetPromptRequest::new(
  params : GetPromptRequestParams,
) -> GetPromptRequest {
  { params, }
}

///|
pub fn GetPromptResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Map[String, Json],
  /// An optional description for the prompt.
  description? : String,
  messages : Array[PromptMessage],
) -> GetPromptResult {
  { _meta, description, messages }
}

///|
pub fn Prompt::new(
  /// The name of the prompt or prompt template.
  name : String,
  /// An optional description of what this prompt provides
  description? : String,
  /// A list of arguments to use for templating the prompt.
  arguments? : Array[PromptArgument],
) -> Prompt {
  { name, description, arguments }
}

///|
pub fn PromptArgument::new(
  /// The name of the argument.
  name : String,
  /// A human-readable description of the argument.
  description? : String,
  /// Whether this argument must be provided.
  required? : Bool,
) -> PromptArgument {
  { name, description, required }
}

///|
pub fn PromptMessage::new(
  role : Role,
  content : &PromptMessageContent,
) -> PromptMessage {
  { role, content }
}

///|
pub fn EmbeddedResource::new(
  resource : &EmbeddedResourceResource,
  /// Optional annotations for the client.
  annotations? : Annotations,
) -> EmbeddedResource {
  { resource, annotations }
}

///|
pub fn PromptListChangedNotification::new(
  params? : Map[String, Json],
) -> PromptListChangedNotification {
  { params, }
}

////////////////////////////////////////////////////////////////////////////////
// Tools
////////////////////////////////////////////////////////////////////////////////

///|
pub fn ListToolsRequestParams::new(
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor? : String,
) -> ListToolsRequestParams {
  { cursor, }
}

///|
pub fn ListToolsRequest::new(
  params? : ListToolsRequestParams,
) -> ListToolsRequest {
  { params, }
}

///|
pub fn ListToolsResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Map[String, Json],
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor? : String,
  tools : Array[Tool],
) -> ListToolsResult {
  { _meta, nextCursor, tools }
}

///|
pub fn CallToolResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Map[String, Json],
  content : Array[&CallToolResultContent],
  /// Whether the tool call ended in an error.
  ///
  /// If not set, this is assumed to be false (the call was successful).
  isError? : Bool,
) -> CallToolResult {
  { _meta, content, isError }
}

///|
pub fn CallToolRequestParams::new(
  name : String,
  arguments? : Map[String, Json],
) -> CallToolRequestParams {
  { name, arguments }
}

///|
pub fn CallToolRequest::new(params : CallToolRequestParams) -> CallToolRequest {
  { params, }
}

///|
pub fn ToolListChangedNotification::new(
  params? : Map[String, Json],
) -> ToolListChangedNotification {
  { params, }
}

///|
pub fn ToolAnnotations::new(
  /// A human-readable title for the tool.
  title? : String,
  /// If true, the tool does not modify its environment.
  ///
  /// Default: false
  readOnlyHint? : Bool,
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
) -> ToolAnnotations {
  { title, readOnlyHint, destructiveHint, idempotentHint, openWorldHint }
}

///|
pub fn ToolInputSchema::new(
  properties? : Map[String, Json],
  required? : Array[String],
) -> ToolInputSchema {
  { properties, required }
}

///|
pub fn Tool::new(
  /// The name of the tool.
  name : String,
  /// A human-readable description of the tool.
  ///
  /// This can be used by clients to improve the LLM's understanding of available tools. It can be thought of like a "hint" to the model.
  description? : String,
  /// A JSON Schema object defining the expected parameters for the tool.
  inputSchema : ToolInputSchema,
  /// Optional additional tool information.
  annotations? : ToolAnnotations,
) -> Tool {
  { name, description, inputSchema, annotations }
}

////////////////////////////////////////////////////////////////////////////////
// Logging
////////////////////////////////////////////////////////////////////////////////

///|
pub fn SetLevelRequestParams::new(
  /// The level of logging that the client wants to receive from the server. The server should send all logs at this level and higher (i.e., more severe) to the client as notifications/message.
  level : LoggingLevel,
) -> SetLevelRequestParams {
  { level, }
}

///|
pub fn SetLevelRequest::new(params : SetLevelRequestParams) -> SetLevelRequest {
  { params, }
}

///|
pub fn LoggingMessageNotificationParams::new(
  /// The severity of this log message.
  level : LoggingLevel,
  /// An optional name of the logger issuing this message.
  logger? : String,
  /// The data to be logged, such as a string message or an object. Any JSON serializable type is allowed here.
  data : Json,
) -> LoggingMessageNotificationParams {
  { level, logger, data }
}

///|
pub fn LoggingMessageNotification::new(
  params : LoggingMessageNotificationParams,
) -> LoggingMessageNotification {
  { params, }
}

////////////////////////////////////////////////////////////////////////////////
// Sampling
////////////////////////////////////////////////////////////////////////////////

///|
pub fn CreateMessageRequestParams::new(
  messages : Array[SamplingMessage],
  /// The server's preferences for which model to select. The client MAY ignore these preferences.
  modelPreferences? : ModelPreferences,
  /// An optional system prompt the server wants to use for sampling. The client MAY modify or omit this prompt.
  systemPrompt? : String,
  /// A request to include context from one or more MCP servers (including the caller), to be attached to the prompt. The client MAY ignore this request.
  includeContext? : IncludeContext,
  temperature? : Double,
  /// The maximum number of tokens to sample, as requested by the server. The client MAY choose to sample fewer tokens than requested.
  maxTokens : Int64,
  stopSequences? : Array[String],
  /// Optional metadata to pass through to the LLM provider. The format of this metadata is provider-specific.
  metadata? : Map[String, Json],
) -> CreateMessageRequestParams {
  {
    messages,
    modelPreferences,
    systemPrompt,
    includeContext,
    temperature,
    maxTokens,
    stopSequences,
    metadata,
  }
}

///|
pub fn CreateMessageRequest::new(
  params : CreateMessageRequestParams,
) -> CreateMessageRequest {
  { params, }
}

///|
pub fn CreateMessageResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Map[String, Json],
  content : &CreateMessageResultContent,
  role : Role,
  /// The name of the model that generated the message.
  model : String,
  /// The reason why sampling stopped, if known.
  stopReason? : String,
) -> CreateMessageResult {
  { _meta, content, role, model, stopReason }
}

///|
pub fn SamplingMessage::new(
  role : Role,
  content : &SamplingMessageContent,
) -> SamplingMessage {
  { role, content }
}

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
  priority? : Double,
) -> Annotations {
  { audience, priority }
}

///|
pub fn TextContent::new(
  /// The text content of the message.
  text : String,
  /// Optional annotations for the client.
  annotations? : Annotations,
) -> TextContent {
  { text, annotations }
}

///|
pub fn ImageContent::new(
  /// The base64-encoded image data.
  data : String,
  /// The MIME type of the image. Different providers may support different image types.
  mimeType : String,
  /// Optional annotations for the client.
  annotations? : Annotations,
) -> ImageContent {
  { data, mimeType, annotations }
}

///|
pub fn AudioContent::new(
  /// The base64-encoded audio data.
  data : String,
  /// The MIME type of the audio. Different providers may support different audio types.
  mimeType : String,
  /// Optional annotations for the client.
  annotations? : Annotations,
) -> AudioContent {
  { data, mimeType, annotations }
}

///|
pub fn ModelPreferences::new(
  /// Optional hints to use for model selection.
  ///
  /// If multiple hints are specified, the client MUST evaluate them in order
  /// (such that the first match is taken).
  ///
  /// The client SHOULD prioritize these hints over the numeric priorities, but
  /// MAY still use the priorities to select from ambiguous matches.
  hints? : Array[ModelHint],
  /// How much to prioritize cost when selecting a model. A value of 0 means cost
  /// is not important, while a value of 1 means cost is the most important
  /// factor.
  costPriority? : Double,
  /// How much to prioritize sampling speed (latency) when selecting a model. A
  /// value of 0 means speed is not important, while a value of 1 means speed is
  /// the most important factor.
  speedPriority? : Double,
  /// How much to prioritize intelligence and capabilities when selecting a
  /// model. A value of 0 means intelligence is not important, while a value of 1
  /// means intelligence is the most important factor.
  intelligencePriority? : Double,
) -> ModelPreferences {
  { hints, costPriority, speedPriority, intelligencePriority }
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
  name? : String,
) -> ModelHint {
  { name, }
}

////////////////////////////////////////////////////////////////////////////////
// Autocomplete
////////////////////////////////////////////////////////////////////////////////

///|
pub fn CompleteRequestParamsArgument::new(
  /// The name of the argument
  name : String,
  /// The value of the argument to use for completion matching.
  value : String,
) -> CompleteRequestParamsArgument {
  { name, value }
}

///|
pub fn CompleteRequestParams::new(
  ref_ : &CompleteRequestParamsRef,
  /// The argument's information
  argument : CompleteRequestParamsArgument,
) -> CompleteRequestParams {
  { ref_, argument }
}

///|
pub fn CompleteRequest::new(params : CompleteRequestParams) -> CompleteRequest {
  { params, }
}

///|
pub fn CompleteResultCompletion::new(
  /// An array of completion values. Must not exceed 100 items.
  values : Array[String],
  /// The total number of completion options available. This can exceed the number of values actually sent in the response.
  total? : Int64,
  /// Indicates whether there are additional completion options beyond those provided in the current response, even if the exact total is unknown.
  hasMore? : Bool,
) -> CompleteResultCompletion {
  { values, total, hasMore }
}

///|
pub fn CompleteResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Map[String, Json],
  completion : CompleteResultCompletion,
) -> CompleteResult {
  { _meta, completion }
}

///|
pub fn ResourceReference::new(
  /// The URI or URI template of the resource.
  uri : String,
) -> ResourceReference {
  { uri, }
}

///|
pub fn PromptReference::new(
  /// The name of the prompt or prompt template
  name : String,
) -> PromptReference {
  { name, }
}

////////////////////////////////////////////////////////////////////////////////
// Roots
////////////////////////////////////////////////////////////////////////////////

///|
pub fn ListRootsRequest::new(params? : Map[String, Json]) -> ListRootsRequest {
  { params, }
}

///|
pub fn ListRootsResult::new(
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta? : Map[String, Json],
  roots : Array[Root],
) -> ListRootsResult {
  { _meta, roots }
}

///|
pub fn Root::new(
  /// The URI identifying the root. This *must* start with file:// for now.
  /// This restriction may be relaxed in future versions of the protocol to allow
  /// other URI schemes.
  uri : String,
  /// An optional name for the root. This can be used to provide a human-readable
  /// identifier for the root, which may be useful for display purposes or for
  /// referencing the root in other parts of the application.
  name? : String,
) -> Root {
  { uri, name }
}

///|
pub fn RootsListChangedNotification::new(
  params? : Map[String, Json],
) -> RootsListChangedNotification {
  { params, }
}

////////////////////////////////////////////////////////////////////////////////
// Client messages
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Server messages
////////////////////////////////////////////////////////////////////////////////
