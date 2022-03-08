//
//  XPYCamera.h
//  XPYFaceUnity
//
//  Created by 项林平 on 2021/12/14.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class XPYCamera;

NS_ASSUME_NONNULL_BEGIN

@protocol XPYCameraDelegate <NSObject>

/// 视频帧输出
- (void)camera:(XPYCamera *)camera didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
/// 音频帧输出
- (void)camera:(XPYCamera *)camera didOutputAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@interface XPYCamera : NSObject

@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;

@property (nonatomic, readonly, getter=isRunning) BOOL running;
/// 前/后置摄像头
@property (nonatomic, assign, readonly) AVCaptureDevicePosition captureDevicePosition;
/// 采集分辨率
@property (nonatomic, copy, readonly) AVCaptureSessionPreset captureSessionPreset;

@property (nonatomic, weak) id<XPYCameraDelegate> delegate;

/// Initializer
/// @param position 前后置摄像头
/// @param captureFormat 格式
/// @param preset 分辨率
- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)position
                         captureFormat:(int)captureFormat
                  captureSessionPreset:(AVCaptureSessionPreset)preset;

- (void)startCapture;

- (void)stopCapture;

/// 切换前后置摄像头
- (BOOL)switchDevicePosition;

/// 切换采集分辨率
- (BOOL)switchSessionPreset:(AVCaptureSessionPreset)preset;

@end

NS_ASSUME_NONNULL_END
