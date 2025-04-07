///| Annotations: Optional annotations for the client. The client can use annotations to inform how objects are used or displayed
pub(all) struct Annotations {
  /// Describes who the intended customer of this object or data is.
  ///
  /// It can include multiple entries to indicate content useful for multiple audiences (e.g., `["user", "assistant"]`).
  audience : Array[Role]
  /// Describes how important this data is for operating the server.
  ///
  /// A value of 1 means "most important," and indicates that the data is
  /// effectively required, while 0 means "least important," and indicates that
  /// the data is entirely optional.
  priority : Double
} derive(Show, Eq)

///| AudioContent: Audio provided to or from an LLM.
pub(all) struct AudioContent {
  /// Optional annotations for the client.
  annotations : Annotations?
  /// The base64-encoded audio data.
  data : String
  /// The MIME type of the audio. Different providers may support different audio types.
  mimeType : String
  /// JSON-RPC: "type" = "audio"
} derive(Show, Eq)

///|
pub(all) struct BlobResourceContents {
  /// A base64-encoded string representing the binary data of the item.
  blob : String
  /// The MIME type of this resource, if known.
  mimeType : String?
  /// The URI of this resource.
  uri : String
} derive(Show, Eq)

///| CallToolRequest: Used by the client to invoke a tool provided by the server.
pub(all) struct CallToolRequest {
  /// JSON-RPC: "method" = "tools/call"
  params : CallToolRequestParams
} derive(Show, Eq)

///|
pub(all) struct CallToolRequestParams {
  arguments : Json?
  name : String
} derive(Show, Eq)

///| CallToolResult: The server's response to a tool call.
///
/// Any errors that originate from the tool SHOULD be reported inside the result
/// object, with `isError` set to true, _not_ as an MCP protocol-level error
/// response. Otherwise, the LLM would not be able to see that an error occurred
/// and self-correct.
///
/// However, any errors in _finding_ the tool, an error indicating that the
/// server does not support tool calls, or any other exceptional conditions,
/// should be reported as an MCP error response.
pub(all) struct CallToolResult {
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta : Json?
  content : Array[CallToolResultContent] // TextContent | ImageContent | AudioContent | EmbeddedResource
  /// Whether the tool call ended in an error.
  ///
  /// If not set, this is assumed to be false (the call was successful).
  isError : Bool?
} derive(Show, Eq)

///|
pub enum CallToolResultContent {
  TextContent(TextContent)
  ImageContent(ImageContent)
  AudioContent(AudioContent)
  EmbeddedResource(EmbeddedResource)
} derive(Show, Eq)

///| CancelledNotification: This notification can be sent by either side to indicate that it is cancelling a previously-issued request.
///
/// The request SHOULD still be in-flight, but due to communication latency, it is always possible that this notification MAY arrive after the request has already finished.
///
/// This notification indicates that the result will be unused, so any associated processing SHOULD cease.
///
/// A client MUST NOT attempt to cancel its `initialize` request.
pub(all) struct CancelledNotification {
  /// JSON-RPC: "method" = "notifications/cancelled"
  params : CancelledNotificationParams
} derive(Show, Eq)

///|
pub(all) struct CancelledNotificationParams {
  /// An optional string describing the reason for the cancellation. This MAY be logged or presented to the user.
  reason : String?
  /// The ID of the request to cancel.
  ///
  /// This MUST correspond to the ID of a request previously issued in the same direction.
  requestId : RequestId
} derive(Show, Eq)

///| ClientCapabilities: Capabilities a client may support. Known capabilities are defined here, in this schema, but this is not a closed set: any client can define its own, additional capabilities.
pub(all) struct ClientCapabilities {
  /// Experimental, non-standard capabilities that the client supports.
  experimental : Json
  /// Present if the client supports listing roots.
  roots : ClientCapabilitiesRoots
  /// Present if the client supports sampling from an LLM.
  sampling : Json
} derive(Show, Eq)

///| ClientCapabilitiesRoots: Present if the client supports listing roots.
pub(all) struct ClientCapabilitiesRoots {
  /// Whether the client supports notifications for changes to the roots list.
  listChanged : Bool
} derive(Show, Eq)

///|
pub enum ClientNotification {
  CancelledNotification(CancelledNotification)
  InitializedNotification(InitializedNotification)
  ProgressNotification(ProgressNotification)
  RootsListChangedNotification(RootsListChangedNotification)
} derive(Show, Eq)

///|
pub enum ClientRequest {
  InitializeRequest(InitializeRequest)
  PingRequest(PingRequest)
  ListResourcesRequest(ListResourcesRequest)
  ReadResourceRequest(ReadResourceRequest)
  SubscribeRequest(SubscribeRequest)
  UnsubscribeRequest(UnsubscribeRequest)
  ListPromptsRequest(ListPromptsRequest)
  GetPromptRequest(GetPromptRequest)
  ListToolsRequest(ListToolsRequest)
  CallToolRequest(CallToolRequest)
  SetLevelRequest(SetLevelRequest)
  CompleteRequest(CompleteRequest)
} derive(Show, Eq)

///|
pub enum ClientResult {
  Result(Result)
  CreateMessageResult(CreateMessageResult)
  ListRootsResult(ListRootsResult)
} derive(Show, Eq)

///| CompleteRequest: A request from the client to the server, to ask for completion options.
pub(all) struct CompleteRequest {
  /// JSON-RPC: "method" = "completion/complete"
  params : CompleteRequestParams
} derive(Show, Eq)

///|
pub(all) struct CompleteRequestParams {
  /// The argument's information
  argument : CompleteRequestParamsArgument
  ref_ : CompleteRequestParamsRef
} derive(Show, Eq)

///| CompleteRequestParamsArgument: The argument's information
pub(all) struct CompleteRequestParamsArgument {
  /// The name of the argument
  name : String
  /// The value of the argument to use for completion matching.
  value : String
} derive(Show, Eq)

///|
pub enum CompleteRequestParamsRef {
  PromptReference(PromptReference)
  ResourceReference(ResourceReference)
} derive(Show, Eq)

///| CompleteResult: The server's response to a completion/complete request
pub(all) struct CompleteResult {
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta : Json?
  completion : CompleteResultCompletion
} derive(Show, Eq)

///|
pub(all) struct CompleteResultCompletion {
  /// Indicates whether there are additional completion options beyond those provided in the current response, even if the exact total is unknown.
  hasMore : Bool?
  /// The total number of completion options available. This can exceed the number of values actually sent in the response.
  total : Int64?
  /// An array of completion values. Must not exceed 100 items.
  values : Array[String]
} derive(Show, Eq)

///| CreateMessageRequest: A request from the server to sample an LLM via the client. The client has full discretion over which model to select. The client should also inform the user before beginning sampling, to allow them to inspect the request (human in the loop) and decide whether to approve it.
pub(all) struct CreateMessageRequest {
  /// JSON-RPC: "method" = "sampling/createMessage"
  params : CreateMessageRequestParams
} derive(Show, Eq)

///|
pub(all) struct CreateMessageRequestParams {
  /// A request to include context from one or more MCP servers (including the caller), to be attached to the prompt. The client MAY ignore this request.
  includeContext : String?
  /// The maximum number of tokens to sample, as requested by the server. The client MAY choose to sample fewer tokens than requested.
  maxTokens : Int64
  messages : Array[SamplingMessage]
  /// Optional metadata to pass through to the LLM provider. The format of this metadata is provider-specific.
  metadata : Json?
  /// The server's preferences for which model to select. The client MAY ignore these preferences.
  modelPreferences : ModelPreferences?
  stopSequences : Array[String]?
  /// An optional system prompt the server wants to use for sampling. The client MAY modify or omit this prompt.
  systemPrompt : String?
  temperature : Double?
} derive(Show, Eq)

///| CreateMessageResult: The client's response to a sampling/create_message request from the server. The client should inform the user before returning the sampled message, to allow them to inspect the response (human in the loop) and decide whether to allow the server to see it.
pub(all) struct CreateMessageResult {
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta : Json?
  content : CreateMessageResultContent
  /// The name of the model that generated the message.
  model : String
  role : Role
  /// The reason why sampling stopped, if known.
  stopReason : String?
} derive(Show, Eq)

///|
pub enum CreateMessageResultContent {
  TextContent(TextContent)
  ImageContent(ImageContent)
  AudioContent(AudioContent)
} derive(Show, Eq)

///| Cursor: An opaque token used to represent a cursor for pagination.
pub(all) struct Cursor {} derive(Show, Eq)

///| EmbeddedResource: The contents of a resource, embedded into a prompt or tool call result.
///
/// It is up to the client how best to render embedded resources for the benefit
/// of the LLM and/or the user.
pub(all) struct EmbeddedResource {
  /// Optional annotations for the client.
  annotations : Annotations?
  resource : EmbeddedResourceResource
  /// JSON-RPC: "type" = "resource"
} derive(Show, Eq)

///|
pub enum EmbeddedResourceResource {
  TextResourceContents(TextResourceContents)
  BlobResourceContents(BlobResourceContents)
} derive(Show, Eq)

///|
pub(all) struct EmptyResult {} derive(Show, Eq)

///| GetPromptRequest: Used by the client to get a prompt provided by the server.
pub(all) struct GetPromptRequest {
  /// JSON-RPC: "method" = "prompts/get"
  params : GetPromptRequestParams
} derive(Show, Eq)

///|
pub(all) struct GetPromptRequestParams {
  /// Arguments to use for templating the prompt.
  arguments : Json?
  /// The name of the prompt or prompt template.
  name : String
} derive(Show, Eq)

///| GetPromptResult: The server's response to a prompts/get request from the client.
pub(all) struct GetPromptResult {
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta : Json?
  /// An optional description for the prompt.
  description : String?
  messages : Array[PromptMessage]
} derive(Show, Eq)

///| ImageContent: An image provided to or from an LLM.
pub(all) struct ImageContent {
  /// Optional annotations for the client.
  annotations : Annotations?
  /// The base64-encoded image data.
  data : String
  /// The MIME type of the image. Different providers may support different image types.
  mimeType : String
  /// JSON-RPC: "type" = "image"
} derive(Show, Eq)

///| Implementation: Describes the name and version of an MCP implementation.
pub(all) struct Implementation {
  name : String
  version : String
} derive(Show, Eq)

///| InitializeRequest: This request is sent from the client to the server when it first connects, asking it to begin initialization.
pub(all) struct InitializeRequest {
  /// JSON-RPC: "method" = "initialize"
  params : InitializeRequestParams
} derive(Show, Eq)

///|
pub(all) struct InitializeRequestParams {
  capabilities : ClientCapabilities
  clientInfo : Implementation
  /// The latest version of the Model Context Protocol that the client supports. The client MAY decide to support older versions as well.
  protocolVersion : String
} derive(Show, Eq)

///| InitializeResult: After receiving an initialize request from the client, the server sends this response.
pub(all) struct InitializeResult {
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta : Json?
  capabilities : ServerCapabilities
  /// Instructions describing how to use the server and its features.
  ///
  /// This can be used by clients to improve the LLM's understanding of available tools, resources, etc. It can be thought of like a "hint" to the model. For example, this information MAY be added to the system prompt.
  instructions : String?
  /// The version of the Model Context Protocol that the server wants to use. This may not match the version that the client requested. If the client cannot support this version, it MUST disconnect.
  protocolVersion : String
  serverInfo : Implementation
} derive(Show, Eq)

///| InitializedNotification: This notification is sent from the client to the server after initialization has finished.
pub(all) struct InitializedNotification {
  /// JSON-RPC: "method" = "notifications/initialized"
  params : InitializedNotificationParams?
} derive(Show, Eq)

///|
pub(all) struct InitializedNotificationParams {
  /// This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.
  _meta : Json
} derive(Show, Eq)

///| ListPromptsRequest: Sent from the client to request a list of prompts and prompt templates the server has.
pub(all) struct ListPromptsRequest {
  /// JSON-RPC: "method" = "prompts/list"
  params : ListPromptsRequestParams?
} derive(Show, Eq)

///|
pub(all) struct ListPromptsRequestParams {
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor : String
} derive(Show, Eq)

///| ListPromptsResult: The server's response to a prompts/list request from the client.
pub(all) struct ListPromptsResult {
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta : Json?
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor : String?
  prompts : Array[Prompt]
} derive(Show, Eq)

///| ListResourceTemplatesRequest: Sent from the client to request a list of resource templates the server has.
pub(all) struct ListResourceTemplatesRequest {
  /// JSON-RPC: "method" = "resources/templates/list"
  params : ListResourceTemplatesRequestParams?
} derive(Show, Eq)

///|
pub(all) struct ListResourceTemplatesRequestParams {
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor : String
} derive(Show, Eq)

///| ListResourceTemplatesResult: The server's response to a resources/templates/list request from the client.
pub(all) struct ListResourceTemplatesResult {
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta : Json?
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor : String?
  resourceTemplates : Array[ResourceTemplate]
} derive(Show, Eq)

///| ListResourcesRequest: Sent from the client to request a list of resources the server has.
pub(all) struct ListResourcesRequest {
  /// JSON-RPC: "method" = "resources/list"
  params : ListResourcesRequestParams?
} derive(Show, Eq)

///|
pub(all) struct ListResourcesRequestParams {
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor : String
} derive(Show, Eq)

///| ListResourcesResult: The server's response to a resources/list request from the client.
pub(all) struct ListResourcesResult {
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta : Json?
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor : String?
  resources : Array[Resource]
} derive(Show, Eq)

///| ListRootsRequest: Sent from the server to request a list of root URIs from the client. Roots allow
/// servers to ask for specific directories or files to operate on. A common example
/// for roots is providing a set of repositories or directories a server should operate
/// on.
///
/// This request is typically used when the server needs to understand the file system
/// structure or access specific locations that the client has permission to read from.
pub(all) struct ListRootsRequest {
  /// JSON-RPC: "method" = "roots/list"
  params : ListRootsRequestParams?
} derive(Show, Eq)

///|
pub(all) struct ListRootsRequestParams {
  _meta : ListRootsRequestParams_meta
} derive(Show, Eq)

///|
pub(all) struct ListRootsRequestParams_meta {
  /// If specified, the caller is requesting out-of-band progress notifications for this request (as represented by notifications/progress). The value of this parameter is an opaque token that will be attached to any subsequent notifications. The receiver is not obligated to provide these notifications.
  progressToken : ProgressToken
} derive(Show, Eq)

///| ListRootsResult: The client's response to a roots/list request from the server.
/// This result contains an array of Root objects, each representing a root directory
/// or file that the server can operate on.
pub(all) struct ListRootsResult {
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta : Json?
  roots : Array[Root]
} derive(Show, Eq)

///| ListToolsRequest: Sent from the client to request a list of tools the server has.
pub(all) struct ListToolsRequest {
  /// JSON-RPC: "method" = "tools/list"
  params : ListToolsRequestParams?
} derive(Show, Eq)

///|
pub(all) struct ListToolsRequestParams {
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor : String
} derive(Show, Eq)

///| ListToolsResult: The server's response to a tools/list request from the client.
pub(all) struct ListToolsResult {
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta : Json?
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor : String?
  tools : Array[Tool]
} derive(Show, Eq)

///| LoggingLevel: The severity of a log message.
///
/// These map to syslog message severities, as specified in RFC-5424:
/// https://datatracker.ietf.org/doc/html/rfc5424#section-6.2.1
pub(all) struct LoggingLevel {} derive(Show, Eq)

///| LoggingMessageNotification: Notification of a log message passed from server to client. If no logging/setLevel request has been sent from the client, the server MAY decide which messages to send automatically.
pub(all) struct LoggingMessageNotification {
  /// JSON-RPC: "method" = "notifications/message"
  params : LoggingMessageNotificationParams
} derive(Show, Eq)

///|
pub(all) struct LoggingMessageNotificationParams {
  /// The data to be logged, such as a string message or an object. Any JSON serializable type is allowed here.
  data : Json
  /// The severity of this log message.
  level : LoggingLevel
  /// An optional name of the logger issuing this message.
  logger : String?
} derive(Show, Eq)

///| ModelHint: Hints to use for model selection.
///
/// Keys not declared here are currently left unspecified by the spec and are up
/// to the client to interpret.
pub(all) struct ModelHint {
  /// A hint for a model name.
  ///
  /// The client SHOULD treat this as a substring of a model name; for example:
  ///  - `claude-3-5-sonnet` should match `claude-3-5-sonnet-20241022`
  ///  - `sonnet` should match `claude-3-5-sonnet-20241022`, `claude-3-sonnet-20240229`, etc.
  ///  - `claude` should match any Claude model
  ///
  /// The client MAY also map the string to a different provider's model name or a different model family, as long as it fills a similar niche; for example:
  ///  - `gemini-1.5-flash` could match `claude-3-haiku-20240307`
  name : String
} derive(Show, Eq)

///| ModelPreferences: The server's preferences for model selection, requested of the client during sampling.
///
/// Because LLMs can vary along multiple dimensions, choosing the "best" model is
/// rarely straightforward.  Different models excel in different areas—some are
/// faster but less capable, others are more capable but more expensive, and so
/// on. This interface allows servers to express their priorities across multiple
/// dimensions to help clients make an appropriate selection for their use case.
///
/// These preferences are always advisory. The client MAY ignore them. It is also
/// up to the client to decide how to interpret these preferences and how to
/// balance them against other considerations.
pub(all) struct ModelPreferences {
  /// How much to prioritize cost when selecting a model. A value of 0 means cost
  /// is not important, while a value of 1 means cost is the most important
  /// factor.
  costPriority : Double
  /// Optional hints to use for model selection.
  ///
  /// If multiple hints are specified, the client MUST evaluate them in order
  /// (such that the first match is taken).
  ///
  /// The client SHOULD prioritize these hints over the numeric priorities, but
  /// MAY still use the priorities to select from ambiguous matches.
  hints : Array[ModelHint]
  /// How much to prioritize intelligence and capabilities when selecting a
  /// model. A value of 0 means intelligence is not important, while a value of 1
  /// means intelligence is the most important factor.
  intelligencePriority : Double
  /// How much to prioritize sampling speed (latency) when selecting a model. A
  /// value of 0 means speed is not important, while a value of 1 means speed is
  /// the most important factor.
  speedPriority : Double
} derive(Show, Eq)

///|
pub(all) struct Notification {
  method_ : String
  params : NotificationParams?
} derive(Show, Eq)

///|
pub(all) struct NotificationParams {
  /// This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.
  _meta : Json
} derive(Show, Eq)

///|
pub(all) struct PaginatedRequest {
  method_ : String
  params : PaginatedRequestParams?
} derive(Show, Eq)

///|
pub(all) struct PaginatedRequestParams {
  /// An opaque token representing the current pagination position.
  /// If provided, the server should return results starting after this cursor.
  cursor : String
} derive(Show, Eq)

///|
pub(all) struct PaginatedResult {
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta : Json
  /// An opaque token representing the pagination position after the last returned result.
  /// If present, there may be more results available.
  nextCursor : String
} derive(Show, Eq)

///| PingRequest: A ping, issued by either the server or the client, to check that the other party is still alive. The receiver must promptly respond, or else may be disconnected.
pub(all) struct PingRequest {
  /// JSON-RPC: "method" = "ping"
  params : PingRequestParams?
} derive(Show, Eq)

///|
pub(all) struct PingRequestParams {
  _meta : PingRequestParams_meta
} derive(Show, Eq)

///|
pub(all) struct PingRequestParams_meta {
  /// If specified, the caller is requesting out-of-band progress notifications for this request (as represented by notifications/progress). The value of this parameter is an opaque token that will be attached to any subsequent notifications. The receiver is not obligated to provide these notifications.
  progressToken : ProgressToken
} derive(Show, Eq)

///| ProgressNotification: An out-of-band notification used to inform the receiver of a progress update for a long-running request.
pub(all) struct ProgressNotification {
  /// JSON-RPC: "method" = "notifications/progress"
  params : ProgressNotificationParams
} derive(Show, Eq)

///|
pub(all) struct ProgressNotificationParams {
  /// An optional message describing the current progress.
  message : String?
  /// The progress thus far. This should increase every time progress is made, even if the total is unknown.
  progress : Double
  /// The progress token which was given in the initial request, used to associate this notification with the request that is proceeding.
  progressToken : ProgressToken
  /// Total number of items to process (or total progress required), if known.
  total : Double?
} derive(Show, Eq)

///| ProgressToken: A progress token, used to associate progress notifications with the original request.
pub(all) struct ProgressToken {} derive(Show, Eq)

///| Prompt: A prompt or prompt template that the server offers.
pub(all) struct Prompt {
  /// A list of arguments to use for templating the prompt.
  arguments : Array[PromptArgument]?
  /// An optional description of what this prompt provides
  description : String?
  /// The name of the prompt or prompt template.
  name : String
} derive(Show, Eq)

///| PromptArgument: Describes an argument that a prompt can accept.
pub(all) struct PromptArgument {
  /// A human-readable description of the argument.
  description : String?
  /// The name of the argument.
  name : String
  /// Whether this argument must be provided.
  required : Bool?
} derive(Show, Eq)

///| PromptListChangedNotification: An optional notification from the server to the client, informing it that the list of prompts it offers has changed. This may be issued by servers without any previous subscription from the client.
pub(all) struct PromptListChangedNotification {
  /// JSON-RPC: "method" = "notifications/prompts/list_changed"
  params : PromptListChangedNotificationParams?
} derive(Show, Eq)

///|
pub(all) struct PromptListChangedNotificationParams {
  /// This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.
  _meta : Json
} derive(Show, Eq)

///| PromptMessage: Describes a message returned as part of a prompt.
///
/// This is similar to `SamplingMessage`, but also supports the embedding of
/// resources from the MCP server.
pub(all) struct PromptMessage {
  content : PromptMessageContent
  role : Role
} derive(Show, Eq)

///|
pub enum PromptMessageContent {
  TextContent(TextContent)
  ImageContent(ImageContent)
  AudioContent(AudioContent)
  EmbeddedResource(EmbeddedResource)
} derive(Show, Eq)

///| PromptReference: Identifies a prompt.
pub(all) struct PromptReference {
  /// The name of the prompt or prompt template
  name : String
  /// JSON-RPC: "type" = "ref/prompt"
} derive(Show, Eq)

///| ReadResourceRequest: Sent from the client to the server, to read a specific resource URI.
pub(all) struct ReadResourceRequest {
  /// JSON-RPC: "method" = "resources/read"
  params : ReadResourceRequestParams
} derive(Show, Eq)

///|
pub(all) struct ReadResourceRequestParams {
  /// The URI of the resource to read. The URI can use any protocol; it is up to the server how to interpret it.
  uri : String
} derive(Show, Eq)

///| ReadResourceResult: The server's response to a resources/read request from the client.
pub(all) struct ReadResourceResult {
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta : Json?
  contents : Array[ReadResourceResultContents] // TextResourceContents | BlobResourceContents
} derive(Show, Eq)

///|
pub enum ReadResourceResultContents {
  TextResourceContents(TextResourceContents)
  BlobResourceContents(BlobResourceContents)
} derive(Show, Eq)

///|
pub(all) struct Request {
  method_ : String
  params : RequestParams?
} derive(Show, Eq)

///|
pub(all) struct RequestParams {
  _meta : RequestParams_meta
} derive(Show, Eq)

///|
pub(all) struct RequestParams_meta {
  /// If specified, the caller is requesting out-of-band progress notifications for this request (as represented by notifications/progress). The value of this parameter is an opaque token that will be attached to any subsequent notifications. The receiver is not obligated to provide these notifications.
  progressToken : ProgressToken
} derive(Show, Eq)

///| RequestId: A uniquely identifying ID for a request in JSON-RPC.
pub(all) struct RequestId {} derive(Show, Eq)

///| Resource: A known resource that the server is capable of reading.
pub(all) struct Resource {
  /// Optional annotations for the client.
  annotations : Annotations?
  /// A description of what this resource represents.
  ///
  /// This can be used by clients to improve the LLM's understanding of available resources. It can be thought of like a "hint" to the model.
  description : String?
  /// The MIME type of this resource, if known.
  mimeType : String?
  /// A human-readable name for this resource.
  ///
  /// This can be used by clients to populate UI elements.
  name : String
  /// The size of the raw resource content, in bytes (i.e., before base64 encoding or any tokenization), if known.
  ///
  /// This can be used by Hosts to display file sizes and estimate context window usage.
  size : Int64?
  /// The URI of this resource.
  uri : String
} derive(Show, Eq)

///| ResourceContents: The contents of a specific resource or sub-resource.
pub(all) struct ResourceContents {
  /// The MIME type of this resource, if known.
  mimeType : String?
  /// The URI of this resource.
  uri : String
} derive(Show, Eq)

///| ResourceListChangedNotification: An optional notification from the server to the client, informing it that the list of resources it can read from has changed. This may be issued by servers without any previous subscription from the client.
pub(all) struct ResourceListChangedNotification {
  /// JSON-RPC: "method" = "notifications/resources/list_changed"
  params : ResourceListChangedNotificationParams?
} derive(Show, Eq)

///|
pub(all) struct ResourceListChangedNotificationParams {
  /// This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.
  _meta : Json
} derive(Show, Eq)

///| ResourceReference: A reference to a resource or resource template definition.
pub(all) struct ResourceReference {
  /// JSON-RPC: "type" = "ref/resource"
  /// The URI or URI template of the resource.
  uri : String
} derive(Show, Eq)

///| ResourceTemplate: A template description for resources available on the server.
pub(all) struct ResourceTemplate {
  /// Optional annotations for the client.
  annotations : Annotations?
  /// A description of what this template is for.
  ///
  /// This can be used by clients to improve the LLM's understanding of available resources. It can be thought of like a "hint" to the model.
  description : String?
  /// The MIME type for all resources that match this template. This should only be included if all resources matching this template have the same type.
  mimeType : String?
  /// A human-readable name for the type of resource this template refers to.
  ///
  /// This can be used by clients to populate UI elements.
  name : String
  /// A URI template (according to RFC 6570) that can be used to construct resource URIs.
  uriTemplate : String
} derive(Show, Eq)

///| ResourceUpdatedNotification: A notification from the server to the client, informing it that a resource has changed and may need to be read again. This should only be sent if the client previously sent a resources/subscribe request.
pub(all) struct ResourceUpdatedNotification {
  /// JSON-RPC: "method" = "notifications/resources/updated"
  params : ResourceUpdatedNotificationParams
} derive(Show, Eq)

///|
pub(all) struct ResourceUpdatedNotificationParams {
  /// The URI of the resource that has been updated. This might be a sub-resource of the one that the client actually subscribed to.
  uri : String
} derive(Show, Eq)

///|
pub(all) struct Result {
  /// This result property is reserved by the protocol to allow clients and servers to attach additional metadata to their responses.
  _meta : Json
} derive(Show, Eq)

///| Role: The sender or recipient of messages and data in a conversation.
pub(all) struct Role {} derive(Show, Eq)

///| Root: Represents a root directory or file that the server can operate on.
pub(all) struct Root {
  /// An optional name for the root. This can be used to provide a human-readable
  /// identifier for the root, which may be useful for display purposes or for
  /// referencing the root in other parts of the application.
  name : String?
  /// The URI identifying the root. This *must* start with file:// for now.
  /// This restriction may be relaxed in future versions of the protocol to allow
  /// other URI schemes.
  uri : String
} derive(Show, Eq)

///| RootsListChangedNotification: A notification from the client to the server, informing it that the list of roots has changed.
/// This notification should be sent whenever the client adds, removes, or modifies any root.
/// The server should then request an updated list of roots using the ListRootsRequest.
pub(all) struct RootsListChangedNotification {
  /// JSON-RPC: "method" = "notifications/roots/list_changed"
  params : RootsListChangedNotificationParams?
} derive(Show, Eq)

///|
pub(all) struct RootsListChangedNotificationParams {
  /// This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.
  _meta : Json
} derive(Show, Eq)

///| SamplingMessage: Describes a message issued to or received from an LLM API.
pub(all) struct SamplingMessage {
  content : SamplingMessageContent
  role : Role
} derive(Show, Eq)

///|
pub enum SamplingMessageContent {
  TextContent(TextContent)
  ImageContent(ImageContent)
  AudioContent(AudioContent)
} derive(Show, Eq)

///| ServerCapabilities: Capabilities that a server may support. Known capabilities are defined here, in this schema, but this is not a closed set: any server can define its own, additional capabilities.
pub(all) struct ServerCapabilities {
  /// Present if the server supports argument autocompletion suggestions.
  completions : Json
  /// Experimental, non-standard capabilities that the server supports.
  experimental : Json
  /// Present if the server supports sending log messages to the client.
  logging : Json
  /// Present if the server offers any prompt templates.
  prompts : ServerCapabilitiesPrompts
  /// Present if the server offers any resources to read.
  resources : ServerCapabilitiesResources
  /// Present if the server offers any tools to call.
  tools : ServerCapabilitiesTools
} derive(Show, Eq)

///| ServerCapabilitiesPrompts: Present if the server offers any prompt templates.
pub(all) struct ServerCapabilitiesPrompts {
  /// Whether this server supports notifications for changes to the prompt list.
  listChanged : Bool
} derive(Show, Eq)

///| ServerCapabilitiesResources: Present if the server offers any resources to read.
pub(all) struct ServerCapabilitiesResources {
  /// Whether this server supports notifications for changes to the resource list.
  listChanged : Bool
  /// Whether this server supports subscribing to resource updates.
  subscribe : Bool
} derive(Show, Eq)

///| ServerCapabilitiesTools: Present if the server offers any tools to call.
pub(all) struct ServerCapabilitiesTools {
  /// Whether this server supports notifications for changes to the tool list.
  listChanged : Bool
} derive(Show, Eq)

///|
pub enum ServerNotification {
  CancelledNotification(CancelledNotification)
  ProgressNotification(ProgressNotification)
  ResourceListChangedNotification(ResourceListChangedNotification)
  ResourceUpdatedNotification(ResourceUpdatedNotification)
  PromptListChangedNotification(PromptListChangedNotification)
  ToolListChangedNotification(ToolListChangedNotification)
  LoggingMessageNotification(LoggingMessageNotification)
} derive(Show, Eq)

///|
pub enum ServerRequest {
  PingRequest(PingRequest)
  CreateMessageRequest(CreateMessageRequest)
  ListRootsRequest(ListRootsRequest)
} derive(Show, Eq)

///|
pub enum ServerResult {
  Result(Result)
  InitializeResult(InitializeResult)
  ListResourcesResult(ListResourcesResult)
  ReadResourceResult(ReadResourceResult)
  ListPromptsResult(ListPromptsResult)
  GetPromptResult(GetPromptResult)
  ListToolsResult(ListToolsResult)
  CallToolResult(CallToolResult)
  CompleteResult(CompleteResult)
} derive(Show, Eq)

///| SetLevelRequest: A request from the client to the server, to enable or adjust logging.
pub(all) struct SetLevelRequest {
  /// JSON-RPC: "method" = "logging/setLevel"
  params : SetLevelRequestParams
} derive(Show, Eq)

///|
pub(all) struct SetLevelRequestParams {
  /// The level of logging that the client wants to receive from the server. The server should send all logs at this level and higher (i.e., more severe) to the client as notifications/message.
  level : LoggingLevel
} derive(Show, Eq)

///| SubscribeRequest: Sent from the client to request resources/updated notifications from the server whenever a particular resource changes.
pub(all) struct SubscribeRequest {
  /// JSON-RPC: "method" = "resources/subscribe"
  params : SubscribeRequestParams
} derive(Show, Eq)

///|
pub(all) struct SubscribeRequestParams {
  /// The URI of the resource to subscribe to. The URI can use any protocol; it is up to the server how to interpret it.
  uri : String
} derive(Show, Eq)

///| TextContent: Text provided to or from an LLM.
pub(all) struct TextContent {
  /// Optional annotations for the client.
  annotations : Annotations?
  /// The text content of the message.
  text : String
  /// JSON-RPC: "type" = "text"
} derive(Show, Eq)

///|
pub(all) struct TextResourceContents {
  /// The MIME type of this resource, if known.
  mimeType : String?
  /// The text of the item. This must only be set if the item can actually be represented as text (not binary data).
  text : String
  /// The URI of this resource.
  uri : String
} derive(Show, Eq)

///| Tool: Definition for a tool the client can call.
pub(all) struct Tool {
  /// Optional additional tool information.
  annotations : ToolAnnotations?
  /// A human-readable description of the tool.
  ///
  /// This can be used by clients to improve the LLM's understanding of available tools. It can be thought of like a "hint" to the model.
  description : String?
  /// A JSON Schema object defining the expected parameters for the tool.
  inputSchema : ToolInputSchema
  /// The name of the tool.
  name : String
} derive(Show, Eq)

///| ToolInputSchema: A JSON Schema object defining the expected parameters for the tool.
pub(all) struct ToolInputSchema {
  properties : Json?
  required : Array[String]?
  /// JSON-RPC: "type" = "object"
} derive(Show, Eq)

///| ToolAnnotations: Additional properties describing a Tool to clients.
///
/// NOTE: all properties in ToolAnnotations are **hints**.
/// They are not guaranteed to provide a faithful description of
/// tool behavior (including descriptive properties like `title`).
///
/// Clients should never make tool use decisions based on ToolAnnotations
/// received from untrusted servers.
pub(all) struct ToolAnnotations {
  /// If true, the tool may perform destructive updates to its environment.
  /// If false, the tool performs only additive updates.
  ///
  /// (This property is meaningful only when `readOnlyHint == false`)
  ///
  /// Default: true
  destructiveHint : Bool
  /// If true, calling the tool repeatedly with the same arguments
  /// will have no additional effect on the its environment.
  ///
  /// (This property is meaningful only when `readOnlyHint == false`)
  ///
  /// Default: false
  idempotentHint : Bool
  /// If true, this tool may interact with an "open world" of external
  /// entities. If false, the tool's domain of interaction is closed.
  /// For example, the world of a web search tool is open, whereas that
  /// of a memory tool is not.
  ///
  /// Default: true
  openWorldHint : Bool
  /// If true, the tool does not modify its environment.
  ///
  /// Default: false
  readOnlyHint : Bool
  /// A human-readable title for the tool.
  title : String
} derive(Show, Eq)

///| ToolListChangedNotification: An optional notification from the server to the client, informing it that the list of tools it offers has changed. This may be issued by servers without any previous subscription from the client.
pub(all) struct ToolListChangedNotification {
  /// JSON-RPC: "method" = "notifications/tools/list_changed"
  params : ToolListChangedNotificationParams?
} derive(Show, Eq)

///|
pub(all) struct ToolListChangedNotificationParams {
  /// This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.
  _meta : Json
} derive(Show, Eq)

///| UnsubscribeRequest: Sent from the client to request cancellation of resources/updated notifications from the server. This should follow a previous resources/subscribe request.
pub(all) struct UnsubscribeRequest {
  /// JSON-RPC: "method" = "resources/unsubscribe"
  params : UnsubscribeRequestParams
} derive(Show, Eq)

///|
pub(all) struct UnsubscribeRequestParams {
  /// The URI of the resource to unsubscribe from.
  uri : String
} derive(Show, Eq)
