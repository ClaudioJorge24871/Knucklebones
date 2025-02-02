extern float time;

// Apply smooth organic distortion
vec2 distortUV(vec2 uv) {
    float offsetX = sin(uv.y * 10.0 + time * 1.5) * 0.02;
    float offsetY = cos(uv.x * 12.0 + time * 1.2) * 0.02;
    
    uv.x += offsetX;
    uv.y += offsetY;
    
    return uv;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    
    // Apply distortion
    uv = distortUV(uv);

    // More wave-like distortions
    float wave1 = sin(uv.y * 8.0 + time * 2.0) * 0.015;
    float wave2 = cos(uv.x * 10.0 + time * 2.5) * 0.015;
    
    uv.x += wave1;
    uv.y += wave2;

    vec4 pixel = Texel(texture, uv);
    return pixel * color;
}
