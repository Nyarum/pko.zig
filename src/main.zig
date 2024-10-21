const std = @import("std");
const server = @import("server.zig");
const parsing = @import("parsing.zig");

pub fn main() !void {
    // Create an allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create an ArrayList to act as our buffer
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    const writer = buffer.writer().any();

    try parsing.writeString(writer, "Hello, world!");

    std.debug.print("{s}\n", .{buffer.items});

    try server.createServer("0.0.0.0", 1973);
}
