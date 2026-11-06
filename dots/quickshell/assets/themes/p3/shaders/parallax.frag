#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float offsetX;           // Mouse X offset [-1, 1]
    float offsetY;           // Mouse Y offset [-1, 1]
    float parallaxStrength;  // Parallax intensity
    float aspectRatio;       // Image aspect ratio (width/height)
};

layout(binding = 1) uniform sampler2D source;     // Original image
layout(binding = 2) uniform sampler2D depthMap;   // Depth map

void main() {
    vec2 uv = qt_TexCoord0;
    
    // Parallax vector based on mouse cursor
    vec2 offset = vec2(offsetX, -offsetY) * parallaxStrength;
    
    // Smooth 2-tap parallax occlusion approximation (zero loops, instant evaluation)
    float depth1 = texture(depthMap, uv).r;
    vec2 uvMid = uv + offset * (depth1 - 0.5) * 0.5;
    float depth2 = texture(depthMap, uvMid).r;
    vec2 sampleUV = clamp(uv + offset * (depth2 - 0.5), vec2(0.001), vec2(0.999));
    
    fragColor = texture(source, sampleUV) * qt_Opacity;
}
