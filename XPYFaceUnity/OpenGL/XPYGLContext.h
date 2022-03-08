//
//  XPYGLContext.h
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/2/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYGLContext : NSObject

+ (instancetype)sharedContext;

- (void)useCurrentContext;

@end

NS_ASSUME_NONNULL_END
