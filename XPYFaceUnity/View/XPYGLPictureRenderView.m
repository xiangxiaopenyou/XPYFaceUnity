//
//  XPYGLPictureRenderView.m
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/3/7.
//

#import "XPYGLPictureRenderView.h"

@implementation XPYGLPictureRenderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self drawPicture];
    
    // 呈现buffer
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
}

- (void)drawPicture {
    // 顶点数据数组
    GLfloat vertices[] = {
        -1, 1, 0,   // 左上角
        -1, -1, 0,  // 左下角
        1, 1, 0,    // 右上角
        1, -1, 0    // 右下角
    };
    
    // 纹理坐标数组（纹理坐标需要上下颠倒）
    GLfloat texturePoints[] = {
        0, 0,       // 左下角
        0, 1,       // 左上角
        1, 0,       // 右下角
        1, 1        // 右上角
    };
    
    // 读取本地图片
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"png"]];
    GLuint textureId = [self textureIdWithImage:image];
    
    // 获取渲染缓存宽高
    GLint drawWidth, drawHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &drawWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &drawHeight);
    
    glViewport(0, 0, drawWidth, drawHeight);
    
    glUseProgram(self.program);
    // 获取shader的参数
    GLuint position = glGetAttribLocation(self.program, "position");
    GLuint textureCoords = glGetAttribLocation(self.program, "inputTextureCoords");
    // Uniform类型获取
    GLuint inTexture = glGetUniformLocation(self.program, "inTexture");
        
    // 将纹理ID传给着色器程序
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureId);
    // 0对应GL_TEXTURE0
    glUniform1i(inTexture, 0);
    
    // 顶点数据
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(position);
    
    // 纹理数据
    glVertexAttribPointer(textureCoords, 2, GL_FLOAT, GL_FALSE, 0, texturePoints);
    glEnableVertexAttribArray(textureCoords);
    
    // 开始绘制
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableVertexAttribArray(position);
    glDisableVertexAttribArray(textureCoords);
}

/// 获取纹理
- (GLuint)textureIdWithImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // 绘制图片
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    // 生成纹理
    GLuint textureId;
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    // 将图片写入纹理缓存
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    // (GL_CLAMP_TO_EDGE:超出部分显示纹理临近的边缘颜色值 GL_LINEAR:使用纹理中坐标最接近的若干个颜色加权平均)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // 解绑
    glBindTexture(GL_TEXTURE_2D, 0);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(imageData);
    
    return textureId;
}


@end
