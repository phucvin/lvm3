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
    // Condition flag (not directly addressable, exactly one flag should always be set).
    cond,
};

/// Condition flags.
pub const Cond = enum(u16) {
    p = 1 << 0,
    z = 1 << 1,
    n = 1 << 2,
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

/// Reset all registers to 0.
pub fn reset() void {
    for (&registers) |*reg| {
        reg.* = 0;
    }
}

/// Increment the program counter. Saturates at 0xFFFF.
pub fn incPc() void {
    const pc = read(Reg.pc);
    if (pc == 0xFFFF) {
        return;
    }
    write(Reg.pc, pc + 1);
}

/// Set the condition flag.
pub fn setCond(cond: Cond) void {
    write(Reg.cond, @intFromEnum(cond));
}

/// Update the condition flag based on the value in a register.
pub fn updateCondFromReg(reg: Reg) void {
    const val = read(reg);
    if (val == 0) {
        setCond(Cond.z);
    } else if (val >> 15 == 1) {
        setCond(Cond.n);
    } else {
        setCond(Cond.p);
    }
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

    reset();
}

test "reset registers" {
    write(Reg.r0, 1);
    write(Reg.r1, 2);
    write(Reg.r2, 3);
    write(Reg.r3, 4);
    write(Reg.r4, 5);
    write(Reg.r5, 6);
    write(Reg.r6, 7);
    write(Reg.r7, 8);
    write(Reg.pc, 9);
    write(Reg.cond, 0b10);

    reset();
    try std.testing.expectEqual(0, read(Reg.r0));
    try std.testing.expectEqual(0, read(Reg.r1));
    try std.testing.expectEqual(0, read(Reg.r2));
    try std.testing.expectEqual(0, read(Reg.r3));
    try std.testing.expectEqual(0, read(Reg.r4));
    try std.testing.expectEqual(0, read(Reg.r5));
    try std.testing.expectEqual(0, read(Reg.r6));
    try std.testing.expectEqual(0, read(Reg.r7));
    try std.testing.expectEqual(0, read(Reg.pc));
    try std.testing.expectEqual(0, read(Reg.cond));
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

    reset();
}

test "set condition flag" {
    setCond(Cond.p);
    try std.testing.expectEqual(1 << 0, read(Reg.cond));

    setCond(Cond.z);
    try std.testing.expectEqual(1 << 1, read(Reg.cond));

    setCond(Cond.n);
    try std.testing.expectEqual(1 << 2, read(Reg.cond));

    reset();
}

test "update condition flag from register" {
    write(Reg.r0, 0);
    updateCondFromReg(Reg.r0);
    try std.testing.expectEqual(@intFromEnum(Cond.z), read(Reg.cond));

    write(Reg.r1, 0b1000_0000_0000_0000);
    updateCondFromReg(Reg.r1);
    try std.testing.expectEqual(@intFromEnum(Cond.n), read(Reg.cond));

    write(Reg.r2, 10);
    updateCondFromReg(Reg.r2);
    try std.testing.expectEqual(@intFromEnum(Cond.p), read(Reg.cond));

    reset();
}
