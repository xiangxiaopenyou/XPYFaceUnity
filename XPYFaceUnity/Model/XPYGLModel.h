//
//  XPYGLModel.h
//  XPYCamera
//
//  Created by 项林平 on 2021/4/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// GL视图类型
typedef NS_ENUM(NSUInteger, XPYGLViewType) {
    XPYGLViewTypeBackground,// 纯色背景
    XPYGLViewTypeTriangle,  // 三角形
    XPYGLViewTypeCircle     // 圆形
};

@interface XPYGLModel : NSObject

@property (nonatomic, assign) XPYGLViewType type;

@property (nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
