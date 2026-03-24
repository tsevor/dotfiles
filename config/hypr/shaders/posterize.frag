#version 300 es
precision mediump float;

out vec4 FragColor;
in vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 color = texture(tex, v_texcoord);
    int r = int(color.r * 255.0);
    int g = int(color.g * 255.0);
    int b = int(color.b * 255.0);
    FragColor = vec4(
        float(((r << 2) | (r >> 2)) & 0xf0 | r & 0xf) / 255.0,
        float(((g << 2) | (g >> 2)) & 0xf0 | r & 0xf) / 255.0,
        float(((b << 2) | (b >> 2)) & 0xf0 | r & 0xf) / 255.0,
        color.a
    );
}
