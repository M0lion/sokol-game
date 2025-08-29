const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const slog = sokol.log;
const shd = @import("shader_triangle");
const Vec = @import("math/vector.zig").Vec;
const Transform = @import("math/matrix.zig").Transform;
const cv = @import("pipeline/coloredVertex.zig");
const curves = @import("pipeline/curveVertex.zig");
const parts = @import("ships/parts.zig");
const MeshBuilder = @import("meshBuilder.zig").MeshBuilder(curves.CurveVertex);

const state = struct {
    var mesh: curves.CurveVertexMesh = undefined;
    var pip: curves.CurveVertexPipeline = undefined;
    var camera: Transform = Transform.scale(0.5);
    var x: f32 = 0;
};

export fn init() void {
    sg.setup(.{ .logger = .{ .func = slog.func }, .environment = sglue.environment() });

    state.pip = .init();
    // create vertex buffer with triangle vertices
    var ft = parts.fuelTank.FuelTankDescriptor{
        .widht = 1,
        .height = 2,
    };

    var meshBuilder = MeshBuilder.initCapacity(std.heap.page_allocator, 1, 1) catch {
        @panic("failed to init meshbuilder");
    };

    ft.buildMesh(&meshBuilder, Transform.identity()) catch {
        @panic("failed to build mesh");
    };

    ft.widht = 2;
    ft.height = 1;
    ft.buildMesh(&meshBuilder, Transform.translation(1, 2)) catch {
        @panic("failed to build mesh");
    };

    state.mesh = curves.CurveVertexMesh.fromBuilder(&meshBuilder);
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
