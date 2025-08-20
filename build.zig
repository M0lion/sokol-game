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
        },
    });

    for (mod_shader) |shader| {
        root_module.addImport(shader.name, shader.module);
    }

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

const Shader = struct {
    name: []const u8,
    module: *std.Build.Module,
};

fn buildShaders(b: *std.Build, dep_sokol: *std.Build.Dependency) ![]Shader {
    const allocator = b.allocator;
    var shaderFiles = try std.ArrayList([]const u8).initCapacity(allocator, 10);
    try findShaders(".", &shaderFiles, allocator);

    const mod_sokol = dep_sokol.module("sokol");
    const dep_shdc = dep_sokol.builder.dependency("shdc", .{});

    var modules = try std.ArrayList(Shader).initCapacity(allocator, 1);
    for (shaderFiles.items) |item| {
        const stem = std.fs.path.stem(item);
        const name = try std.fmt.allocPrint(allocator, "shader_{s}", .{stem});
        const output = try std.fmt.allocPrint(allocator, "{s}.zig", .{name});
        const module = try sokol.shdc.createModule(b, name, mod_sokol, .{
            .shdc_dep = dep_shdc,
            .input = item,
            .output = output,
            .slang = .{
                .glsl430 = true,
                .hlsl5 = true,
            },
        });
        try modules.append(allocator, .{
            .module = module,
            .name = name,
        });
    }

    return modules.items;
}

fn findShaders(path: []const u8, shaderFiles: *std.ArrayList([]const u8), allocator: std.mem.Allocator) !void {
    var dir = std.fs.cwd().openDir(path, .{ .iterate = true }) catch |err| switch (err) {
        error.FileNotFound => {
            std.log.warn("Shaders directory '{s}' not found, creating empty shader module", .{path});
            return;
        },
        else => return err,
    };
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |entry| {
        const shader_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ path, entry.name });
        if (entry.kind == .file and std.mem.endsWith(u8, entry.name, ".glsl")) {
            try shaderFiles.append(allocator, shader_path);
        } else if (entry.kind == std.fs.File.Kind.directory) {
            try findShaders(shader_path, shaderFiles, allocator);
        }
    }
}
