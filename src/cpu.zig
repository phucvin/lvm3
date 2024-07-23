const std = @import("std");
const registers = @import("registers.zig");
const utils = @import("utils.zig");
const memory = @import("memory.zig");
const tsr = @import("tsr.zig");

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
        const imm = utils.sext(instr & 0x1F, 5);
        registers.write(dr, registers.read(sr1) + imm);
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
        const imm = utils.sext(instr & 0x1F, 5);
        registers.write(dr, registers.read(sr1) & imm);
    } else {
        const sr2: Reg = @enumFromInt(instr & 0x7);
        registers.write(dr, registers.read(sr1) & registers.read(sr2));
    }
    registers.updateCondFromReg(dr);
}

/// Execute a load register instruction.
pub fn ldr(instr: u16) void {
    const dr: Reg = @enumFromInt((instr >> 9) & 0x7);
    const base_r: Reg = @enumFromInt((instr >> 6) & 0x7);
    const offset = utils.sext(instr & 0x3F, 6);
    registers.write(dr, memory.read(registers.read(base_r) + offset));
    registers.updateCondFromReg(dr);
}

/// Execute a store register instruction.
pub fn str(instr: u16) void {
    const sr: Reg = @enumFromInt((instr >> 9) & 0x7);
    const base_r: Reg = @enumFromInt((instr >> 6) & 0x7);
    const offset = utils.sext(instr & 0x3F, 6);
    memory.write(registers.read(base_r) + offset, registers.read(sr));
}

/// Execute a bitwise NOT instruction.
pub fn not(instr: u16) void {
    const dr: Reg = @enumFromInt((instr >> 9) & 0x7);
    const sr: Reg = @enumFromInt((instr >> 6) & 0x7);
    registers.write(dr, ~registers.read(sr));
    registers.updateCondFromReg(dr);
}

/// Execute a load indirect instruction.
pub fn ldi(instr: u16) void {
    const dr: Reg = @enumFromInt((instr >> 9) & 0x7);
    const pc_offset = utils.sext(instr & 0x1FF, 9);
    registers.write(dr, memory.read(memory.read(registers.read(Reg.pc) + pc_offset)));
    registers.updateCondFromReg(dr);
}

/// Execute a store indirect instruction.
pub fn sti(instr: u16) void {
    const sr: Reg = @enumFromInt((instr >> 9) & 0x7);
    const pc_offset = utils.sext(instr & 0x1FF, 9);
    memory.write(memory.read(registers.read(Reg.pc) + pc_offset), registers.read(sr));
}

/// Execute a jump instruction (also handles return from subroutine).
pub fn jmp(instr: u16) void {
    const base_r: Reg = @enumFromInt((instr >> 6) & 0x7);
    registers.write(Reg.pc, registers.read(base_r));
}

/// Execute a load effective address instruction.
pub fn lea(instr: u16) void {
    const dr: Reg = @enumFromInt((instr >> 9) & 0x7);
    const pc_offset = utils.sext(instr & 0x1FF, 9);
    registers.write(dr, registers.read(Reg.pc) + pc_offset);
    registers.updateCondFromReg(dr);
}

/// Execute a trap instruction.
pub fn trap(instr: u16) !void {
    const trap_vec: tsr.Vec = @enumFromInt(instr & 0xFF);
    switch (trap_vec) {
        tsr.Vec.getc => try tsr.getc(),
        tsr.Vec.out => try tsr.out(),
        tsr.Vec.puts => tsr.puts(),
        tsr.Vec.in => tsr.in(),
        tsr.Vec.putsp => tsr.putsp(),
        tsr.Vec.halt => tsr.halt(),
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

test "load register" {
    registers.write(Reg.r0, 0x5000);
    memory.write(0x5000, 42);
    memory.write(0x5001, 0xa);
    memory.write(0xd, 100);

    ldr(0b0110_001_000_000000);
    try std.testing.expectEqual(42, registers.read(Reg.r1));

    ldr(0b0110_001_000_000001);
    try std.testing.expectEqual(10, registers.read(Reg.r1));

    ldr(0b0110_010_001_000011);
    try std.testing.expectEqual(100, registers.read(Reg.r2));

    registers.reset();
    memory.reset();
}

test "store register" {
    registers.write(Reg.r0, 0x5000);
    registers.write(Reg.r1, 42);
    registers.write(Reg.r2, 0xa);
    registers.write(Reg.r3, 100);

    str(0b0111_000_001_000000);
    try std.testing.expectEqual(0x5000, memory.read(42));

    str(0b0111_001_010_000001);
    try std.testing.expectEqual(42, memory.read(0xb));

    str(0b0111_010_011_000011);
    try std.testing.expectEqual(0xa, memory.read(103));

    registers.reset();
    memory.reset();
}

test "bitwise not" {
    registers.write(Reg.r0, 0b1100_0000_1111_1010);
    registers.write(Reg.r1, 0b1111_1111_1111_1100);

    not(0b1001_010_000_111111);
    try std.testing.expectEqual(0b0011_1111_0000_0101, registers.read(Reg.r2));

    not(0b1001_010_001_111111);
    try std.testing.expectEqual(0b0000_0000_0000_0011, registers.read(Reg.r2));

    not(0b1001_010_010_111111);
    try std.testing.expectEqual(0b1111_1111_1111_1100, registers.read(Reg.r2));

    not(0b1001_000_111_111111);
    try std.testing.expectEqual(0b1111_1111_1111_1111, registers.read(Reg.r0));

    registers.reset();
}

test "load indirect" {
    registers.write(Reg.pc, 0x1000);
    memory.write(0x1008, 0x4000);
    memory.write(0x4000, 42);
    ldi(0b1010_000_000001000);
    try std.testing.expectEqual(42, registers.read(Reg.r0));

    memory.write(0x1008, 0x4001);
    memory.write(0x4001, 80);
    registers.incPc();
    ldi(0b1010_001_000000111);
    try std.testing.expectEqual(80, registers.read(Reg.r1));

    ldi(0b1010_001_000000000);
    try std.testing.expectEqual(0, registers.read(Reg.r1));

    registers.reset();
    memory.reset();
}

test "store indirect" {
    registers.write(Reg.pc, 0x2000);
    registers.write(Reg.r0, 0x5000);
    registers.write(Reg.r1, 500);
    registers.write(Reg.r2, 111);

    memory.write(0x2008, 10);
    memory.write(0x2007, 0xFFFE);
    memory.write(0x2000, 1);

    sti(0b1011_000_000001000);
    try std.testing.expectEqual(0x5000, memory.read(10));

    sti(0b1011_001_000000111);
    try std.testing.expectEqual(500, memory.read(0xFFFE));

    sti(0b1011_010_000000000);
    try std.testing.expectEqual(111, memory.read(1));

    registers.reset();
    memory.reset();
}

test "jump" {
    registers.write(Reg.r0, 0x4000);
    registers.write(Reg.r1, 0x5000);
    registers.write(Reg.r7, 0x3000);

    jmp(0b1100_000_000_000000);
    try std.testing.expectEqual(0x4000, registers.read(Reg.pc));

    jmp(0b1100_000_001_000000);
    try std.testing.expectEqual(0x5000, registers.read(Reg.pc));

    jmp(0b1100_000_111_000000);
    try std.testing.expectEqual(0x3000, registers.read(Reg.pc));

    registers.reset();
}

test "load effective address" {
    registers.write(Reg.pc, 0x8000);
    lea(0b1110_000_000001000);
    try std.testing.expectEqual(0x8008, registers.read(Reg.r0));

    lea(0b1110_001_000000111);
    try std.testing.expectEqual(0x8007, registers.read(Reg.r1));

    lea(0b1110_010_000000000);
    try std.testing.expectEqual(0x8000, registers.read(Reg.r2));

    registers.reset();
}
