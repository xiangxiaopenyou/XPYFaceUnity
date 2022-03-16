//
//  XPYGLRenderView.m
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/1/5.
//

#import "XPYGLRenderView.h"

#import "XPYGLContext.h"
#import "XPYGLDefines.h"
#import "XPYGLProgram.h"

#import "XPYHelper.h"

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@interface XPYGLRenderView ()

@property (nonatomic, strong) XPYGLProgram *rgbaProgram;    // RGBA着色器程序对象
@property (nonatomic, strong) XPYGLProgram *yuvProgram;     // YUV着色器程序对象

@end

@implementation XPYGLRenderView {
    GLuint renderBuffer;      // 渲染缓冲区对象
    GLuint frameBuffer;       // 帧缓冲区对象
    GLuint depthBuffer;       // 深度缓冲区对象
    
    GLint width, height;
    
    CGFloat bufferWidth, bufferHeight;
    
    CVOpenGLESTextureCacheRef textureCache; // 纹理缓存管理类，用于创建和管理CVOpenGLESTextureRef
    
    GLfloat renderVertices[8];        // 顶点数组
    
    CGSize frameBufferBoundsSize;   // 图像渲染区域限制大小
}

/// 自定义图层类型
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

#pragma mark - Initializer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    CAEAGLLayer *glLayer = (CAEAGLLayer *)self.layer;
    // 设置为不透明
    glLayer.opaque = YES;
    // 配置属性：1.不维持渲染内容 2.RGBA8颜色格式
    glLayer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking : @NO,
        kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8
    };
    
    synchronousBlockOnContextQueue(^{
        [self createBuffers];
        [self createTextureCache];
    });
}

#pragma mark - Life cycle

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        if (!CGSizeEqualToSize(self.bounds.size, frameBufferBoundsSize)) {
            synchronousBlockOnContextQueue(^{
                [self destoryBuffers];
                [self createBuffers];
            });
        } else {
            [self recalculateRenderVertices];
        }
    }
}

- (void)dealloc {
    synchronousBlockOnContextQueue(^{
        [self destoryBuffers];
        if (textureCache) {
            [self releaseTextureCache];
        }
    });
}

#pragma mark - Instance methods

- (void)renderBuffer:(CVPixelBufferRef)buffer {
    if (buffer == NULL) {
        return;
    }
    synchronousBlockOnContextQueue(^{
        CVPixelBufferRetain(buffer);
        // 保存buffer宽高
        bufferWidth = CVPixelBufferGetWidth(buffer);
        bufferHeight = CVPixelBufferGetHeight(buffer);
        glViewport(0, 0, width, height);
        if (CVPixelBufferGetPixelFormatType(buffer) == kCVPixelFormatType_32BGRA) {
            [self drawTextureWithRGBAPixelBuffer:buffer];
        } else {
            [self drawTextureWithYUVPixelBuffer:buffer];
        }
        CVPixelBufferRelease(buffer);
        EAGLContext *currentContext = [EAGLContext currentContext];
        [currentContext presentRenderbuffer:GL_RENDERBUFFER];
    });
}

#pragma mark - Private methods

- (void)createTextureCache {
    if (!textureCache) {
        // 创建CVOpenGLESTextureCacheRef
        CVReturn result = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [EAGLContext currentContext], NULL, &textureCache);
        if (result != kCVReturnSuccess) {
            NSLog(@"⭐️CVOpenGLESTextureCacheCreate failed⭐️");
        }
    }
}

- (void)releaseTextureCache {
    CVOpenGLESTextureCacheFlush(self->textureCache, 0);
    CFRelease(self->textureCache);
    self->textureCache = NULL;
}

- (void)drawTextureWithRGBAPixelBuffer:(CVPixelBufferRef)buffer {
    if (!self.rgbaProgram) {
        self.rgbaProgram = [[XPYGLProgram alloc] initWithVertexShaderString:XPYGLVertexShaderString fragmentShaderString:XPYGLRGBAFragmentShaderString];
        if ([self.rgbaProgram link]) {
            [self.rgbaProgram use];
        }
    }
    CVOpenGLESTextureRef texture = NULL;
    //CVPixelBuffer转为纹理，并将句柄存放于texture中
    CVReturn result = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, buffer, NULL, GL_TEXTURE_2D, GL_RGBA, (GLsizei)CVPixelBufferGetWidth(buffer), (GLsizei)CVPixelBufferGetHeight(buffer), GL_BGRA, GL_UNSIGNED_BYTE, 0, &texture);
    if (result != kCVReturnSuccess) {
        NSLog(@"Failed to create RGBA texture");
        return;
    }
    // 激活纹理单元
    glActiveTexture(GL_TEXTURE0);
    // 绑定纹理
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(texture));
    // 设置参数
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    GLint position = [self.rgbaProgram attributeLocationForName:@"position"];
    GLint textureCoords = [self.rgbaProgram attributeLocationForName:@"inputTextureCoords"];
    GLint inTexture = [self.rgbaProgram uniformLocationForName:@"inTexture"];
    glUniform1i(inTexture, 0);
    
    [self recalculateRenderVertices];

    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, 0, renderVertices);
    glEnableVertexAttribArray(position);
    
    // 纹理坐标数组（纹理坐标需要上下颠倒）
    GLfloat texturePoints[] = {
        0, 1,       // 左上角
        1, 1,       // 右上角
        0, 0,       // 左下角
        1, 0        // 右下角
    };

    glVertexAttribPointer(textureCoords, 2, GL_FLOAT, GL_FALSE, 0, texturePoints);
    glEnableVertexAttribArray(textureCoords);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glDisableVertexAttribArray(position);
    glDisableVertexAttribArray(textureCoords);
    
    if (texture) {
        CFRelease(texture);
    }
    
}

- (void)drawTextureWithYUVPixelBuffer:(CVPixelBufferRef)buffer {
    if (!self.yuvProgram) {
        self.yuvProgram = [[XPYGLProgram alloc] initWithVertexShaderString:XPYGLVertexShaderString fragmentShaderString:XPYGLYUVFullRangeFragmentShaderString];
        if ([self.yuvProgram link]) {
            [self.yuvProgram use];
        }
    }
    CVOpenGLESTextureRef luminanceTextureRef = NULL;
    CVReturn luminanceResult = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, buffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE, (GLsizei)CVPixelBufferGetWidth(buffer), (GLsizei)CVPixelBufferGetHeight(buffer), GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
    if (luminanceResult != kCVReturnSuccess) {
        NSLog(@"Failed to create luminance texture");
        return;
    }
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(luminanceTextureRef));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    CVOpenGLESTextureRef chrominanceTextureRef = NULL;
    CVReturn chrominanceResult = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, buffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, (GLsizei)CVPixelBufferGetWidth(buffer)/2, (GLsizei)CVPixelBufferGetHeight(buffer)/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
    if (chrominanceResult != kCVReturnSuccess) {
        NSLog(@"Failed to create chrominance texture");
        return;
    }
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(chrominanceTextureRef));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLint position = [self.yuvProgram attributeLocationForName:@"position"];
    GLint textureCoords = [self.yuvProgram attributeLocationForName:@"inputTextureCoords"];
    GLint luminanceTexture = [self.yuvProgram uniformLocationForName:@"luminanceTexture"];
    GLint chrominanceTexture = [self.yuvProgram uniformLocationForName:@"chrominanceTexture"];
    GLint colorMatrix = [self.yuvProgram uniformLocationForName:@"colorMatrix"];
    
    glUniform1i(luminanceTexture, 1);
    glUniform1i(chrominanceTexture, 2);
    
    glUniformMatrix3fv(colorMatrix, 1, GL_FALSE, XPYGLColorMatrix601FullRange);
    
    [self recalculateRenderVertices];
    
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, 0, renderVertices);
    glEnableVertexAttribArray(position);
    
    // 纹理坐标数组（纹理坐标需要上下颠倒）
    GLfloat texturePoints[] = {
        0, 1,       // 左上角
        1, 1,       // 右上角
        0, 0,       // 左下角
        1, 0        // 右下角
    };

    glVertexAttribPointer(textureCoords, 2, GL_FLOAT, GL_FALSE, 0, texturePoints);
    glEnableVertexAttribArray(textureCoords);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glDisableVertexAttribArray(position);
    glDisableVertexAttribArray(textureCoords);
    
    if (luminanceTextureRef) {
        CFRelease(luminanceTextureRef);
    }
    
    if (chrominanceTextureRef) {
        CFRelease(chrominanceTextureRef);
    }
}

/// 重新计算顶点数组
- (void)recalculateRenderVertices {
    synchronousBlockOnContextQueue(^{
        // 计算宽高比例
        CGFloat widthScale = width / bufferWidth;
        CGFloat heightScale = height / bufferHeight;
        
        switch (self.renderContentMode) {
            case XPYGLRenderViewContentModeScaleToFill:{
                widthScale = 1;
                heightScale = 1;
            }
                break;
            case XPYGLRenderViewContentModeAspectFill:{
                
                
                CGFloat scale = MAX(widthScale, heightScale);
                widthScale = bufferWidth * scale / width;
                heightScale = bufferHeight * scale / height;
                
            }
                break;
            case XPYGLRenderViewContentModeAspectFit:{
                widthScale = width / bufferWidth;
                heightScale = height / bufferHeight;
                
                CGFloat scale = MIN(widthScale, heightScale);
                widthScale = bufferWidth * scale / width;
                heightScale = bufferHeight * scale / height;
            }
                break;
        }
        renderVertices[0] = -widthScale;
        renderVertices[1] = -heightScale;
        renderVertices[2] = widthScale;
        renderVertices[3] = -heightScale;
        renderVertices[4] = -widthScale;
        renderVertices[5] = heightScale;
        renderVertices[6] = widthScale;
        renderVertices[7] = heightScale;
    });
}

/// 创建缓冲区对象
- (void)createBuffers {
    glDisable(GL_DEPTH_TEST);
    // 深度缓冲区比较值
    glDepthFunc(GL_LEQUAL);
    // 深度缓冲区写入
    glDepthMask(GL_TRUE);
    
    // 创建帧缓冲区对象
    glGenFramebuffers(1, &frameBuffer);
    // 绑定帧缓冲区对象到GL_FRAMEBUFFER
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    // 创建渲染缓冲区对象
    glGenRenderbuffers(1, &renderBuffer);
    // 绑定渲染缓冲区对象到GL_RENDERBUFFER
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    // 为渲染缓冲区对象分配存储空间
    EAGLContext *currentContext = [EAGLContext currentContext];
    [currentContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    // 将渲染缓冲区挂载到当前帧缓冲区上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    frameBufferBoundsSize = self.bounds.size;
    
    [self recalculateRenderVertices];
}

/// 销毁缓冲区对象
- (void)destoryBuffers {
    if (frameBuffer) {
        glDeleteFramebuffers(1, &frameBuffer);
        frameBuffer = 0;
    }
    if (renderBuffer) {
        glDeleteRenderbuffers(1, &renderBuffer);
        renderBuffer = 0;
    }
    if (depthBuffer) {
        glDeleteRenderbuffers(2, &depthBuffer);
        depthBuffer = 0;
    }
}

//- (BOOL)createRGBAProgram {
//    if (!_rgbaProgram) {
//        _rgbaProgram = [[XPYGLProgram alloc] initWithVertexShaderString:XPYGLVertexShaderString fragmentShaderString:XPYGLRGBAFragmentShaderString];
//    }
//    if ([_rgbaProgram link]) {
//        [_rgbaProgram use];
//        return YES;
//    }
//    return NO;
//}

//- (BOOL)createYUVProgram {
//    if (!_yuvProgram) {
//        _yuvProgram = [[XPYGLProgram alloc] initWithVertexShaderString:XPYGLVertexShaderString fragmentShaderString:XPYGLYUVFullRangeFragmentShaderString];
//        if (![_yuvProgram link]) {
//            return NO;
//        }
//        [_yuvProgram use];
//    }
//    return YES;
//}

#pragma mark - Setters

- (void)setRenderContentMode:(XPYGLRenderViewContentMode)renderContentMode {
    _renderContentMode = renderContentMode;
    [self recalculateRenderVertices];
}

@end
