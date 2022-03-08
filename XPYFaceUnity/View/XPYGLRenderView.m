//
//  XPYGLRenderView.m
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/1/5.
//

#import "XPYGLRenderView.h"

#import "XPYHelper.h"

#import <OpenGLES/ES3/gl.h>

@interface XPYGLRenderView ()

@property (nonatomic, strong) EAGLContext *context;

@end

@implementation XPYGLRenderView {
    GLuint _renderBuffer;      // 渲染缓冲区对象
    GLuint _frameBuffer;       // 帧缓冲区对象
    GLuint _depthBuffer;       // 深度缓冲区对象
    
    CVOpenGLESTextureCacheRef textureCache; // 纹理缓存管理类，用于创建和管理CVOpenGLESTextureRef
    
    GLuint rgbaProgram;         // RBGA着色器程序对象
    GLuint yuvProgram;          // YUV着色器程序对象
}

#pragma mark - Initializer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self initializeContext];
        
    }
    return self;
}

/// 配置Layer
- (void)setupLayer {
    CAEAGLLayer *glLayer = (CAEAGLLayer *)self.layer;
    // 设置为不透明
    glLayer.opaque = YES;
    // 配置属性：1.不维持渲染内容 2.RGBA8颜色格式
    glLayer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking : @NO,
        kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8
    };
}

/// 初始化EAGLContext
- (void)initializeContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!_context) {
        // 不支持ES3的使用ES2
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    if (!_context) {
        NSLog(@"⭐️Initialize EAGLContext failed⭐️");
        return;
    }
    
    // 设置当前Context
    BOOL isSuccess = [EAGLContext setCurrentContext:_context];
    if (!isSuccess) {
        NSLog(@"⭐️setCurrentContext failed⭐️");
    } else {
        [self createTextureCache];
    }
}

#pragma mark - Instance methods

- (void)renderBuffer:(CVPixelBufferRef)buffer {
    if (!buffer) {
        return;
    }
    if ([EAGLContext currentContext] != self.context) {
        [EAGLContext setCurrentContext:self.context];
        [self createTextureCache];
    }
    CVPixelBufferRetain(buffer);
    // 激活texture
    // glActiveTexture(GL_TEXTURE1);
    if (CVPixelBufferGetPixelFormatType(buffer) == kCVPixelFormatType_32BGRA) {
        [self createRGBAProgram];
    }
    CVOpenGLESTextureRef texture = NULL;
    // CVPixelBuffer转为纹理，并将句柄存放于texture中
    CVReturn result = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, buffer, NULL, GL_TEXTURE_2D, GL_RGBA, (GLsizei)CVPixelBufferGetWidth(buffer), (GLsizei)CVPixelBufferGetHeight(buffer), GL_RGBA, GL_UNSIGNED_BYTE, 0, &texture);
    if (result != kCVReturnSuccess) {
        NSLog(@"⭐️CVOpenGLESTextureCacheCreateTextureFromImage failed⭐️");
    } else {
        [self drawTexture:texture];
    }
    CVPixelBufferRelease(buffer);
}

#pragma mark - Private methods

- (void)createTextureCache {
    if (textureCache) {
        CVOpenGLESTextureCacheFlush(textureCache, 0);
        CFRelease(textureCache);
    }
    CVReturn result = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.context, NULL, &textureCache);
    if (result != kCVReturnSuccess) {
        NSLog(@"⭐️CVOpenGLESTextureCacheCreate failed⭐️");
    }
}

/// 画出纹理
- (void)drawTexture:(CVOpenGLESTextureRef)texture {
    // 绑定texture到上下文
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(texture));
    // 设置参数
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
}

- (BOOL)createRGBAProgram {
    // 顶点着色器对象
    GLuint vertexShader = [XPYHelper shaderWithFileName:@"vertex" type:GL_VERTEX_SHADER];
    if (vertexShader == 0) {
        return NO;
    }
    // 片元着色器对象
    GLuint fragmentShader = [XPYHelper shaderWithFileName:@"fragment" type:GL_FRAGMENT_SHADER];
    if (fragmentShader == 0) {
        return NO;
    }
    rgbaProgram = glCreateProgram();
    // 绑定顶点着色器对象
    glAttachShader(rgbaProgram, vertexShader);
    // 绑定片元着色器对象
    glAttachShader(rgbaProgram, fragmentShader);
    // 绑定着色器属性，必须在链接程序之前
//    glBindAttribLocation(rgbaProgram, 0, "position");
//    glBindAttribLocation(rgbaProgram, 1, "inputTextureCoords");
    // 链接着色器程序
    glLinkProgram(rgbaProgram);
    GLint success;
    glGetProgramiv(rgbaProgram, GL_LINK_STATUS, &success);
    if (success == GL_FALSE) {
        // 获取链接错误信息
        GLint infoLength = 0;
        glGetProgramiv(rgbaProgram, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength > 1) {
            char *infoLog = malloc(sizeof(char) * infoLength);
            if (infoLog) {
                glGetProgramInfoLog(rgbaProgram, infoLength, NULL, infoLog);
                NSLog(@"⭐️程序链接错误：%@⭐️", [NSString stringWithCString:infoLog encoding:NSUTF8StringEncoding]);
                free(infoLog);
            }
        }
        // 删除着色器对象
        if (vertexShader) {
            glDeleteShader(vertexShader);
            vertexShader = 0;
        }
        if (fragmentShader) {
            glDeleteShader(fragmentShader);
            fragmentShader = 0;
        }
        if (rgbaProgram) {
            glDeleteProgram(rgbaProgram);
            rgbaProgram = 0;
        }
        return NO;
    }
    
    if (vertexShader) {
        glDetachShader(rgbaProgram, vertexShader);
        glDeleteShader(vertexShader);
    }
    if (fragmentShader) {
        glDetachShader(rgbaProgram, fragmentShader);
        glDeleteShader(fragmentShader);
    }
    glUseProgram(rgbaProgram);
    return YES;
}

/// 创建缓冲区对象
- (void)createBuffers {
    glDisable(GL_DEPTH_TEST);
    // 深度缓冲区比较值
    glDepthFunc(GL_LEQUAL);
    // 深度缓冲区写入
    glDepthMask(GL_TRUE);
    
    // 创建帧缓冲区对象
    glGenFramebuffers(1, &_frameBuffer);
    // 绑定帧缓冲区对象到GL_FRAMEBUFFER
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // 创建渲染缓冲区对象
    glGenRenderbuffers(1, &_renderBuffer);
    // 绑定渲染缓冲区对象到GL_RENDERBUFFER
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    // 为渲染缓冲区对象分配存储空间
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    // 将渲染缓冲区挂载到当前帧缓冲区上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
}
/// 销毁缓冲区对象
- (void)destoryBuffers {
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    if (_depthBuffer) {
        glDeleteRenderbuffers(2, &_depthBuffer);
        _depthBuffer = 0;
    }
}

#pragma mark - Override class methods

/// 自定义图层类型
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

#pragma mark - Override instance methods
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self destoryBuffers];
    [self createBuffers];
}

@end
