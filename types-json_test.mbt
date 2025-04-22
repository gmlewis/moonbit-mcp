///|
test "serialize CompleteResultCompletion to JSON" {
  // Create a CompleteResultCompletion using the constructor function
  let completion = CompleteResultCompletion::new(hasMore=true, total=100, [
    "option1", "option2", "option3",
  ])

  // Convert to JSON
  let json = completion.to_json()

  // Verify the resulting JSON has the expected structure
  inspect!(
    json,
    content=
      #|Object({"values": Array([String("option1"), String("option2"), String("option3")]), "total": Number(100), "hasMore": True})
    ,
  )
}

///|
test "serialize CompleteResultCompletion with only required fields" {
  // Create a CompleteResultCompletion using the constructor function with only required fields
  let completion = CompleteResultCompletion::new(["single_value"])

  // Convert to JSON
  let json = completion.to_json()

  // Verify the resulting JSON has the expected structure
  inspect!(
    json,
    content=
      #|Object({"values": Array([String("single_value")])})
    ,
  )
}

///|
test "parse CompleteResultCompletion from JSON" {
  // Create a JSON object with the properties we want to test
  let json_string =
    #|{
    #|  "hasMore": true,
    #|  "total": 42,
    #|  "values": ["completion1", "completion2", "completion3"]
    #|}
  let json = @json.parse!(json_string)
  inspect!(
    json,
    content=
      #|Object({"hasMore": True, "total": Number(42), "values": Array([String("completion1"), String("completion2"), String("completion3")])})
    ,
  )

  // Parse the JSON into a CompleteResultCompletion
  let result : CompleteResultCompletion = @json.from_json!(json)

  // Test that the values were correctly parsed
  inspect!(
    result,
    content=
      #|{values: ["completion1", "completion2", "completion3"], total: Some(42), hasMore: Some(true)}
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
  let json = @json.parse!(json_string)

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
  let json = @json.parse!(json_string)

  // Parse the JSON into a CompleteResultCompletion
  let result : CompleteResultCompletion = @json.from_json!(json)

  // Test that the values were correctly parsed and optional fields are None
  inspect!(
    result,
    content=
      #|{values: ["only", "required", "field"], total: None, hasMore: None}
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
  let json = @json.parse!(json_string)

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

///|
test "serialize CancelledNotificationParams to JSON" {
  let params = CancelledNotificationParams::new(
    @jsonrpc2.ID::number(123),
    reason="test_reason",
  )
  let json = params.to_json()
  inspect!(
    json,
    content=
      #|Object({"requestId": Number(123), "reason": String("test_reason")})
    ,
  )
}

///|
test "serialize CancelledNotificationParams with only required fields" {
  let params = CancelledNotificationParams::new(@jsonrpc2.ID::number(456))
  let json = params.to_json()
  inspect!(
    json,
    content=
      #|Object({"requestId": Number(456)})
    ,
  )
}

///|
test "parse CancelledNotificationParams from JSON" {
  let json_string =
    #|{"requestId":789,"reason":"cancelled"}
  let json = match @json.parse?(json_string) {
    Ok(v) => v
    Err(e) => fail!("Failed to parse test JSON: \{e}")
  }
  let result : CancelledNotificationParams = @json.from_json!(json)
  inspect!(
    result,
    content=
      #|{requestId: Number(789), reason: Some("cancelled")}
    ,
  )
}

///|
test "parse CancelledNotificationParams with missing reason" {
  let json_string =
    #|{"requestId":42}
  let json = match @json.parse?(json_string) {
    Ok(v) => v
    Err(e) => fail!("Failed to parse test JSON: \{e}")
  }
  let result : CancelledNotificationParams = @json.from_json!(json)
  inspect!(result, content="{requestId: Number(42), reason: None}")
}

///|
test "error when requestId field missing" {
  let json_string =
    #|{"reason":"oops"}
  let json = match @json.parse?(json_string) {
    Ok(v) => v
    Err(e) => fail!("Failed to parse test JSON: \{e}")
  }
  let result : Result[CancelledNotificationParams, _] = @json.from_json?(json)
  inspect!(
    result,
    content=
      #|Err(JsonDecodeError(($, "expected field 'requestId'")))
    ,
  )
}
