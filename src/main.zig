const std = @import("std");
const sokol = @import("sokol");
const sapp = sokol.app;
const sglue = sokol.glue;
const slog = sokol.log;

export fn init() void {}

export fn frame() void {}

export fn cleanup() void {}

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
