//
//  XPYCamera.h
//  XPYFaceUnity
//
//  Created by 项林平 on 2021/12/14.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYCamera : NSObject

/// Initializer
/// @param position 前后置摄像头
/// @param captureFormat 格式
/// @param preset 分辨率
- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)position
                         captureFormat:(int)captureFormat
                  captureSessionPreset:(AVCaptureSessionPreset)preset;

- (void)startCapturing;

- (void)stopCapturing;

@end

NS_ASSUME_NONNULL_END
