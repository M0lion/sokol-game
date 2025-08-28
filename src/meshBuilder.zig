const std = @import("std");

pub fn MeshBuilder(comptime T: type) type {
    return struct {
        const Self = @This();
        vertices: std.ArrayList(T),
        indices: std.ArrayList(u16),
        allocator: std.mem.Allocator,

        pub fn initCapacity(allocator: std.mem.Allocator, vert_num: usize, index_num: usize) !Self {
            return .{
                .allocator = allocator,
                .vertices = try std.ArrayList(T).initCapacity(allocator, vert_num),
                .indices = try std.ArrayList(u16).initCapacity(allocator, index_num),
            };
        }

        pub fn addVertex(self: *Self, vertex: T) !u16 {
            try self.vertices.append(self.allocator, vertex);
            return @intCast(self.vertices.items.len - 1);
        }

        pub fn addIndex(self: *Self, index: u16) !void {
            try self.indices.append(self.allocator, index);
        }
    };
}
