// water.frag
extern float time; // We'll pass the current time from LÖVE to the shader

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // Create a distortion effect using sine waves
    vec2 uv = texture_coords;
    uv.x += sin(uv.y * 10.0 + time * 2.0) * 0.01; // Horizontal wave
    uv.y += cos(uv.x * 10.0 + time * 2.0) * 0.01; // Vertical wave

    // Sample the texture with the distorted coordinates
    vec4 pixel = Texel(texture, uv);
    return pixel * color;
}