/// 片元着色器
/// 默认精度mediump

precision mediump float;

uniform sampler2D inTexture;
varying vec2 textureCoords;

void main() {
    vec4 rgba = texture2D(inTexture, textureCoords);
    gl_FragColor = vec4(rgba.rgb, 1.0);
}

