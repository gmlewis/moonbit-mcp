///|
test "parse CompleteResultCompletion from JSON" {
  // Create a JSON object with the properties we want to test
  let json_string =
    #|{
    #|  "hasMore": true,
    #|  "total": 42,
    #|  "values": ["completion1", "completion2", "completion3"]
    #|}
  let json = match @json.parse?(json_string) {
    Ok(v) => v
    Err(e) => fail!("Failed to parse test JSON: \{e}")
  }

  // Parse the JSON into a CompleteResultCompletion
  let result : CompleteResultCompletion = @json.from_json!(json)

  // Test that the values were correctly parsed
  inspect!(result.hasMore, content="Some(true)")
  inspect!(result.total, content="Some(42)")
  inspect!(
    result.values,
    content=
      #|["completion1", "completion2", "completion3"]
    ,
  )
}

///|
test "parse CompleteResultCompletion from JSON with bad number" {
  // Create a JSON object with the properties we want to test
  let json_string =
    #|{
    #|  "hasMore": true,
    #|  "total": "42",
    #|  "values": ["completion1", "completion2", "completion3"]
    #|}
  let json = match @json.parse?(json_string) {
    Ok(v) => v
    Err(e) => fail!("Failed to parse test JSON: \{e}")
  }

  // Parse the JSON into a CompleteResultCompletion
  let result : Result[CompleteResultCompletion, _] = @json.from_json?(json)

  // Test that the values were correctly parsed
  inspect!(
    result,
    content=
      #|Err(JsonDecodeError(($, "expected number; got String(\"42\")")))
    ,
  )
}

///|
test "parse CompleteResultCompletion with missing optional fields" {
  let json_string =
    #|{
    #|  "values": ["only", "required", "field"]
    #|}
  let json = match @json.parse?(json_string) {
    Ok(v) => v
    Err(e) => fail!("Failed to parse test JSON: \{e}")
  }

  // Parse the JSON into a CompleteResultCompletion
  let result : CompleteResultCompletion = @json.from_json!(json)

  // Test that the values were correctly parsed and optional fields are None
  inspect!(result.hasMore, content="None")
  inspect!(result.total, content="None")
  inspect!(
    result.values,
    content=
      #|["only", "required", "field"]
    ,
  )
}

///|
test "error when required field is missing" {
  let json_string =
    #|{
    #|  "hasMore": true,
    #|  "total": 42
    #|}
  let json = match @json.parse?(json_string) {
    Ok(v) => v
    Err(e) => fail!("Failed to parse test JSON: \{e}")
  }

  // Parse the JSON into a CompleteResultCompletion
  let result : Result[CompleteResultCompletion, _] = @json.from_json?(json)

  //
  inspect!(
    result,
    content=
      #|Err(JsonDecodeError(($, "expected field 'values'")))
    ,
  )
}
