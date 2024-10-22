const std = @import("std");

pub const Client = struct {
    buf: [8192]u8 = undefined,
    conn: *std.net.Server.Connection,
    lastMsg: []u8,
};

pub fn init(client: *Client, conn: *std.net.Server.Connection) void {
    client.* = Client{ .conn = conn, .lastMsg = "" };
}

pub fn handle(client: *Client, data: []u8) void {
    std.log.info("Received message: {s}", .{data});
    std.log.info("Last message: {s}", .{client.lastMsg});

    client.lastMsg = data;

    client.conn.stream.writeAll(data) catch unreachable;
}
