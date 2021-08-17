//
//  XPYGLView.h
//  XPYCamera
//
//  Created by 项林平 on 2021/4/21.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYGLView : UIView

@property (nonatomic, strong, readonly) EAGLContext *context;

@property (nonatomic, assign, readonly) GLuint program;

@end

NS_ASSUME_NONNULL_END
