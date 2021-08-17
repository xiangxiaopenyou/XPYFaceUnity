//
//  XPYGLBackgroundView.m
//  XPYCamera
//
//  Created by 项林平 on 2021/4/23.
//

#import "XPYGLBackgroundView.h"

@implementation XPYGLBackgroundView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 设置清除颜色
    glClearColor(0, 0, 1, 1.f);
    // 设置窗口颜色
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 呈现buffer
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
}


@end
