const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });

    const root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "sokol",
                .module = dep_sokol.module("sokol"),
            },
        },
    });

    const exe = b.addExecutable(.{
        .name = "sokol_game",
        .root_module = root_module,
    });

    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    b.step("run", "Run the app").dependOn(&run.step);

    if (b.args) |args| {
        run.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = root_module,
    });

    const run_tests = b.addRunArtifact(exe_tests);
    b.step("test", "Run tests").dependOn(&run_tests.step);
}
