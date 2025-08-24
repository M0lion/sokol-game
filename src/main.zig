const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const slog = sokol.log;
const shd = @import("shader_triangle");
const Vec = @import("math/vector.zig").Vec;

const state = struct {
    var bind: sg.Bindings = .{};
    var pip: sg.Pipeline = .{};
};

const ColoredVertex = struct {
    pos: Vec,
    color: [4]f32,
};

export fn init() void {
    sg.setup(.{ .logger = .{ .func = slog.func }, .environment = sglue.environment() });

    // create vertex buffer with triangle vertices
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]ColoredVertex{
            // vertex 0: top, red
            .{ .pos = .{ .x = 0.0, .y = 0.5 }, .color = .{ 1.0, 0.0, 0.0, 1.0 } },
            // vertex 1: bottom right, green
            .{ .pos = .{ .x = 0.5, .y = -0.5 }, .color = .{ 0.0, 1.0, 0.0, 1.0 } },
            // vertex 2: bottom left, blue
            .{ .pos = .{ .x = -0.5, .y = -0.5 }, .color = .{ 0.0, 0.0, 1.0, 1.0 } },
        }),
    });

    // create a shader and pipeline object
    state.pip = sg.makePipeline(.{
        .shader = sg.makeShader(shd.triangleShaderDesc(sg.queryBackend())),
        .layout = init: {
            var l = sg.VertexLayoutState{};
            l.attrs[shd.ATTR_triangle_position].format = .FLOAT2;
            l.attrs[shd.ATTR_triangle_color0].format = .FLOAT4;
            break :init l;
        },
    });
}

export fn frame() void {
    sg.beginPass(.{ .swapchain = sglue.swapchain() });
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    sg.draw(0, 3, 1);
    sg.endPass();
    sg.commit();
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
