const std = @import("std");
const net = std.net;
const handle = @import("handle.zig");

pub fn createServer(addr: []const u8, port: u16) !void {
    // Define the server's listening address using the existing 'Address' type
    const listen_addr = try net.Address.parseIp(addr, port);

    // Create a Server object to listen on the specified address
    var server = try net.Address.listen(listen_addr, .{
        .reuse_address = true,
        .force_nonblocking = true,
    });

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    var allocator = gpa.allocator();
    const pool = allocator.create(std.Thread.Pool) catch unreachable;
    try pool.init(.{ .allocator = allocator });

    std.log.info("TCP server listening on {s}:{d}", .{ addr, port });

    handle.init();
    try pool.spawn(handle.handleConnections, .{});

    while (true) {
        // Accept incoming connections using the Server's accept() method
        var conn = server.accept() catch {
            std.time.sleep(10);
            continue;
        };

        std.log.info("New connection from: {any}", .{conn.address});

        try pool.spawn(handle.addConnection, .{&conn});
    }
}
