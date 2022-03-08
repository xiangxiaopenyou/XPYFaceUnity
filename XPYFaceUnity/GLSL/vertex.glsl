/// 顶点着色器
/// 输入一个4分量向量position，将postion拷贝到gl_Position输出

attribute vec4 position;
attribute vec4 inputTextureCoords;

varying vec2 textureCoords;

void main() {
    gl_Position = position;
    textureCoords = inputTextureCoords.xy;
}
