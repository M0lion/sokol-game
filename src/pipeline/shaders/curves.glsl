@vs vs
in vec2 position;
in vec2 uv;
in uint type;
in vec4 color0;

out vec2 v_uv;
out uint v_type;
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
		v_uv = uv;
		v_type = type;
}
@end

@fs fs
in vec2 v_uv;
flat in uint v_type;
in vec4 color;
out vec4 frag_color;

vec4 quadratic(vec2 uv_coord, vec4 input_color) {
    // Quadratic Bezier implicit equation: u² - v = 0
    float f = v_uv.x * v_uv.x - v_uv.y;

    // Antialiasing using gradients
    vec2 px = dFdx(v_uv);
    vec2 py = dFdy(v_uv);
    float fx = (2.0 * v_uv.x) * px.x - px.y;
    float fy = (2.0 * v_uv.x) * py.x - py.y;

		if (v_uv.x < 0) {
        f = -f;
        fx = -fx;
        fy = -fy;
    }

    float sd = f / sqrt(fx * fx + fy * fy);
    
    float alpha = 0.5 - sd;
    alpha = clamp(alpha, 0.0, 1.0);
    
    return vec4(color.rgb, color.a * alpha);
}

void main() {
	switch (v_type) {
		case 1u:
			frag_color = quadratic(v_uv, color);
			break;
		default:
			frag_color = color;
			break;
	}
}

//void main() {
//	// Quadratic Bezier implicit equation: u² - v = 0
//    float f = v_uv.x * v_uv.x - v_uv.y;
//    
//    // Solid fill below curve (for filled shapes)
//    float alpha = smoothstep(0.01, -0.01, f);
//    
//    // For solid quads, you can check if UV is in normal [0,1] range
//    // and skip curve logic, or use f < 0 will fill the whole quad
//    // if UVs are set to (0,0), (1,0), (0,1), (1,1)
//    
//    frag_color = vec4(color.rg, alpha, color.a * alpha);
//}
@end

@program triangle vs fs
