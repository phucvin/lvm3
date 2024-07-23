const std = @import("std");
const registers = @import("registers.zig");

const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();
const Reg = registers.Reg;

pub const Vec = enum(u8) {
    getc = 0x20,
    out = 0x21,
    puts = 0x22,
    in = 0x23,
    putsp = 0x24,
    halt = 0x25,
};

/// Read a character from the keyboard and store it in R0.
pub fn getc() !void {
    const c = try stdin.reader().readByte();
    registers.write(Reg.r0, c);
}

/// Write a character in R0 to the console.
pub fn out() !void {
    const c = registers.read(Reg.r0);
    try stdout.writer().writeByte(@truncate(c));
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
