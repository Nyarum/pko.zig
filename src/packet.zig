const time = @import("time.zig");
const std = @import("std");
const bytes = @import("bytes.zig");

pub fn writeOpcodeAndTime() !bytes.FixedSizeBuffer([20]u8) {
    // Create a temporary buffer to hold the packet data
    var packetBuffer: [20]u8 = undefined; // Adjust size as needed
    var packetStream = std.io.fixedBufferStream(&packetBuffer);

    // Opcode 940 in little-endian format
    var opcode: [2]u8 = [_]u8{ 0x03, 0xAC }; // 940 is 0x03AC in hex

    // Get the current time in seconds since epoch
    const now = try time.getCurrentTime();

    // Write opcode
    _ = try packetStream.write(&opcode);

    // Write current time as u8
    _ = try packetStream.write(now.buffer[0..now.len]);

    return bytes.FixedSizeBuffer([20]u8){ .buffer = packetBuffer, .len = try packetStream.getPos() };
}

pub fn writeHeaderAndPacket(comptime T: type, packet: bytes.FixedSizeBuffer(T)) ![]u8 {
    // Create a temporary buffer to hold the packet data
    var packetBuffer: [16948]u8 = undefined; // Adjust size as needed
    var packetStream = std.io.fixedBufferStream(&packetBuffer);

    const packetWritten = packet.buffer[0..packet.len];

    var lenBytes: [2]u8 = [_]u8{ @intCast(packetWritten.len & 0xFF), @intCast((packetWritten.len >> 8) & 0xFF) };
    _ = try packetStream.write(&lenBytes);

    // Write the fixed bytes 0x80 00 00 00
    var fixedBytes: [4]u8 = [_]u8{ 0x80, 0x00, 0x00, 0x00 };
    _ = try packetStream.write(&fixedBytes);

    // Write the packet data
    _ = try packetStream.write(packetWritten);

    return packetStream.getWritten();
}
