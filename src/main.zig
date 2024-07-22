const std = @import("std");
const memory = @import("memory.zig");
const registers = @import("registers.zig");
const cpu = @import("cpu.zig");

const Reg = registers.Reg;
const Cond = registers.Cond;
const Op = cpu.Op;

const start = 0x3000;

pub fn main() void {
    registers.setCond(Cond.z); // One condition flag should always be set.
    registers.write(Reg.pc, start);

    while (true) {
        const instr = memory.read(registers.read(Reg.pc));
        const op = cpu.getOp(instr);
        registers.incPc();

        switch (op) {
            .br => cpu.br(instr),
            .add => cpu.add(instr),
            .ld => cpu.ld(instr),
            .st => cpu.st(instr),
            .jsr => cpu.jsr(instr),
            .and_ => cpu.and_(instr),
            .ldr => cpu.ldr(instr),
            .str => cpu.str(instr),
            .rti => unreachable,
            .not => cpu.not(instr),
            .ldi => cpu.ldi(instr),
            .sti => unreachable,
            .jmp => unreachable,
            .res => unreachable,
            .lea => unreachable,
            .trap => unreachable,
        }
    }
}
