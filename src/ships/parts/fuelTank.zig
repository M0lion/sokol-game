const std = @import("std");
const cv = @import("../../pipeline/coloredVertex.zig");
const Transform = @import("../../math/matrix.zig").Transform2D;
const MeshBuilder = @import("../../meshBuilder.zig").MeshBuilder(cv.ColoredVertex);
const Vec = @import("../../math/vector.zig").Vec;

pub const FuelTankDescriptor = struct {
    height: f32,
    widht: f32,

    pub fn buildMesh(self: @This(), meshBuilder: *MeshBuilder, transform: Transform) !void {
        const color = [_]f32{ 1, 0, 0, 1 };

        const a = try addVerex(meshBuilder, transform, color, 0, 0);
        const b = try addVerex(meshBuilder, transform, color, self.widht, 0);
        const c = try addVerex(meshBuilder, transform, color, 0, self.height);
        const d = try addVerex(meshBuilder, transform, color, self.widht, self.height);

        try meshBuilder.addIndex(a);
        try meshBuilder.addIndex(b);
        try meshBuilder.addIndex(c);
        try meshBuilder.addIndex(b);
        try meshBuilder.addIndex(d);
        try meshBuilder.addIndex(c);
    }
};

fn addVerex(meshBuilder: *MeshBuilder, transform: Transform, color: [4]f32, x: f32, y: f32) !u16 {
    const pos = Vec{
        .x = x,
        .y = y,
    };
    return try meshBuilder.addVertex(.{
        .color = color,
        .pos = transform.transformPoint(pos),
    });
}
