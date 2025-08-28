const sokol = @import("sokol");
const sg = sokol.gfx;
const shd = @import("shader_triangle");
const Vec = @import("../math/vector.zig").Vec;
const Transform = @import("../math/matrix.zig").Transform2D;
const MeshBuider = @import("../meshBuilder.zig").MeshBuilder(ColoredVertex);

pub const ColoredVertex = struct {
    pos: Vec,
    color: [4]f32,
};

pub const ColoredVertexMesh = struct {
    vertices: sg.Buffer,
    vertices_num: usize,
    indices: sg.Buffer,
    indices_num: usize,
    bindings: sg.Bindings,

    pub fn init(data: []const ColoredVertex, index_data: []const u16) @This() {
        const vertices = sg.makeBuffer(.{
            .data = sg.asRange(data),
            .usage = .{
                .vertex_buffer = true,
            },
        });

        const indices = sg.makeBuffer(.{
            .data = sg.asRange(index_data),
            .usage = .{
                .index_buffer = true,
            },
        });

        var bindings = sg.Bindings{};
        bindings.vertex_buffers[0] = vertices;
        bindings.index_buffer = indices;

        return .{
            .vertices = vertices,
            .vertices_num = data.len,
            .indices = indices,
            .indices_num = index_data.len,
            .bindings = bindings,
        };
    }

    pub fn fromBuilder(meshBuilder: *const MeshBuider) ColoredVertexMesh {
        return ColoredVertexMesh.init(meshBuilder.vertices.items, meshBuilder.indices.items);
    }

    pub fn draw(self: @This(), transform: *const Transform) void {
        sg.applyBindings(self.bindings);
        sg.applyUniforms(1, sg.asRange(&transform.toMat4()));
        sg.draw(0, @intCast(self.indices_num), 1);
    }
};

pub const ColoredVertexPipeline = struct {
    pipeline: sg.Pipeline,

    pub fn init() ColoredVertexPipeline {
        const pipeline = sg.makePipeline(.{
            .shader = sg.makeShader(shd.triangleShaderDesc(sg.queryBackend())),
            .index_type = .UINT16,
            .layout = init: {
                var l = sg.VertexLayoutState{};
                l.attrs[shd.ATTR_triangle_position].format = .FLOAT2;
                l.attrs[shd.ATTR_triangle_color0].format = .FLOAT4;
                break :init l;
            },
        });

        return ColoredVertexPipeline{
            .pipeline = pipeline,
        };
    }

    pub fn apply(self: @This(), camera: *Transform) void {
        sg.applyPipeline(self.pipeline);
        sg.applyUniforms(0, sg.asRange(&camera.toMat4()));
    }
};
