pub const Vec = enum(u8) {
    getc = 0x20,
    out = 0x21,
    puts = 0x22,
    in = 0x23,
    putsp = 0x24,
    halt = 0x25,
};

pub fn getc() u16 {
    unreachable;
}

pub fn out() void {
    unreachable;
}

pub fn puts() void {
    unreachable;
}

pub fn in() void {
    unreachable;
}

pub fn putsp() void {
    unreachable;
}

pub fn halt() void {
    unreachable;
}
