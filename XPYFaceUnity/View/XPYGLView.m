//
//  XPYGLView.m
//  XPYCamera
//
//  Created by 项林平 on 2021/4/21.
//

#import "XPYGLView.h"

#import "XPYHelper.h"

@interface XPYGLView ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint program;

@end

@implementation XPYGLView {
    GLuint _renderBuffer;      // 渲染缓冲区对象
    GLuint _frameBuffer;       // 帧缓冲区对象
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
    }
}

#pragma mark - Private methods
/// 创建缓冲区对象
- (void)createBuffers {
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
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_renderBuffer);
    _renderBuffer = 0;
}

#pragma mark - Override class methods
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

#pragma mark - Override instance methods
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self destoryBuffers];
    [self createBuffers];
}

#pragma mark - Getters
- (GLuint)program {
    if (_program == 0) {
        // 顶点着色器对象
        GLuint vertexShader = [XPYHelper shaderWithFileName:@"vertex" type:GL_VERTEX_SHADER];
        // 片元着色器对象
        GLuint fragmentShader = [XPYHelper shaderWithFileName:@"fragment" type:GL_FRAGMENT_SHADER];
        if (vertexShader == 0 || fragmentShader == 0) {
            return 0;
        }
        _program = [XPYHelper programWithVertexShader:vertexShader fragmentShader:fragmentShader];
    }
    return _program;
}

- (void)dealloc {
    
}

@end
