const std = @import("std");
const client = @import("client.zig");

var clients: std.ArrayList(*client.Client) = undefined;
var connectionQueue: std.ArrayList(*std.net.Server.Connection) = undefined;

pub fn init() void {
    clients = std.ArrayList(*client.Client).init(std.heap.page_allocator);
    connectionQueue = std.ArrayList(*std.net.Server.Connection).init(std.heap.page_allocator);
}

pub fn addConnection(conn: *std.net.Server.Connection) void {
    connectionQueue.append(conn) catch unreachable;
}

pub fn handleConnections() void {
    while (true) {
        // Move new connections from the queue to the main list
        while (connectionQueue.items.len > 0) {
            const conn = connectionQueue.items[0];
            connectionQueue.items = connectionQueue.items[1..];

            const newClient = std.heap.page_allocator.create(client.Client) catch |err| {
                std.debug.print("Failed to allocate memory for new client: {any}\n", .{err});
                break;
            };
            client.init(newClient, conn);
            clients.append(newClient) catch unreachable;
        }

        for (clients.items, 0..) |cl, i| {
            const bytes_read = cl.conn.stream.read(&cl.buf) catch |err| {
                if (err == error.WouldBlock) {
                    continue;
                } else {
                    std.debug.print("Failed to read from client: {any}\n", .{err});
                    std.heap.page_allocator.destroy(cl);
                    _ = clients.swapRemove(i);
                    continue;
                }
            };
            if (bytes_read == 0) {
                std.heap.page_allocator.destroy(cl);
                _ = clients.swapRemove(i);
                break; // Connection closed by client
            }

            const msg = cl.buf[0..bytes_read];

            client.handle(cl, msg);
        }

        std.time.sleep(10);
    }
}
