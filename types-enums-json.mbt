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
