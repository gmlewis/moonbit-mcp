///|
pub struct Context {
  start_time_unix_nanos : Int64
  timeout_millis : Int?
}

///|
pub fn Context::new() -> Context {
  let start_time_unix_nanos = unix_nanos()
  Context::{ start_time_unix_nanos, timeout_millis: None }
}

///|
pub fn Context::with_timeout(self : Context, timeout_millis : Int) -> Context {
  let start_time_unix_nanos = unix_nanos()
  Context::{
    ..self,
    start_time_unix_nanos,
    timeout_millis: Some(timeout_millis),
  }
}

///|
fn Context::now(self : Context) -> Context {
  let start_time_unix_nanos = unix_nanos()
  Context::{ ..self, start_time_unix_nanos, }
}
