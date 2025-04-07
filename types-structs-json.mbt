///|
pub impl ToJson for Annotations with to_json(self) {
  let obj = {}
  if self.audience is Some(audience) {
    obj["audience"] = audience.to_json()
  }
  if self.priority is Some(priority) {
    obj["priority"] = priority.to_json()
  }
  obj.to_json()
}

///|
pub impl @json.FromJson for Annotations with from_json(json, path) {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "expected object"))
  }
  let audience : Array[Role]? = if obj["audience"] is Some(json) {
    let v : Result[Array[Role], _] = @json.from_json?(json)
    if v is Ok(roles) {
      Some(roles)
    } else {
      None
    }
  } else {
    None
  }
  let priority = if obj["priority"] is Some(Number(n)) { Some(n) } else { None }
  { audience, priority }
}
