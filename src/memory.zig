const std = @import("std");

const size = std.math.maxInt(u16);

var memory = [_]u16{0} ** size;

/// Read the value at a memory address.
pub fn read(addr: u16) u16 {
    // Return 0 for out-of-bounds reads to avoid optional/result handling.
    if (addr == size) {
        return 0;
    }
    return memory[addr];
}
/// Write a value to a memory address.
pub fn write(addr: u16, val: u16) void {
    // Ignore out-of-bounds writes to avoid result handling.
    if (addr == size) {
        return;
    }
    memory[addr] = val;
}

/// Reset all memory to 0.
pub fn reset() void {
    memory = [_]u16{0} ** size;
}

/// Determine where to place the program in memory.
pub fn getProgramOrigin(file: std.fs.File) !u16 {
    var buffer: [2]u8 = undefined;
    const bytes_read = try file.read(&buffer);
    if (bytes_read < 2) {
        return error.InsufficientData;
    }
    return std.mem.readInt(u16, &buffer, .big);
}

test "memory read and write" {
    comptime var addr = 0;
    comptime var val = 42;
    write(addr, val);
    try std.testing.expectEqual(val, read(addr));

    addr = 1000;
    val = 123;
    write(addr, val);
    try std.testing.expectEqual(val, read(addr));
    try std.testing.expectEqual(0, read(addr - 1));
    try std.testing.expectEqual(0, read(addr + 1));

    addr = size - 1;
    val = size;
    write(addr, val);
    try std.testing.expectEqual(val, read(addr));
    try std.testing.expectEqual(0, read(addr + 1));

    reset();
}

test "memory reset" {
    write(0, 42);
    write(1000, 123);
    write(size - 1, size);
    try std.testing.expectEqual(42, read(0));
    try std.testing.expectEqual(123, read(1000));
    try std.testing.expectEqual(size, read(size - 1));

    reset();
    try std.testing.expectEqual(0, read(0));
    try std.testing.expectEqual(0, read(1000));
    try std.testing.expectEqual(0, read(size - 1));
}
