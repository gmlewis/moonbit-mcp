package main

import (
	_ "embed"
	"strings"
	"testing"

	ord "github.com/wk8/go-ordered-map/v2"
)

//go:embed testdata/2025-03-26/schema.ts
var tsSchema20250326 string

func TestChunkify(t *testing.T) {
	t.Parallel()
	defs, categories := chunkify(tsSchema20250326)

	// log.SetFlags(0)
	// for pair := defs.Oldest(); pair != nil; pair = pair.Next() {
	// 	log.Printf("  %q,", pair.Key)
	// }
	// for pair := categories.Oldest(); pair != nil; pair = pair.Next() {
	// 	log.Printf("  {Key: %q, Value: %q},", pair.Key, pair.Value)
	// }

	wantDefs := []string{
		"JSONRPCMessage", "JSONRPCBatchRequest", "JSONRPCBatchResponse", "LATEST_PROTOCOL_VERSION", "JSONRPC_VERSION",
		"ProgressToken", "Cursor", "Request", "Notification", "Result", "RequestId", "JSONRPCRequest", "JSONRPCNotification",
		"JSONRPCResponse", "PARSE_ERROR", "INVALID_REQUEST", "METHOD_NOT_FOUND", "INVALID_PARAMS", "INTERNAL_ERROR", "JSONRPCError",
		"EmptyResult", "CancelledNotification", "InitializeRequest", "InitializeResult", "InitializedNotification", "ClientCapabilities",
		"ServerCapabilities", "Implementation", "PingRequest", "ProgressNotification", "PaginatedRequest", "PaginatedResult",
		"ListResourcesRequest", "ListResourcesResult", "ListResourceTemplatesRequest", "ListResourceTemplatesResult", "ReadResourceRequest",
		"ReadResourceResult", "ResourceListChangedNotification", "SubscribeRequest", "UnsubscribeRequest", "ResourceUpdatedNotification",
		"Resource", "ResourceTemplate", "ResourceContents", "TextResourceContents", "BlobResourceContents", "ListPromptsRequest",
		"ListPromptsResult", "GetPromptRequest", "GetPromptResult", "Prompt", "PromptArgument", "Role", "PromptMessage", "EmbeddedResource",
		"PromptListChangedNotification", "ListToolsRequest", "ListToolsResult", "CallToolResult", "CallToolRequest", "ToolListChangedNotification",
		"ToolAnnotations", "Tool", "SetLevelRequest", "LoggingMessageNotification", "LoggingLevel", "CreateMessageRequest", "CreateMessageResult",
		"SamplingMessage", "Annotations", "TextContent", "ImageContent", "AudioContent", "ModelPreferences", "ModelHint", "CompleteRequest",
		"CompleteResult", "ResourceReference", "PromptReference", "ListRootsRequest", "ListRootsResult", "Root", "RootsListChangedNotification",
		"ClientRequest", "ClientNotification", "ClientResult", "ServerRequest", "ServerNotification", "ServerResult",
	}

	if got, want := defs.Len(), len(wantDefs); got != want {
		t.Errorf("chunkify defs len = %v, want %v", got, want)
	}
	var i int
	for pair := defs.Oldest(); pair != nil; pair = pair.Next() {
		if pair.Key != wantDefs[i] {
			t.Errorf("chunkify defs[%v] = %q, want %q", i, pair.Key, wantDefs[i])
		}
		i++
	}

	wantCategories := []ord.Pair[string, string]{
		{Key: "", Value: "JSON-RPC types"},
		{Key: "EmptyResult", Value: "Empty result"},
		{Key: "CancelledNotification", Value: "Cancellation"},
		{Key: "InitializeRequest", Value: "Initialization"},
		{Key: "PingRequest", Value: "Ping"},
		{Key: "ProgressNotification", Value: "Progress notifications"},
		{Key: "PaginatedRequest", Value: "Pagination"},
		{Key: "ListResourcesRequest", Value: "Resources"},
		{Key: "ListPromptsRequest", Value: "Prompts"},
		{Key: "ListToolsRequest", Value: "Tools"},
		{Key: "SetLevelRequest", Value: "Logging"},
		{Key: "CreateMessageRequest", Value: "Sampling"},
		{Key: "CompleteRequest", Value: "Autocomplete"},
		{Key: "ListRootsRequest", Value: "Roots"},
		{Key: "ClientRequest", Value: "Client messages"},
		{Key: "ServerRequest", Value: "Server messages"},
	}
	if got, want := categories.Len(), len(wantCategories); got != want {
		t.Errorf("chunkify categories len = %v, want %v", got, want)
	}
	for i, pair := 0, categories.Oldest(); pair != nil; pair = pair.Next() {
		if pair.Key != wantCategories[i].Key {
			t.Errorf("chunkify categories[%v].Key = %q, want %q", i, pair.Key, wantCategories[i].Key)
		}
		if pair.Value != wantCategories[i].Value {
			t.Errorf("chunkify categories[%v].Value = %q, want %q", i, pair.Value, wantCategories[i].Value)
		}
		i++
	}
}

func TestConsolidate(t *testing.T) {
	t.Parallel()
	chunks := strings.Split(tsSchema20250326, "\n\n")
	chunks = consolidate(chunks)
	const maxLen = 20
	// log.SetFlags(0)
	// for _, got := range chunks {
	// 	log.Printf(`  %q,`, got[:maxLen])
	// }

	wantStr := []string{
		"/* JSON-RPC types */",
		"/**\n * Refers to any",
		"/**\n * A JSON-RPC ba",
		"/**\n * A JSON-RPC ba",
		"export const LATEST_",
		"export const JSONRPC",
		"/**\n * A progress to",
		"/**\n * An opaque tok",
		"export interface Req",
		"export interface Not",
		"export interface Res",
		"/**\n * A uniquely id",
		"/**\n * A request tha",
		"/**\n * A notificatio",
		"/**\n * A successful ",
		"export const PARSE_E",
		"export const INVALID",
		"export const METHOD_",
		"export const INVALID",
		"export const INTERNA",
		"/**\n * A response to",
		"/* Empty result */\n/",
		"/* Cancellation */\n/",
		"/* Initialization */",
		"/**\n * After receivi",
		"/**\n * This notifica",
		"/**\n * Capabilities ",
		"/**\n * Capabilities ",
		"/**\n * Describes the",
		"/* Ping */\n/**\n * A ",
		"/* Progress notifica",
		"/* Pagination */\nexp",
		"export interface Pag",
		"/* Resources */\n/**\n",
		"/**\n * The server's ",
		"/**\n * Sent from the",
		"/**\n * The server's ",
		"/**\n * Sent from the",
		"/**\n * The server's ",
		"/**\n * An optional n",
		"/**\n * Sent from the",
		"/**\n * Sent from the",
		"/**\n * A notificatio",
		"/**\n * A known resou",
		"/**\n * A template de",
		"/**\n * The contents ",
		"export interface Tex",
		"export interface Blo",
		"/* Prompts */\n/**\n *",
		"/**\n * The server's ",
		"/**\n * Used by the c",
		"/**\n * The server's ",
		"/**\n * A prompt or p",
		"/**\n * Describes an ",
		"/**\n * The sender or",
		"/**\n * Describes a m",
		"/**\n * The contents ",
		"/**\n * An optional n",
		"/* Tools */\n/**\n * S",
		"/**\n * The server's ",
		"/**\n * The server's ",
		"/**\n * Used by the c",
		"/**\n * An optional n",
		"/**\n * Additional pr",
		"/**\n * Definition fo",
		"/* Logging */\n/**\n *",
		"/**\n * Notification ",
		"/**\n * The severity ",
		"/* Sampling */\n/**\n ",
		"/**\n * The client's ",
		"/**\n * Describes a m",
		"/**\n * Optional anno",
		"/**\n * Text provided",
		"/**\n * An image prov",
		"/**\n * Audio provide",
		"/**\n * The server's ",
		"/**\n * Hints to use ",
		"/* Autocomplete */\n/",
		"/**\n * The server's ",
		"/**\n * A reference t",
		"/**\n * Identifies a ",
		"/* Roots */\n/**\n * S",
		"/**\n * The client's ",
		"/**\n * Represents a ",
		"/**\n * A notificatio",
		"/* Client messages *",
		"export type ClientNo",
		"export type ClientRe",
		"/* Server messages *",
		"export type ServerNo",
		"export type ServerRe",
	}
	if got, want := len(chunks), len(wantStr); got != want {
		t.Fatalf("consolidate chunks len = %v, want %v", got, want)
	}
	for i, chunk := range chunks {
		if got := chunk[:maxLen]; got != wantStr[i] {
			t.Errorf("consolidate chunks[%v] = '%v', want '%v'", i, got, wantStr[i])
		}
	}
}
