const std = @import("std");

/// Instruction opcodes.
pub const Op = enum(u4) {
    br, // Branch.
    add, // Add.
    ld, // Load.
    st, // Store.
    jsr, // Jump register.
    and_, // Bitwise AND.
    ldr, // Load register.
    str, // Store register.
    rti, // Return from interrupt (unused).
    not, // Bitwise NOT.
    ldi, // Load indirect.
    sti, // Store indirect.
    jmp, // Jump.
    res, // Reserved (unused).
    lea, // Load effective address.
    trap, // Execute trap.
};

/// Get the opcode (4 most significant bits) from an instruction.
pub fn getOp(instr: u16) Op {
    return @as(Op, @enumFromInt(instr >> 12));
}

test "get opcode from instruction" {
    try std.testing.expectEqual(Op.br, getOp(0b0000_0000_0000_0000));
    try std.testing.expectEqual(Op.add, getOp(0b0001_0000_0000_0000));
    try std.testing.expectEqual(Op.ld, getOp(0b0010_0000_0000_0000));
    try std.testing.expectEqual(Op.st, getOp(0b0011_0000_0000_0000));
    try std.testing.expectEqual(Op.jsr, getOp(0b0100_0000_0000_0000));
    try std.testing.expectEqual(Op.and_, getOp(0b0101_0000_0000_0000));
    try std.testing.expectEqual(Op.ldr, getOp(0b0110_0000_0000_0000));
    try std.testing.expectEqual(Op.str, getOp(0b0111_0000_0000_0000));
    try std.testing.expectEqual(Op.rti, getOp(0b1000_0000_0000_0000));
    try std.testing.expectEqual(Op.not, getOp(0b1001_0000_0000_0000));
    try std.testing.expectEqual(Op.ldi, getOp(0b1010_0000_0000_0000));
    try std.testing.expectEqual(Op.sti, getOp(0b1011_0000_0000_0000));
    try std.testing.expectEqual(Op.jmp, getOp(0b1100_0000_0000_0000));
    try std.testing.expectEqual(Op.res, getOp(0b1101_0000_0000_0000));
    try std.testing.expectEqual(Op.lea, getOp(0b1110_0000_0000_0000));
    try std.testing.expectEqual(Op.trap, getOp(0b1111_0000_0000_0000));
}
