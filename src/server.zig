const std = @import("std");
const net = std.net;

pub fn createServer(addr: []const u8, port: u16) !void {
    // Define the server's listening address using the existing 'Address' type
    const listen_addr = try net.Address.parseIp(addr, port);

    // Create a Server object to listen on the specified address
    var server = try net.Address.listen(listen_addr, .{});

    std.log.info("TCP server listening on {s}:{d}", .{ addr, port });

    while (true) {
        // Accept incoming connections using the Server's accept() method
        var conn = try server.accept();
        defer conn.stream.close();

        std.log.info("New connection from: {any}", .{conn.address});

        try handleConnection(&conn);
    }
}

fn handleConnection(conn: *net.Server.Connection) !void {
    var buf: [1024]u8 = undefined;

    while (true) {
        const bytes_read = try conn.stream.read(&buf);
        if (bytes_read == 0) break; // Connection closed by client

        const msg = buf[0..bytes_read];
        std.log.info("Received message: {s}", .{msg});

        // Echo the message back to the client
        try conn.stream.writeAll(msg);
    }
}
