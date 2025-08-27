const std = @import("std");
const cv = @import("../../pipeline/coloredVertex.zig");
const Transform = @import("../../math/matrix.zig").Transform2D;

pub const FuelTankDescriptor = struct {
    height: f32,
    widht: f32,

    pub fn getMesh(self: @This(), allocator: std.mem.Allocator, transform: Transform) !cv.ColoredVertexMesh {
        var vertices = try std.ArrayList(cv.ColoredVertex).initCapacity(allocator, 1);
        var indices = try std.ArrayList(u16).initCapacity(allocator, 1);

        const color = [_]f32{ 1, 0, 0, 1 };

        try addVerex(allocator, &vertices, color, 0, 0);
        try addVerex(allocator, &vertices, color, self.widht, 0);
        try addVerex(allocator, &vertices, color, 0, self.height);
        try addVerex(allocator, &vertices, color, self.widht, self.height);

        try indices.append(allocator, 0);
        try indices.append(allocator, 1);
        try indices.append(allocator, 2);
        try indices.append(allocator, 1);
        try indices.append(allocator, 3);
        try indices.append(allocator, 2);

        for (vertices.items) |*vertex| {
            vertex.pos = transform.transformPoint(vertex.pos);
        }

        return cv.ColoredVertexMesh.init(vertices.items, indices.items);
    }
};

fn addVerex(allocator: std.mem.Allocator, vertices: *std.ArrayList(cv.ColoredVertex), color: [4]f32, x: f32, y: f32) !void {
    try vertices.append(allocator, .{
        .color = color,
        .pos = .{
            .x = x,
            .y = y,
        },
    });
}
