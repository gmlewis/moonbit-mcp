// Define the C FFI bindings
///|
fn put_char(_c : Byte) -> Unit {
  abort("not native")
}

///|
fn get_char() -> Byte {
  abort("not native")
}

///|
fn set_raw_mode() -> Unit {
  abort("not native")
}

///|
fn restore_terminal() -> Unit {
  abort("not native")
}

///|
priv extern type TimeSpec

///|
fn clock_gettime(_clk_id : Int, _tp : TimeSpec) -> Int {
  abort("not native")
}

///|
pub fn unix_nanos() -> Int64 {
  let time_spec = FixedArray::from_array([0L, 0L])
  let tp : TimeSpec = cast(time_spec)
  let res = clock_gettime(0, tp)
  if res != 0 {
    write_stderr("Error getting time\n")
    return -1L
  }
  let seconds = time_spec[0]
  let nanoseconds = time_spec[1]
  let total_nanos = seconds * 1_000_000_000L + nanoseconds
  total_nanos
}

///|
fn[A, B] cast(a : A) -> B = "%identity"

///|
priv extern type BytePtr

///|
fn write(_fd : Int, _buf : BytePtr, _count : Int) -> Int {
  abort("not native")
}

///|
pub fn write_stdout(s : String) -> Unit {
  write_fd(1, s)
}

///|
pub fn write_stderr(s : String) -> Unit {
  write_fd(2, s)
}

///|
fn write_fd(fd : Int, s : String) -> Unit {
  let bytes = @base64.str2bytes(s)
  let len = bytes.length()
  // null-terminate the string
  let buf = FixedArray::makei(len + 1, fn(x : Int) -> Byte {
    if x < len {
      bytes[x]
    } else {
      0
    }
  })
  let buf_ptr : BytePtr = cast(buf)
  let res = write(fd, buf_ptr, len)
  if res < 0 {
    println("Error writing to stderr")
  }
}

///|
fn posix_sleep(_seconds : Int) -> Int {
  abort("not native")
}

///|
pub fn sleep(seconds : Int) -> Unit {
  posix_sleep(seconds) |> ignore()
}
