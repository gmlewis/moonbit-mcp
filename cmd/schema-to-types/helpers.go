package main

import (
	"fmt"
	"strings"
)

func (d *Definition) genHelperMethods(jsonRPCConsts map[string]string) {
	switch {
	case strings.HasSuffix(d.name, "Request"):
		d.genRequestHelperMethods(jsonRPCConsts)
	case strings.HasSuffix(d.name, "Notification"):
		d.genNotificationHelperMethods(jsonRPCConsts)
	case strings.HasSuffix(d.name, "Result"):
		d.genResultHelperMethods()
	}
}

func (d *Definition) genRequestHelperMethods(jsonRPCConsts map[string]string) {
	method, hasConstMethod := jsonRPCConsts["method"]
	if !hasConstMethod {
		method = "self.method_"
	}

	lines := []string{
		"///|",
		fmt.Sprintf("pub impl MCPRequest for %v with to_call(self, id) {", d.name),
		fmt.Sprintf("  @jsonrpc2.new_call(id, %v, self.params.to_json())", method),
		"}",
		"",
		"///|",
		fmt.Sprintf("pub fn %v::from_message(msg : @jsonrpc2.Message) -> (@jsonrpc2.ID, %[1]v)?  {", d.name),
		"  guard msg is Request(req) else { return None }",
		"  guard req.id is Some(id) else { return None }",
	}

	if hasConstMethod {
		lines = append(lines,
			fmt.Sprintf("  guard req.method_ == %v else { return None }", method),
			`  let json = { "params" : req.params }.to_json()`,
		)
	} else {
		lines = append(lines, `  let json = { "method_": req.method_.to_json(), "params": req.params }.to_json()`)
	}

	lines = append(lines,
		fmt.Sprintf("  let v : Result[%v, _] = @json.from_json?(json)", d.name),
		"  guard v is Ok(request) else { return None }",
		"  Some((id, request))",
		"}",
	)

	d.helperStructsAndMethods = append(d.helperStructsAndMethods, strings.Join(lines, "\n"))
}

func (d *Definition) genNotificationHelperMethods(jsonRPCConsts map[string]string) {
	method, hasConstMethod := jsonRPCConsts["method"]
	if !hasConstMethod {
		method = "self.method_"
	}

	lines := []string{
		"///|",
		fmt.Sprintf("pub impl MCPNotification for %v with to_notification(self) {", d.name),
		fmt.Sprintf("  @jsonrpc2.new_notification(%v, self.params.to_json())", method),
		"}",
		"",
		"///|",
		fmt.Sprintf("pub fn %v::from_message(msg : @jsonrpc2.Message) -> %[1]v?  {", d.name),
		"  guard msg is Request(req) else { return None }",
		"  guard req.id is None else { return None }",
	}

	if hasConstMethod {
		lines = append(lines,
			fmt.Sprintf("  guard req.method_ == %v else { return None }", method),
			`  let json = { "params" : req.params }.to_json()`,
		)
	} else {
		lines = append(lines, `  let json = { "method_": req.method_.to_json(), "params": req.params }.to_json()`)
	}

	lines = append(lines,
		fmt.Sprintf("  let v : Result[%v, _] = @json.from_json?(json)", d.name),
		"  guard v is Ok(notification) else { return None }",
		"  Some(notification)",
		"}",
	)

	d.helperStructsAndMethods = append(d.helperStructsAndMethods, strings.Join(lines, "\n"))
}

func (d *Definition) genResultHelperMethods() {
	lines := []string{
		"///|",
		fmt.Sprintf("pub impl MCPResponse for %v with to_response(self, id) {", d.name),
		"  @jsonrpc2.new_response(id, Ok(self.to_json()))",
		"}",
		"",
		"///|",
		fmt.Sprintf("pub fn %v::from_message(msg : @jsonrpc2.Message) -> (@jsonrpc2.ID, %[1]v)?  {", d.name),
		"  guard msg is Response(res) else { return None }",
		"  guard res.result is Ok(json) else { return None }",
		fmt.Sprintf("  let v : Result[%v, _] = @json.from_json?(json)", d.name),
		"  guard v is Ok(result) else { return None }",
		"  Some((res.id, result))",
		"}",
	}

	d.helperStructsAndMethods = append(d.helperStructsAndMethods, strings.Join(lines, "\n"))
}
