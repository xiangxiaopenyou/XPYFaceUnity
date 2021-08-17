/// 片元着色器
/// 默认精度mediump
/// 将顶点着色器输出的outColor拷贝到gl_FragColor

precision mediump float;
varying vec4 outColor;
void main() {
    gl_FragColor = outColor;
}
