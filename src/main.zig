const std = @import("std");
const memory = @import("memory.zig");
const registers = @import("registers.zig");
const cpu = @import("cpu.zig");
const tsr = @import("tsr.zig");
const terminal = @import("terminal.zig");

const Reg = registers.Reg;
const Cond = registers.Cond;
const Op = cpu.Op;

const start = 0x3000;

pub fn main() !void {
    terminal.disableCanonAndEcho();

    registers.setCond(Cond.z); // One condition flag should always be set.
    registers.write(Reg.pc, start);

    const file = try std.fs.cwd().openFile("test", .{});
    defer file.close();

    const origin = try memory.getProgramOrigin(file);
    std.debug.print("Program origin: {}\n", .{origin});

    while (true) {
        const instr = memory.read(registers.read(Reg.pc));
        const op = cpu.getOp(instr);
        registers.incPc();

        try tsr.in();

        switch (op) {
            .br => cpu.br(instr),
            .add => cpu.add(instr),
            .ld => cpu.ld(instr),
            .st => cpu.st(instr),
            .jsr => cpu.jsr(instr),
            .and_ => cpu.and_(instr),
            .ldr => cpu.ldr(instr),
            .str => cpu.str(instr),
            .rti => unreachable, // Unused.
            .not => cpu.not(instr),
            .ldi => cpu.ldi(instr),
            .sti => cpu.sti(instr),
            .jmp => cpu.jmp(instr),
            .res => unreachable, // Unused.
            .lea => cpu.lea(instr),
            .trap => try cpu.trap(instr),
        }
    }
}
