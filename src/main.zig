const std = @import("std");
const memory = @import("memory.zig");
const registers = @import("registers.zig");
const cpu = @import("cpu.zig");
const tsr = @import("tsr.zig");
const terminal = @import("terminal.zig");
const utils = @import("utils.zig");

const Reg = registers.Reg;
const Cond = registers.Cond;
const Op = cpu.Op;

var act = std.os.linux.Sigaction{
    .handler = .{ .handler = terminal.signalHandler },
    .mask = std.os.linux.empty_sigset,
    .flags = 0,
};

const program_start = 0x3000;

pub fn main() !void {
    _ = std.os.linux.sigaction(std.os.linux.SIG.INT, &act, null);
    _ = std.os.linux.sigaction(std.os.linux.SIG.TERM, &act, null);
    terminal.disableCanonAndEcho();

    try std.io.getStdOut().writeAll("### LVM-3 Booted ###\n");

    const program_path = try utils.getProgramPathFromArgs() orelse return;
    try memory.loadProgram(program_path);

    try std.io.getStdOut().writeAll("### Program Loaded ###\n");

    registers.write(Reg.pc, program_start);
    registers.setCond(Cond.z); // One condition flag should always be set.

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
