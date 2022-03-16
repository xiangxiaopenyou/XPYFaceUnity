//
//  XPYGLDefines.h
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/3/11.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>

#define GL_SHADER_STRING(x) @#x

#pragma mark - Shader string

extern NSString * const XPYGLVertexShaderString;                // 顶点着色器
extern NSString * const XPYGLRGBAFragmentShaderString;          // RGBA
extern NSString * const XPYGLYUVFullRangeFragmentShaderString;  // 420f
extern NSString * const XPYGLYUVVideoRangeFragmentShaderString; // 420v

#pragma mark - Color matrix

extern GLfloat *XPYGLColorMatrix601VideoRange;
extern GLfloat *XPYGLColorMatrix601FullRange;
extern GLfloat *XPYGLColorMatrix709;


