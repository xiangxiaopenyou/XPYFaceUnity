//
//  XPYGLDefines.m
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/3/11.
//

#import "XPYGLDefines.h"

NSString * const XPYGLVertexShaderString = GL_SHADER_STRING
(
 /// 输入一个4分量向量position，将postion拷贝到gl_Position输出
 attribute vec4 position;
 attribute vec4 inputTextureCoords;
 
 varying vec2 textureCoords;
 
 void main() {
    gl_Position = position;
    textureCoords = inputTextureCoords.xy;
 }
 );


NSString * const XPYGLRGBAFragmentShaderString = GL_SHADER_STRING
(
 varying highp vec2 textureCoords;
 /// 默认精度mediump
 precision mediump float;
 uniform sampler2D inTexture;

 void main() {
     vec4 rgba = texture2D(inTexture, textureCoords);
     gl_FragColor = vec4(rgba.rgb, 1.0);
 }
 );

NSString * const XPYGLYUVFullRangeFragmentShaderString = GL_SHADER_STRING
(
 varying highp vec2 textureCoords;
 
 precision mediump float;
 
 uniform sampler2D luminanceTexture;
 uniform sampler2D chrominanceTexture;
 /// 颜色变化矩阵
 uniform mediump mat3 colorMatrix;
 
 void main() {
    mediump vec3 yuv;
    lowp vec3 rgb;
    yuv.x = texture2D(luminanceTexture, textureCoords).r;
    yuv.yz = texture2D(chrominanceTexture, textureCoords).ra - vec2(0.5, 0.5);
    rgb = colorMatrix * yuv;
    gl_FragColor = vec4(rgb, 1.0);
 }
 );

NSString * const XPYGLYUVVideoRangeFragmentShaderString = GL_SHADER_STRING
(
 
 );

GLfloat kXPYGLColorMatrix601VideoRange[] = {
    1.164,  1.164, 1.164,
    0.0, -0.392, 2.017,
    1.596, -0.813,   0.0
};

GLfloat kXPYGLColorMatrix601FullRange[] = {
    1.0,    1.0,    1.0,
    0.0,    -0.343, 1.765,
    1.4,    -0.711, 0.0,
};

GLfloat kXPYGLColorMatrix709[] = {
    1.164,  1.164, 1.164,
    0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};

GLfloat *XPYGLColorMatrix601VideoRange = kXPYGLColorMatrix601VideoRange;
GLfloat *XPYGLColorMatrix601FullRange = kXPYGLColorMatrix601FullRange;
GLfloat *XPYGLColorMatrix709 = kXPYGLColorMatrix709;

