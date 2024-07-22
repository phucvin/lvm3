const std = @import("std");
const registers = @import("registers.zig");
const utils = @import("utils.zig");
const memory = @import("memory.zig");

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

/// Execute an add instruction.
pub fn add(instr: u16) void {
    const dr: Reg = @enumFromInt((instr >> 9) & 0x7);
    const sr1: Reg = @enumFromInt((instr >> 6) & 0x7);
    const imm_flag = (instr >> 5) & 0x1;
    if (imm_flag != 0) {
        const imm5 = utils.sext(instr & 0x1F, 5);
        registers.write(dr, registers.read(sr1) + imm5);
    } else {
        const sr2: Reg = @enumFromInt(instr & 0x7);
        registers.write(dr, registers.read(sr1) + registers.read(sr2));
    }
    registers.updateCondFromReg(dr);
}

/// Execute a load instruction.
pub fn ld(instr: u16) void {
    const dr: Reg = @enumFromInt((instr >> 9) & 0x7);
    const pc_offset = utils.sext(instr & 0x1FF, 9);
    registers.write(dr, memory.read(registers.read(Reg.pc) + pc_offset));
    registers.updateCondFromReg(dr);
}

/// Execute a store instruction.
pub fn st(instr: u16) void {
    const sr: Reg = @enumFromInt((instr >> 9) & 0x7);
    const pc_offset = utils.sext(instr & 0x1FF, 9);
    memory.write(registers.read(Reg.pc) + pc_offset, registers.read(sr));
}

/// Execute a jump register instruction.
pub fn jsr(instr: u16) void {
    const pc = registers.read(Reg.pc);
    registers.write(Reg.r7, pc);
    const imm_flag = (instr >> 11) & 0x1;
    if (imm_flag != 0) {
        // JSR.
        const pc_offset = utils.sext(instr & 0x7FF, 11);
        registers.write(Reg.pc, pc + pc_offset);
    } else {
        // JSRR.
        const base_r: Reg = @enumFromInt((instr >> 6) & 0x7);
        registers.write(Reg.pc, registers.read(base_r));
    }
}

/// Execute a bitwise AND instruction.
pub fn and_(instr: u16) void {
    const dr: Reg = @enumFromInt((instr >> 9) & 0x7);
    const sr1: Reg = @enumFromInt((instr >> 6) & 0x7);
    const imm_flag = (instr >> 5) & 0x1;
    if (imm_flag != 0) {
        const imm5 = utils.sext(instr & 0x1F, 5);
        registers.write(dr, registers.read(sr1) & imm5);
    } else {
        const sr2: Reg = @enumFromInt(instr & 0x7);
        registers.write(dr, registers.read(sr1) & registers.read(sr2));
    }
    registers.updateCondFromReg(dr);
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
    br(0b0000_010_000000011);
    try std.testing.expectEqual(0x3003, registers.read(Reg.pc));
    br(0b0000_110_000000001);
    try std.testing.expectEqual(0x3004, registers.read(Reg.pc));

    registers.setCond(Cond.p);
    br(0b0000_110_000000111);
    try std.testing.expectEqual(0x3004, registers.read(Reg.pc));
    br(0b0000_111_000000111);
    try std.testing.expectEqual(0x300b, registers.read(Reg.pc));

    registers.setCond(Cond.n);
    br(0b0000_111_000000000);
    try std.testing.expectEqual(0x300b, registers.read(Reg.pc));
    br(0b0000_100_000000010);
    try std.testing.expectEqual(0x300d, registers.read(Reg.pc));

    registers.reset();
}

test "add" {
    registers.write(Reg.r0, 1);
    registers.write(Reg.r1, 2);
    registers.write(Reg.r2, 3);

    add(0b0101_000_001_0_00010);
    try std.testing.expectEqual(5, registers.read(Reg.r0));

    add(0b0101_001_010_0_00000);
    try std.testing.expectEqual(8, registers.read(Reg.r1));

    add(0b0101_010_011_1_01111);
    try std.testing.expectEqual(15, registers.read(Reg.r2));

    add(0b0101_000_100_1_00000);
    try std.testing.expectEqual(0, registers.read(Reg.r0));

    registers.reset();
}

test "load" {
    registers.write(Reg.pc, 0x3000);
    memory.write(0x3008, 42);
    ld(0b0010_000_000001000);
    try std.testing.expectEqual(42, registers.read(Reg.r0));
    ld(0b0010_000_000000011);
    try std.testing.expectEqual(0, registers.read(Reg.r0));

    memory.write(0x3008, 80);
    registers.incPc();
    ld(0b0010_001_000000111);
    try std.testing.expectEqual(80, registers.read(Reg.r1));

    memory.write(0x3008, 0);
    registers.incPc();
    registers.incPc();
    ld(0b0010_001_000000101);
    try std.testing.expectEqual(0, registers.read(Reg.r1));

    registers.reset();
    memory.reset();
}

test "store" {
    registers.write(Reg.pc, 0x3000);
    registers.write(Reg.r0, 42);
    st(0b0011_000_000001000);
    try std.testing.expectEqual(42, memory.read(0x3008));

    registers.write(Reg.r1, 80);
    registers.incPc();
    registers.incPc();
    st(0b0011_001_000000111);
    try std.testing.expectEqual(80, memory.read(0x3009));

    registers.write(Reg.r1, 0);
    st(0b0011_010_000000111);
    try std.testing.expectEqual(0, memory.read(0x3009));

    registers.reset();
    memory.reset();
}

test "jump register" {
    registers.write(Reg.pc, 0x3000);
    jsr(0b0100_1_00000_001010);
    try std.testing.expectEqual(0x3000, registers.read(Reg.r7));
    try std.testing.expectEqual(0x300a, registers.read(Reg.pc));

    registers.write(Reg.r1, 0x3001);
    jsr(0b0100_0_00001_000000);
    try std.testing.expectEqual(0x300a, registers.read(Reg.r7));
    try std.testing.expectEqual(0x3001, registers.read(Reg.pc));

    registers.write(Reg.r6, 0x4000);
    jsr(0b0100_0_00110_000001);
    try std.testing.expectEqual(0x3001, registers.read(Reg.r7));
    try std.testing.expectEqual(0x4000, registers.read(Reg.pc));

    registers.reset();
}

test "bitwise and" {
    registers.write(Reg.r0, 0b1010);
    registers.write(Reg.r1, 0b1100);
    registers.write(Reg.r2, 0b1111);

    and_(0b0101_000_001_0_00010);
    try std.testing.expectEqual(0b1100, registers.read(Reg.r0));

    and_(0b0101_001_010_0_00000);
    try std.testing.expectEqual(0b1100, registers.read(Reg.r1));

    and_(0b0101_010_011_1_01111);
    try std.testing.expectEqual(0b0000, registers.read(Reg.r2));

    and_(0b0101_000_001_1_01001);
    try std.testing.expectEqual(0b1000, registers.read(Reg.r0));

    registers.reset();
}
