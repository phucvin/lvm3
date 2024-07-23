const std = @import("std");
const registers = @import("registers.zig");
const memory = @import("memory.zig");

const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();
const Reg = registers.Reg;

pub const Vec = enum(u8) {
    getc = 0x20,
    out = 0x21,
    puts = 0x22,
    in = 0x23,
    putsp = 0x24,
    halt = 0x25,
};

/// Read a character from the keyboard and store it in R0.
pub fn getc() !void {
    const c = try stdin.reader().readByte();
    registers.write(Reg.r0, c);
}

/// Write the character in R0 to the console.
pub fn out() !void {
    const c = registers.read(Reg.r0);
    try stdout.writer().writeByte(@truncate(c));
}

/// Write a string of characters from memory to the console.
pub fn puts() !void {
    var addr = registers.read(Reg.r0);
    while (true) : (addr += 1) {
        const c = memory.read(addr);
        if (c == 0) {
            break;
        }
        try stdout.writer().writeByte(@truncate(c));
    }
}

/// Prompt the user to enter a character and store it in R0.
pub fn in() !void {
    try stdout.writeAll("Enter a character: ");
    const c = try stdin.reader().readByte();
    registers.write(Reg.r0, c);
}

/// Write a string of characters from memory to the console, where two characters are
/// stored in each memory location.
pub fn putsp() !void {
    var addr = registers.read(Reg.r0);
    while (true) : (addr += 1) {
        const cs = memory.read(addr);
        if (cs == 0) {
            break;
        }
        const c1 = cs & 0xFF;
        const c2 = cs >> 8;
        try stdout.writer().writeByte(@truncate(c1));
        // Second byte may be null if the string is odd-length.
        if (c2 != 0) {
            try stdout.writer().writeByte(@truncate(c2));
        }
    }
}

/// Halt program execution.
pub fn halt() !void {
    try stdout.writeAll("Halting execution.\n");
    std.process.exit(0);
}
