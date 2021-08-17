/// 顶点着色器
/// 输入一个4分量向量position，将postion拷贝到gl_Position输出
/// 输入一个4分量向量color，定义变量outColor，用于与片元着色器的颜色传递

attribute vec4 position;
attribute vec4 color;

varying vec4 outColor;

void main() {
    gl_Position = position;
    outColor = color;
}
