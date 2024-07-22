const std = @import("std");
const registers = @import("registers.zig");
const utils = @import("utils.zig");

const Reg = registers.Reg;
const Cond = registers.Cond;

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

/// Execute a branch instruction.
pub fn br(instr: u16) void {
    const pc_offset = utils.sext(instr & 0x1FF, 9);
    const cond = (instr >> 9) & 0x7;
    if ((cond & registers.read(Reg.cond)) != 0) {
        registers.write(Reg.pc, registers.read(Reg.pc) + pc_offset);
    }
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

test "branch" {
    registers.write(Reg.pc, 0x3000);

    registers.setCond(Cond.z);
    br(0b0000_0100_0000_0011);
    try std.testing.expectEqual(0x3003, registers.read(Reg.pc));
    br(0b0000_1100_0000_0001);
    try std.testing.expectEqual(0x3004, registers.read(Reg.pc));

    registers.setCond(Cond.p);
    br(0b0000_1100_0000_0111);
    try std.testing.expectEqual(0x3004, registers.read(Reg.pc));
    br(0b0000_1110_0000_0111);
    try std.testing.expectEqual(0x300b, registers.read(Reg.pc));

    registers.setCond(Cond.n);
    br(0b0000_1110_0000_0000);
    try std.testing.expectEqual(0x300b, registers.read(Reg.pc));
    br(0b0000_1000_0000_0010);
    try std.testing.expectEqual(0x300d, registers.read(Reg.pc));

    registers.reset();
}
