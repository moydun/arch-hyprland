#version 300 es
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;
void main() {
    vec4 c = texture(tex, v_texcoord);
    float scan = 0.94 + 0.06 * sin(v_texcoord.y * 1080.0 * 3.14159);
    fragColor = vec4(c.rgb * scan, c.a);
}
