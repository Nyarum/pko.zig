const std = @import("std");
const server = @import("server.zig");
const parsing = @import("parsing.zig");
const packet = @import("packet.zig");
const time = @import("time.zig");
pub fn main() !void {
    const buffer = try packet.writeOpcodeAndTime();
    const headerWithPacket = try packet.writeHeaderAndPacket([20]u8, buffer);

    for (headerWithPacket) |byte| {
        std.debug.print("{x} ", .{byte});
    }
    std.debug.print("\n", .{});

    try server.createServer("0.0.0.0", 1973);
}
