//
//  XPYTools.h
//  XPYCamera
//
//  Created by 项林平 on 2021/4/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYTools : NSObject

+ (UIImage *)imageFromSampleBufferRef:(CMSampleBufferRef)sampleBufferRef;

@end

NS_ASSUME_NONNULL_END
