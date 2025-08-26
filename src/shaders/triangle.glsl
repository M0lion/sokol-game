@vs vs
in vec2 position;
in vec4 color0;

out vec4 color;

layout(binding = 0) uniform camera_uniforms {
    mat4 camera;
};

layout(binding = 1) uniform model_uniforms {
    mat4 model;
};

void main() {
    gl_Position = camera * model * vec4(position, 0.0, 1.0);
    color = color0;
}
@end

@fs fs
in vec4 color;
out vec4 frag_color;

void main() {
    frag_color = color;
}
@end

@program triangle vs fs
