const std = @import("std");
const memory = @import("memory.zig");
const registers = @import("registers.zig");

const Reg = registers.Reg;

pub fn main() void {
    std.debug.print("LVM-3 has {d} addressable memory locations.\n", .{memory.size});

    const r0 = registers.read(Reg.r0);
    std.debug.print("The value of register r0 is {d}.\n", .{r0});
}
