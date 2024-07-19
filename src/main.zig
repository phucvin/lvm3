const std = @import("std");
const memory = @import("memory.zig");

pub fn main() void {
    std.debug.print("LVM-3 has {d} addressable memory locations.\n", .{memory.size});
}
