const sokol = @import("sokol");
const sg = sokol.gfx;
const shd = @import("shader_curves");
const Vec = @import("../math/vector.zig").Vec;
const Transform = @import("../math/matrix.zig").Transform;
const MeshBuider = @import("../meshBuilder.zig").MeshBuilder(CurveVertex);

pub const CurveVertex = struct {
    pos: Vec,
    uv: Vec,
    type: u32,
    color: [4]f32,
};

pub const CurveVertexMesh = struct {
    vertices: sg.Buffer,
    vertices_num: usize,
    indices: sg.Buffer,
    indices_num: usize,
    bindings: sg.Bindings,

    pub fn init(data: []const CurveVertex, index_data: []const u16) @This() {
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

    pub fn fromBuilder(meshBuilder: *const MeshBuider) CurveVertexMesh {
        return CurveVertexMesh.init(meshBuilder.vertices.items, meshBuilder.indices.items);
    }

    pub fn draw(self: @This(), transform: *const Transform) void {
        sg.applyBindings(self.bindings);
        sg.applyUniforms(1, sg.asRange(&transform.toMat4()));
        sg.draw(0, @intCast(self.indices_num), 1);
    }
};

pub const CurveVertexPipeline = struct {
    pipeline: sg.Pipeline,

    pub fn init() CurveVertexPipeline {
        const pipeline = sg.makePipeline(.{
            .shader = sg.makeShader(shd.triangleShaderDesc(sg.queryBackend())),
            .index_type = .UINT16,
            .layout = init: {
                var l = sg.VertexLayoutState{};
                l.attrs[shd.ATTR_triangle_position].format = .FLOAT2;
                l.attrs[shd.ATTR_triangle_uv].format = .FLOAT2;
                l.attrs[shd.ATTR_triangle_type].format = .UINT;
                l.attrs[shd.ATTR_triangle_color0].format = .FLOAT4;
                break :init l;
            },
            .colors = init: {
                var colors = [4]sg.ColorTargetState{
                    sg.ColorTargetState{}, // Initialize all 4 slots
                    sg.ColorTargetState{},
                    sg.ColorTargetState{},
                    sg.ColorTargetState{},
                };
                // Only configure the first color target for blending
                colors[0].blend = .{
                    .enabled = true,
                    .src_factor_rgb = .SRC_ALPHA,
                    .dst_factor_rgb = .ONE_MINUS_SRC_ALPHA,
                    .src_factor_alpha = .ONE,
                    .dst_factor_alpha = .ONE_MINUS_SRC_ALPHA,
                };
                break :init colors;
            },
        });

        return CurveVertexPipeline{
            .pipeline = pipeline,
        };
    }

    pub fn apply(self: @This(), camera: *Transform) void {
        sg.applyPipeline(self.pipeline);
        sg.applyUniforms(0, sg.asRange(&camera.toMat4()));
    }
};
