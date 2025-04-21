///|
pub(open) trait MCPPrompt {
  as_prompt(Self) -> Prompt
  call_prompt(Self, Json?) -> GetPromptResult
}
