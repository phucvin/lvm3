const std = @import("std");
const memory = @import("memory.zig");
const registers = @import("registers.zig");
const cpu = @import("cpu.zig");

const Reg = registers.Reg;
const Cond = registers.Cond;
const Op = cpu.Op;

const start = 0x3000;

pub fn main() !void {
    registers.setCond(Cond.z); // One condition flag should always be set.
    registers.write(Reg.pc, start);

    while (true) {
        const instr = try memory.read(registers.read(Reg.pc));
        const op = @as(Op, @enumFromInt(instr >> 12));
        registers.incPc();

        switch (op) {
            .br => unreachable,
            .add => unreachable,
            .ld => unreachable,
            .st => unreachable,
            .jsr => unreachable,
            .and_ => unreachable,
            .ldr => unreachable,
            .str => unreachable,
            .rti => unreachable,
            .not => unreachable,
            .ldi => unreachable,
            .sti => unreachable,
            .jmp => unreachable,
            .res => unreachable,
            .lea => unreachable,
            .trap => unreachable,
        }
    }
}
