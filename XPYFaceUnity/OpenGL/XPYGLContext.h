//
//  XPYGLContext.h
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/2/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

void synchronousBlockOnContextQueue(void (^block)(void));
void asynchronousBlockOnContextQueue(void (^block)(void));

@interface XPYGLContext : NSObject

+ (instancetype)sharedContext;

+ (dispatch_queue_t)sharedContextQueue;

- (void)useCurrentContext;

@end

NS_ASSUME_NONNULL_END
