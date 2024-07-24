const std = @import("std");

/// Sign extend a number represented by a given number of bits to 16 bits.
pub fn sext(num: u16, comptime og_bits: u4) u16 {
    if (og_bits == 0) {
        return 0;
    }
    const shift = 16 - @as(u16, og_bits);
    // Need to cast to i16 to ensure arithmetic right shift.
    return @bitCast(@as(i16, @bitCast(num << shift)) >> shift);
}

/// Get the path to the program from the command line arguments.
pub fn getProgramPathFromArgs() ?[]const u8 {
    var args = try std.process.argsWithAllocator(std.heap.page_allocator);
    defer args.deinit();
    if (args.inner.count != 2) {
        std.debug.print("Usage: lvm3 <path to program>\n", .{});
        return null;
    }
    _ = args.skip();
    return args.next().?;
}

test "sign extend" {
    try std.testing.expectEqual(0b0000_0000_0000_0000, sext(0b1111_1111_1111_1111, 0));
    try std.testing.expectEqual(0b0000_0000_0000_0000, sext(0b1000_0000_0000_0000, 1));
    try std.testing.expectEqual(0b1111_1111_1111_1111, sext(0b0000_0000_0000_0001, 1));
    try std.testing.expectEqual(0b0000_0000_0011_1111, sext(0b1111_1111_1011_1111, 7));
    try std.testing.expectEqual(0b1111_1111_1101_0101, sext(0b0000_0000_0101_0101, 7));
    try std.testing.expectEqual(0b0000_0000_0000_0000, sext(0b1111_0000_0000_0000, 12));
    try std.testing.expectEqual(0b1111_1111_0000_1111, sext(0b0000_1111_0000_1111, 12));
    try std.testing.expectEqual(0b0010_0000_0000_0000, sext(0b0010_0000_0000_0000, 15));
    try std.testing.expectEqual(0b1100_0000_0000_0000, sext(0b0100_0000_0000_0000, 15));
}
