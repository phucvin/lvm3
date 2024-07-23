const std = @import("std");
const registers = @import("registers.zig");

const stdin = std.io.getStdIn();
const Reg = registers.Reg;

pub const Vec = enum(u8) {
    getc = 0x20,
    out = 0x21,
    puts = 0x22,
    in = 0x23,
    putsp = 0x24,
    halt = 0x25,
};

pub fn getc() !void {
    const c = try stdin.reader().readByte();
    registers.write(Reg.r0, c);
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
