const std = @import("std");

var connections: std.ArrayList(*std.net.Server.Connection) = undefined;
var connectionQueue: std.ArrayList(*std.net.Server.Connection) = undefined;

pub fn init() void {
    connections = std.ArrayList(*std.net.Server.Connection).init(std.heap.page_allocator);
    connectionQueue = std.ArrayList(*std.net.Server.Connection).init(std.heap.page_allocator);
}

pub fn addConnection(conn: *std.net.Server.Connection) void {
    connectionQueue.append(conn) catch unreachable;
}

pub fn handleConnections() void {
    var buf: [1024]u8 = undefined;

    while (true) {
        // Move new connections from the queue to the main list
        while (connectionQueue.items.len > 0) {
            const conn = connectionQueue.items[0];
            connectionQueue.items = connectionQueue.items[1..];
            connections.append(conn) catch unreachable;
        }

        for (connections.items) |conn| {
            const bytes_read = conn.stream.read(&buf) catch {
                continue;
            };
            if (bytes_read == 0) break; // Connection closed by client

            const msg = buf[0..bytes_read];
            std.log.info("Received message: {s}", .{msg});

            // Echo the message back to the client
            conn.stream.writeAll(msg) catch unreachable;
        }

        std.time.sleep(10);
    }
}
