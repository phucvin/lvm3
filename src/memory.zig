const std = @import("std");

/// Number of addressable memory locations.
pub const size = std.math.maxInt(u16);

var memory = [_]u16{0} ** size;

/// Read the value at a memory address.
pub fn read(addr: u16) u16 {
    return memory[addr];
}
/// Write a value to a memory address.
pub fn write(addr: u16, val: u16) void {
    memory[addr] = val;
}
