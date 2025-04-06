// Define the C FFI bindings
///|
pub extern "C" fn put_char(c : Byte) -> Unit = "putchar"

///|
pub extern "C" fn get_char() -> Byte = "getchar"

///|
pub extern "C" fn set_raw_mode() -> Unit = "set_raw_mode"

///|
pub extern "C" fn restore_terminal() -> Unit = "restore_terminal"
