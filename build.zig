const std = @import("std");
const sokol = @import("sokol");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });

    const mod_shader = try buildShaders(b, dep_sokol);

    const root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "sokol",
                .module = dep_sokol.module("sokol"),
            },
            .{
                .name = "shader",
                .module = mod_shader,
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

fn buildShaders(b: *std.Build, dep_sokol: *std.Build.Dependency) !*std.Build.Module {
    const mod_sokol = dep_sokol.module("sokol");
    const dep_shdc = dep_sokol.builder.dependency("shdc", .{});
    const mod_shd = try sokol.shdc.createModule(b, "shader", mod_sokol, .{
        .shdc_dep = dep_shdc,
        .input = "src/shaders/triangle.glsl",
        .output = "shader.zig",
        .slang = .{
            .glsl430 = true,
            .hlsl5 = true,
        },
    });

    return mod_shd;
}
