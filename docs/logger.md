# Documentation for the logging facility

- `void log_string(char* strAddr)` - Print the zero terminated string starting at *strAddr* to the serial port
- `void log_newline()` - Print a newline character to the serial port
- `void log_char(char val)` - Print a the character *val* to the serial port
- `void log_numb(int8 val)` - Print 8 bit number *val* to the serial port
- `void log_numw(int16 val)` - Print 16 bit number *val* to the serial port
- `void log_numl(int32 val)` - Print 32 bit number *val* to the serial port
- `void log_numq(int64 val)` - Print 64 bit number *val* to the serial port
- `char* itoa_b(int8 val, char* buffer)` - Convert 8 bit number *val* to a zero terminated string (returns the `char*` where the string starts)
- `char* itoa_w(int16 val, char* buffer)` - Convert 16 bit number *val* to a zero terminated string (returns the `char*` where the string starts)
- `char* itoa_l(int32 val, char* buffer)` - Convert 32 bit number *val* to a zero terminated string (returns the `char*` where the string starts)
- `char* itoa_q(int64 val, char* buffer)` - Convert 64 bit number *val* to a zero terminated string (returns the `char*` where the string starts)
