pub const Vec = struct {
    x: f32,
    y: f32,

    pub fn add(self: Vec, other: Vec) Vec {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }
};
