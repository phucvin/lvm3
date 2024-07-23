const std = @import("std");

const mem_size = std.math.maxInt(u16);

var memory = [_]u16{0} ** mem_size;

/// Read the value at a memory address.
pub fn read(addr: u16) u16 {
    // Return 0 for out-of-bounds reads to avoid optional/result handling.
    if (addr == mem_size) {
        return 0;
    }
    return memory[addr];
}
/// Write a value to a memory address.
pub fn write(addr: u16, val: u16) void {
    // Ignore out-of-bounds writes to avoid result handling.
    if (addr == mem_size) {
        return;
    }
    memory[addr] = val;
}

/// Reset all memory to 0.
pub fn reset() void {
    memory = [_]u16{0} ** mem_size;
}

// Determine where to place the program in memory.
fn getProgramOrigin(file: std.fs.File) !u16 {
    var buffer: [2]u8 = undefined;
    const bytes_read = try file.read(&buffer);
    if (bytes_read < buffer.len) {
        return error.InsufficientData;
    }
    return std.mem.readInt(u16, &buffer, .big);
}

/// Load a program from a file into memory.
pub fn loadProgram(file_path: []const u8) !void {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();
    const origin = try getProgramOrigin(file);
    var buffer: [2]u8 = undefined;
    var index = origin;
    while (true) : (index += 1) {
        const bytes_read = try file.read(&buffer);
        if (bytes_read < buffer.len or index >= mem_size) {
            break;
        }
        memory[index] = std.mem.readInt(u16, &buffer, .big);
    }
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

    addr = mem_size - 1;
    val = mem_size;
    write(addr, val);
    try std.testing.expectEqual(val, read(addr));
    try std.testing.expectEqual(0, read(addr + 1));

    reset();
}

test "memory reset" {
    write(0, 42);
    write(1000, 123);
    write(mem_size - 1, mem_size);
    try std.testing.expectEqual(42, read(0));
    try std.testing.expectEqual(123, read(1000));
    try std.testing.expectEqual(mem_size, read(mem_size - 1));

    reset();
    try std.testing.expectEqual(0, read(0));
    try std.testing.expectEqual(0, read(1000));
    try std.testing.expectEqual(0, read(mem_size - 1));
}
