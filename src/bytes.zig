pub fn FixedSizeBuffer(comptime T: type) type {
    return struct {
        buffer: T,
        len: usize,
    };
}
