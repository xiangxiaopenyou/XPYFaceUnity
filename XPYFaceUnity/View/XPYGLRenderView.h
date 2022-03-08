//
//  XPYGLRenderView.h
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/1/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYGLRenderView : UIView

- (void)renderBuffer:(CVPixelBufferRef)buffer;

@end

NS_ASSUME_NONNULL_END
