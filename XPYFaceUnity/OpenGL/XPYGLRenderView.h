//
//  XPYGLRenderView.h
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/1/5.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XPYGLRenderViewContentMode) {
    XPYGLRenderViewContentModeScaleToFill,      // 拉伸填满
    XPYGLRenderViewContentModeAspectFill,       // 等比例短边填满
    XPYGLRenderViewContentModeAspectFit         // 等比例长边填满
};

NS_ASSUME_NONNULL_BEGIN

@interface XPYGLRenderView : UIView

/// 图像填充模式，默认拉伸填满
@property (nonatomic) XPYGLRenderViewContentMode renderContentMode;

- (void)renderBuffer:(CVPixelBufferRef)buffer;

@end

NS_ASSUME_NONNULL_END
