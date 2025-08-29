const std = @import("std");
const curves = @import("../../pipeline/curveVertex.zig");
const Transform = @import("../../math/matrix.zig").Transform;
const MeshBuilder = @import("../../meshBuilder.zig").MeshBuilder(curves.CurveVertex);
const Vec = @import("../../math/vector.zig").Vec;

pub const FuelTankDescriptor = struct {
    height: f32,
    widht: f32,

    pub fn buildMesh(self: @This(), meshBuilder: *MeshBuilder, transform: Transform) !void {
        const color = [_]f32{ 1, 0, 0, 1 };

        const bottomLeft = Vec{
            .x = 0,
            .y = 0,
        };
        const bottomRight = Vec{
            .x = self.widht,
            .y = 0,
        };
        const topLeft = Vec{
            .x = 0,
            .y = self.height,
        };
        const topRight = Vec{
            .x = self.widht,
            .y = self.height,
        };

        const a = try addVerex(meshBuilder, transform, color, bottomLeft, 0, 0, 1);
        const b = try addVerex(meshBuilder, transform, color, topLeft, 0.5, 0, 1);
        const c = try addVerex(meshBuilder, transform, color, topRight, 1, 1, 1);
        const d = try addVerex(meshBuilder, transform, color, topRight, 0, 0, 0);
        const e = try addVerex(meshBuilder, transform, color, bottomRight, 0, 0, 0);
        const f = try addVerex(meshBuilder, transform, color, bottomLeft, 0, 0, 0);

        try meshBuilder.addIndex(a);
        try meshBuilder.addIndex(b);
        try meshBuilder.addIndex(c);
        try meshBuilder.addIndex(d);
        try meshBuilder.addIndex(f);
        try meshBuilder.addIndex(e);
    }
};

fn addVerex(meshBuilder: *MeshBuilder, transform: Transform, color: [4]f32, pos: Vec, uvx: f32, uvy: f32, vtype: u32) !u16 {
    return try meshBuilder.addVertex(.{
        .color = color,
        .pos = transform.transformPoint(pos),
        .uv = .{
            .x = uvx,
            .y = uvy,
        },
        .type = vtype,
    });
}
