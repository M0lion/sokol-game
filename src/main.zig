const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const slog = sokol.log;
const shd = @import("shader_triangle");
const Vec = @import("math/vector.zig").Vec;
const Transform = @import("math/matrix.zig").Transform2D;
const cv = @import("pipeline/coloredVertex.zig");

const state = struct {
    var mesh: cv.ColoredVertexMesh = undefined;
    var pip: cv.ColoredVertexPipeline = undefined;
    var camera: Transform = Transform.identity();
    var x: f32 = 0;
};

export fn init() void {
    sg.setup(.{ .logger = .{ .func = slog.func }, .environment = sglue.environment() });

    state.pip = .init();
    // create vertex buffer with triangle vertices
    const data = [_]cv.ColoredVertex{
        // vertex 0: top, red
        .{ .pos = .{ .x = 0.0, .y = 0.5 }, .color = .{ 1.0, 0.0, 0.0, 1.0 } },
        // vertex 1: bottom right, green
        .{ .pos = .{ .x = 0.5, .y = -0.5 }, .color = .{ 0.0, 1.0, 0.0, 1.0 } },
        // vertex 2: bottom left, blue
        .{ .pos = .{ .x = -0.5, .y = -0.5 }, .color = .{ 0.0, 0.0, 1.0, 1.0 } },
    };
    const indices = [_]u16{ 0, 1, 2 };
    state.mesh = cv.ColoredVertexMesh.init(data[0..], indices[0..]);
}

export fn frame() void {
    sg.beginPass(.{ .swapchain = sglue.swapchain() });
    state.pip.apply(&state.camera);
    state.mesh.draw(&Transform.scale(std.math.cos(state.x)));
    sg.endPass();
    sg.commit();

    state.camera = state.camera.rotate(0.01);
    state.x += 0.01;
}

export fn cleanup() void {
    sg.shutdown();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 640,
        .height = 480,
        .icon = .{ .sokol_default = true },
        .window_title = "triangle.zig",
        .logger = .{ .func = slog.func },
    });
}
