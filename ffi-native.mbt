// Define the C FFI bindings
///|
pub extern "C" fn put_char(c : Byte) -> Unit = "putchar"

///|
pub extern "C" fn get_char() -> Byte = "getchar"

///|
pub extern "C" fn set_raw_mode() -> Unit = "set_raw_mode"

///|
pub extern "C" fn restore_terminal() -> Unit = "restore_terminal"

///|
extern type TimeSpec

///|
pub extern "C" fn clock_gettime(clk_id : Int, tp : TimeSpec) -> Int = "clock_gettime"

///|
pub fn unix_nanos() -> Int64 {
  let time_spec = FixedArray::from_array([0L, 0L])
  let tp : TimeSpec = cast(time_spec)
  let res = clock_gettime(0, tp)
  if res != 0 {
    println("Error getting time")
    return -1L
  }
  let seconds = time_spec[0]
  let nanoseconds = time_spec[1]
  let total_nanos = seconds * 1_000_000_000L + nanoseconds
  total_nanos
}

///|
fn cast[A, B](a : A) -> B = "%identity"
