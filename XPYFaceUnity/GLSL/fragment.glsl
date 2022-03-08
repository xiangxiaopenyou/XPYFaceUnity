/// 片元着色器
/// 默认精度mediump

precision mediump float;

uniform sampler2D inTexture;
varying vec2 textureCoords;

void main() {
    vec4 rgba = texture2D(inTexture, textureCoords);
    // vec4 alpha = texture2D(inTexture, textureCoords + vec2(-0.5, 0.0));
    gl_FragColor = vec4(rgba.rgb, 1.0);
}
