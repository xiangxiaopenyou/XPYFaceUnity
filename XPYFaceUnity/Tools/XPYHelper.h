//
//  XPYHelper.h
//  XPYCamera
//
//  Created by 项林平 on 2021/4/22.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYHelper : NSObject

/// 获取着色器对象
/// @param fileName 本地文件名
/// @param shaderType 着色器类型
+ (GLuint)shaderWithFileName:(NSString *)fileName type:(GLenum)shaderType;

/// 获取程序对象
/// @param vertexShader 顶点着色器对象
/// @param fragmentShader 片元着色器对象
+ (GLuint)programWithVertexShader:(GLuint)vertexShader fragmentShader:(GLuint)fragmentShader;

@end

NS_ASSUME_NONNULL_END
