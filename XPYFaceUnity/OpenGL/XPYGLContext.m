//
//  XPYGLContext.m
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/2/16.
//

#import "XPYGLContext.h"

#import <OpenGLES/EAGL.h>

static void *openGLESContextQueueKey;

void synchronousBlockOnContextQueue(void (^block)(void)) {
    if (dispatch_get_specific(openGLESContextQueueKey)) {
        [[XPYGLContext sharedContext] useCurrentContext];
        block();
    } else {
        dispatch_sync([XPYGLContext sharedContextQueue], ^{
            [[XPYGLContext sharedContext] useCurrentContext];
            block();
        });
    }
}

void asynchronousBlockOnContextQueue(void (^block)(void)) {
    if (dispatch_get_specific(openGLESContextQueueKey)) {
        [[XPYGLContext sharedContext] useCurrentContext];
        block();
    } else {
        dispatch_async([XPYGLContext sharedContextQueue], ^{
            [[XPYGLContext sharedContext] useCurrentContext];
            block();
        });
    }
}

@interface XPYGLContext ()

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic) dispatch_queue_t contextQueue;

@end

@implementation XPYGLContext

+ (instancetype)sharedContext {
    static XPYGLContext *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XPYGLContext alloc] init];
    });
    return instance;
}

+ (dispatch_queue_t)sharedContextQueue {
    return [XPYGLContext sharedContext].contextQueue;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        openGLESContextQueueKey = &openGLESContextQueueKey;
        self.contextQueue = dispatch_queue_create("xiang.openGLESContextQueue", NULL);
#if OS_OBJECT_USE_OBJC
        dispatch_queue_set_specific(self.contextQueue, openGLESContextQueueKey, (__bridge void *)self, NULL);
#endif
        
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        if (!self.context) {
            // 设备不支持OpenGLES3则使用OpenGLES2
            self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        }
        NSAssert(self.context, @"Unable to create an OpenGL ES context");
    }
    return self;
}

- (void)useCurrentContext {
    if ([EAGLContext currentContext] != self.context) {
        [EAGLContext setCurrentContext:self.context];
    }
}

@end
