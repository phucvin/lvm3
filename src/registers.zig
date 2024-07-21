const std = @import("std");

/// CPU registers.
pub const Reg = enum {
    // General-purpose.
    r0,
    r1,
    r2,
    r3,
    r4,
    r5,
    r6,
    r7,
    // Program counter (not directly addressable).
    pc,
    // Condition flag (not directly addressable, only one should be set at a time).
    cond,
};

/// Condition flags.
pub const Cond = enum(u16) {
    pos = 1 << 0,
    zro = 1 << 1,
    neg = 1 << 2,
};

var registers = [_]u16{0} ** (@intFromEnum(Reg.cond) + 1);

/// Read the value in a register.
pub fn read(reg: Reg) u16 {
    return registers[@intFromEnum(reg)];
}

/// Write a value to a register.
pub fn write(reg: Reg, val: u16) void {
    registers[@intFromEnum(reg)] = val;
}

/// Increment the program counter. Saturates at 0xFFFF.
pub fn incPc() void {
    const pc = read(Reg.pc);
    if (pc == 0xFFFF) {
        return;
    }
    write(Reg.pc, pc + 1);
}

test "registers read and write" {
    comptime var reg = Reg.r0;
    comptime var val = 21;
    write(reg, val);
    try std.testing.expectEqual(val, read(reg));

    reg = Reg.r7;
    val = 0xFFFF;
    write(reg, val);
    try std.testing.expectEqual(val, read(reg));
    try std.testing.expectEqual(0, read(Reg.r6));
    try std.testing.expectEqual(0, read(Reg.pc));

    reg = Reg.cond;
    val = 0b1010;
    write(reg, val);
    try std.testing.expectEqual(val, read(reg));
}

test "increment program counter" {
    incPc();
    try std.testing.expectEqual(1, read(Reg.pc));

    write(Reg.pc, 1000);
    incPc();
    incPc();
    try std.testing.expectEqual(1002, read(Reg.pc));

    write(Reg.pc, 0xFFFF);
    incPc();
    try std.testing.expectEqual(0xFFFF, read(Reg.pc));
}
