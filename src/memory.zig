const std = @import("std");

/// Number of addressable memory locations.
pub const size = std.math.maxInt(u16);

var memory = [_]u16{0} ** size;

/// Read the value at a memory address.
pub fn read(addr: u16) !u16 {
    if (addr == size) {
        return error.OutOfBounds;
    }
    return memory[addr];
}
/// Write a value to a memory address.
pub fn write(addr: u16, val: u16) !void {
    if (addr == size) {
        return error.OutOfBounds;
    }
    memory[addr] = val;
}

test "memory read and write" {
    comptime var addr = 0;
    comptime var val = 42;
    try write(addr, val);
    try std.testing.expectEqual(val, read(addr));

    addr = 1000;
    val = 123;
    try write(addr, val);
    try std.testing.expectEqual(val, read(addr));
    try std.testing.expectEqual(0, read(addr - 1));
    try std.testing.expectEqual(0, read(addr + 1));

    addr = size - 1;
    val = size;
    try write(addr, val);
    try std.testing.expectEqual(val, read(addr));

    addr = size;
    val = 0;
    try std.testing.expectError(error.OutOfBounds, write(addr, val));
    try write(addr - 1, val);
    try std.testing.expectError(error.OutOfBounds, read(addr));
}
