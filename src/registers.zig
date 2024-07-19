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
    // Program counter.
    pc,
    // Condition flags.
    cond,
    // Number of registers (not a register itself).
    count,
};

var registers = [_]u16{0} ** @intFromEnum(Reg.count);

/// Read the value in a register.
pub fn read(reg: Reg) u16 {
    return registers[@intFromEnum(reg)];
}

/// Write a value to a register.
pub fn write(reg: Reg, val: u16) void {
    registers[@intFromEnum(reg)] = val;
}
