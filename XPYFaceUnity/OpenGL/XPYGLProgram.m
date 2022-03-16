//
//  XPYGLProgram.m
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/3/14.
//

#import "XPYGLProgram.h"

#import <OpenGLES/ES3/gl.h>

@interface XPYGLProgram ()

@end

@implementation XPYGLProgram {
    GLuint vertexShader;
    GLuint fragmentShader;
    
    GLuint program;
}

- (instancetype)initWithVertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString {
    self = [super init];
    if (self) {
        
        program = glCreateProgram();
        
        BOOL vertexShaderCompiled = [self compileShaderWithShaderString:vertexShaderString shaderType:GL_VERTEX_SHADER];
        NSAssert(vertexShaderCompiled, @"Failed to compile vertex shader");
        
        BOOL fragmentShaderCompiled = [self compileShaderWithShaderString:fragmentShaderString shaderType:GL_FRAGMENT_SHADER];
        NSAssert(fragmentShaderCompiled, @"Failed to compile fragment shader");
        
        glAttachShader(program, vertexShader);
        glAttachShader(program, fragmentShader);
    }
    return self;
}

- (void)dealloc {
    if (vertexShader) {
        glDeleteShader(vertexShader);
        vertexShader = 0;
    }
    if (fragmentShader) {
        glDeleteShader(fragmentShader);
        fragmentShader = 0;
    }
    if (program) {
        glDeleteProgram(program);
        program = 0;
    }
}

#pragma mark - Instance methods

- (BOOL)link {
    glLinkProgram(program);
    GLint status;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        GLchar infoLog[256];
        glGetProgramInfoLog(program, sizeof(infoLog), 0, infoLog);
        NSLog(@"Error:%s", infoLog);
        NSLog(@"Failed to link program");
        return NO;
    }
    
    if (vertexShader) {
        glDetachShader(program, vertexShader);
        glDeleteShader(vertexShader);
    }
    if (fragmentShader) {
        glDetachShader(program, fragmentShader);
        glDeleteShader(fragmentShader);
    }
    return YES;
}

- (void)use {
    glUseProgram(program);
}

- (GLuint)attributeLocationForName:(NSString *)name {
    return glGetAttribLocation(program, [name UTF8String]);
}

- (GLuint)uniformLocationForName:(NSString *)name {
    return glGetUniformLocation(program, [name UTF8String]);
}

#pragma mark - Private methods

/// Compile shader
- (BOOL)compileShaderWithShaderString:(NSString *)shaderString shaderType:(GLenum)type {
    if (!shaderString) {
        NSLog(@"Shader string can't be nil!");
        return NO;
    }
    GLuint shader = glCreateShader(type);
    const char *shaderChar = [shaderString UTF8String];
    glShaderSource(shader, 1, &shaderChar, NULL);
    glCompileShader(shader);
    GLint status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        GLint infoLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength > 0) {
            char *log = malloc(sizeof(char)*infoLength);
            glGetShaderInfoLog(shader, infoLength, &infoLength, log);
            if (type == GL_VERTEX_SHADER) {
                NSLog(@"Failed to compile vertex shader：%@", [NSString stringWithCString:log encoding:NSUTF8StringEncoding]);
            } else {
                NSLog(@"Failed to compile fragment shader：%@", [NSString stringWithCString:log encoding:NSUTF8StringEncoding]);
            }
            free(log);
        }
    } else {
        if (type == GL_VERTEX_SHADER) {
            vertexShader = shader;
        } else {
            fragmentShader = shader;
        }
    }
    return status == GL_TRUE;
}

@end
