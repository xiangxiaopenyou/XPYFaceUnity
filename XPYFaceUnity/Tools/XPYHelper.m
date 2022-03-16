//
//  XPYHelper.m
//  XPYCamera
//
//  Created by 项林平 on 2021/4/22.
//

#import "XPYHelper.h"

@implementation XPYHelper

+ (GLuint)shaderWithShaderString:(NSString *)shaderString type:(GLenum)shaderType {
    if (!shaderString || shaderString.length == 0) {
        return 0;
    }
    // 创建着色器对象
    GLuint shader = glCreateShader(shaderType);
    
    const char * shaderChar = [shaderString UTF8String];
    
    // 将着色器代码挂载到着色器对象上
    glShaderSource(shader, 1, &shaderChar, NULL);
    
    // 编译shader
    glCompileShader(shader);
    
    // 获取编译状态
    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (success == GL_FALSE) {
        // 获取编译错误信息
        GLint infoLength = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength > 1) {
            char *infoLog = malloc(sizeof(char) * infoLength);
            if (infoLog) {
                glGetShaderInfoLog(shader, infoLength, NULL, infoLog);
                NSLog(@"⭐️着色器编译错误：%@⭐️", [NSString stringWithCString:infoLog encoding:NSUTF8StringEncoding]);
                free(infoLog);
            }
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

+ (GLuint)shaderWithFileName:(NSString *)fileName type:(GLenum)shaderType {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"glsl"];
    NSError *error = nil;
    
    NSString *shaderString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"⭐️创建着色器对象失败：%@⭐️", error);
        return 0;
    }
    
    // 创建着色器对象
    GLuint shader = glCreateShader(shaderType);
    
    const char * shaderChar = [shaderString UTF8String];
    
    // 将着色器代码挂载到着色器对象上
    glShaderSource(shader, 1, &shaderChar, NULL);
    
    // 编译shader
    glCompileShader(shader);
    
    // 获取编译状态
    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (success == GL_FALSE) {
        // 获取编译错误信息
        GLint infoLength = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength > 1) {
            char *infoLog = malloc(sizeof(char) * infoLength);
            if (infoLog) {
                glGetShaderInfoLog(shader, infoLength, NULL, infoLog);
                NSLog(@"⭐️着色器编译错误：%@⭐️", [NSString stringWithCString:infoLog encoding:NSUTF8StringEncoding]);
                free(infoLog);
            }
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
    
}

+ (GLuint)programWithVertexShader:(GLuint)vertexShader fragmentShader:(GLuint)fragmentShader {
    // 创建程序对象
    GLuint program = glCreateProgram();
    // 链接顶点着色器
    glAttachShader(program, vertexShader);
    // 链接片元着色器
    glAttachShader(program, fragmentShader);
    // 链接程序对象
    glLinkProgram(program);
    // 删除着色器对象
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    // 获取链接状态
    GLint success;
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (success == GL_FALSE) {
        // 获取链接错误信息
        GLint infoLength = 0;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength > 1) {
            char *infoLog = malloc(sizeof(char) * infoLength);
            if (infoLog) {
                glGetProgramInfoLog(program, infoLength, NULL, infoLog);
                NSLog(@"⭐️程序链接错误：%@⭐️", [NSString stringWithCString:infoLog encoding:NSUTF8StringEncoding]);
                free(infoLog);
            }
        }
        glDeleteProgram(program);
        return 0;
    }
    return program;
}

@end
