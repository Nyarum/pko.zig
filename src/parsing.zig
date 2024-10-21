const std = @import("std");

pub fn readUint8(stream: std.io.AnyReader) !u8 {
    var buf: [1]u8 = undefined;
    _ = try stream.read(&buf);
    return buf[0];
}

pub fn readUint16(stream: std.io.AnyReader) !u16 {
    var buf: [2]u8 = undefined;
    _ = try stream.read(&buf);
    return @as(u16, @bitCast(buf[0])) | (@as(u16, @bitCast(buf[1])) << 8);
}

pub fn readUint16LittleEndian(stream: std.io.AnyReader) !u16 {
    var buf: [2]u8 = undefined;
    _ = try stream.read(&buf);
    return @as(u16, @bitCast(buf[1])) | (@as(u16, @bitCast(buf[0])) << 8);
}

pub fn readUint32(stream: std.io.AnyReader) !u32 {
    var buf: [4]u8 = undefined;
    _ = try stream.read(&buf);
    return @as(u32, @bitCast(buf[0])) |
        (@as(u32, @bitCast(buf[1])) << 8) |
        (@as(u32, @bitCast(buf[2])) << 16) |
        (@as(u32, @bitCast(buf[3])) << 24);
}

pub fn readUint32LittleEndian(stream: std.io.AnyReader) !u32 {
    var buf: [4]u8 = undefined;
    _ = try stream.read(&buf);
    return @as(u32, @bitCast(buf[3])) |
        (@as(u32, @bitCast(buf[2])) << 8) |
        (@as(u32, @bitCast(buf[1])) << 16) |
        (@as(u32, @bitCast(buf[0])) << 24);
}

pub fn readString(stream: std.io.AnyReader, allocator: std.mem.Allocator) ![]u8 {
    const len = try readUint16LittleEndian(stream);
    const buffer = try allocator.alloc(u8, len);
    errdefer allocator.free(buffer);

    const bytes_read = try stream.readAll(buffer);
    if (bytes_read != len) {
        return error.UnexpectedEOF;
    }

    return buffer;
}

pub fn writeUint8(stream: std.io.AnyWriter, value: u8) !void {
    var buf: [1]u8 = undefined;
    buf[0] = value;
    try stream.writeAll(&buf);
}

pub fn writeUint16(stream: std.io.AnyWriter, value: u16) !void {
    var buf: [2]u8 = undefined;
    buf[0] = @truncate(value);
    buf[1] = @truncate(value >> 8);
    try stream.writeAll(&buf);
}

pub fn writeUint16LittleEndian(stream: std.io.AnyWriter, value: u16) !void {
    var buf: [2]u8 = undefined;
    buf[1] = @truncate(value);
    buf[0] = @truncate(value >> 8);
    try stream.writeAll(&buf);
}

pub fn writeUint32(stream: std.io.AnyWriter, value: u32) !void {
    var buf: [4]u8 = undefined;
    buf[0] = @truncate(value);
    buf[1] = @truncate(value >> 8);
    buf[2] = @truncate(value >> 16);
    buf[3] = @truncate(value >> 24);
    try stream.writeAll(&buf);
}

pub fn writeUint32LittleEndian(stream: std.io.AnyWriter, value: u32) !void {
    var buf: [4]u8 = undefined;
    buf[3] = @truncate(value);
    buf[2] = @truncate(value >> 8);
    buf[1] = @truncate(value >> 16);
    buf[0] = @truncate(value >> 24);
    try stream.writeAll(&buf);
}

pub fn writeString(stream: std.io.AnyWriter, value: []const u8) !void {
    if (value.len > std.math.maxInt(u16)) {
        return error.StringTooLong;
    }
    try writeUint16LittleEndian(stream, @intCast(value.len));
    try stream.writeAll(value);
}
