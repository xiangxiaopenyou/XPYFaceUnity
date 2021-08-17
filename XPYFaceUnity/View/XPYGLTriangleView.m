//
//  XPYGLTriangleView.m
//  XPYCamera
//
//  Created by 项林平 on 2021/4/23.
//

#import "XPYGLTriangleView.h"
#import "XPYHelper.h"

@implementation XPYGLTriangleView {
    // GLuint _program;           // 程序对象
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupProgram];
    }
    return self;
}

/// 设置程序对象
- (void)setupProgram {
    glUseProgram(self.program);
}

/// 画三角形
- (void)drawTriangle {
    
    glViewport(0, self.safeAreaInsets.bottom, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - self.safeAreaInsets.top - self.safeAreaInsets.bottom);
    
    // 顶点位置数组
    GLfloat vertices[] = {
        0.f, 1.f,
        -1.f, -1.f,
        1.f, -1.f
    };
    
    // 获取顶点属性变量的位置索引
    GLuint postion = glGetAttribLocation(self.program, "position");
    // 设置顶点位置属性的数据格式
    glVertexAttribPointer(postion, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    
    glEnableVertexAttribArray(postion);
    
    // 顶点颜色数组
    static GLfloat colors[] = {
        0.0f, 0.0f, 1.0f,
        1.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f
    };
    // 获取顶点属性变量的颜色索引
    GLint color = glGetAttribLocation(self.program, "color");
    // 设置顶点颜色属性的数据格式
    glVertexAttribPointer(color, 3, GL_FLOAT, GL_FALSE, 0, colors);
    glEnableVertexAttribArray(color);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 设置清除颜色
    glClearColor(1, 0, 0, 1.f);
    // 设置窗口颜色
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self drawTriangle];
    
    // 呈现buffer
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
