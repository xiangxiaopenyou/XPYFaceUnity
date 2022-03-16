//
//  XPYCamera.m
//  XPYFaceUnity
//
//  Created by 项林平 on 2021/12/14.
//

#import "XPYCamera.h"
#import "XPYPerformanceTester.h"

/// 弱引用对象
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;

/// 强引用对象
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;

@interface XPYCamera ()<AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    /// 视频、音频采集队列
    dispatch_queue_t videoCaptureQueue, audioCaptureQueue;
}

@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) AVCaptureDevice *cameraDevice;
/// 摄像头输入
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
/// 麦克风输入
@property (nonatomic, strong) AVCaptureDeviceInput *microphoneInput;
/// 视频数据输出
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
/// 音频数据输出
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;

@property (nonatomic, assign) int captureFormat;

@end

@implementation XPYCamera {
    const void * operationQueueKey;
}

#pragma mark - Initializer

- (instancetype)init {
    return [self initWithCameraPosition:AVCaptureDevicePositionFront captureFormat:kCVPixelFormatType_32BGRA captureSessionPreset:AVCaptureSessionPreset1280x720];
}

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)position captureFormat:(int)captureFormat captureSessionPreset:(AVCaptureSessionPreset)preset {
    self = [super init];
    if (self) {
        videoCaptureQueue = dispatch_queue_create("xiang.videoCaptureQueue", NULL);
        audioCaptureQueue = dispatch_queue_create("xiang.audioCaptureQueue", NULL);
        
        _captureDevicePosition = position;
        _captureFormat = captureFormat;
        _captureSessionPreset = preset;
        _videoOrientation = AVCaptureVideoOrientationPortrait;
        _frameRate = 0;
        
        // 摄像头设备
        self.cameraDevice = position ==  AVCaptureDevicePositionFront ? [self frontCamera] : [self backCamera];
        NSAssert(self.cameraDevice, @"Camera device can not be nil");
        
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession beginConfiguration];
        self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.cameraDevice error:nil];
        if ([self.captureSession canAddInput:self.videoInput]) {
            [self.captureSession addInput:self.videoInput];
        }
        if ([_captureSession canAddInput:self.microphoneInput]) {
            [_captureSession addInput:self.microphoneInput];
        }
        if ([_captureSession canAddOutput:self.videoDataOutput]) {
            [_captureSession addOutput:self.videoDataOutput];
            // 设置输出格式
            self.videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(captureFormat)};
        }
        if ([_captureSession canAddOutput:self.audioDataOutput]) {
            [_captureSession addOutput:self.audioDataOutput];
        }
        if ([_captureSession canSetSessionPreset:self.captureSessionPreset]) {
            _captureSession.sessionPreset = self.captureSessionPreset;
        } else {
            _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
        }
        AVCaptureConnection *captureConnetion = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        // 关闭自动镜像
        captureConnetion.automaticallyAdjustsVideoMirroring = NO;
        captureConnetion.videoOrientation = _videoOrientation;
        // 前置镜像后置不镜像
        captureConnetion.videoMirrored = self.captureDevicePosition == AVCaptureDevicePositionFront;
        
        [_captureSession commitConfiguration];
        
    }
    return self;
}

#pragma mark - Dealloc

- (void)dealloc {
    [self stopCapture];
    
    [self.videoDataOutput setSampleBufferDelegate:nil queue:nil];
    [self.audioDataOutput setSampleBufferDelegate:nil queue:nil];
    
    [self.captureSession beginConfiguration];
    if (_microphoneInput) {
        [self.captureSession removeInput:_microphoneInput];
    }
    if (_videoInput) {
        [self.captureSession removeInput:_videoInput];
    }
    if (_audioDataOutput) {
        [self.captureSession removeOutput:_audioDataOutput];
    }
    if (_videoDataOutput) {
        [self.captureSession removeOutput:_videoDataOutput];
    }
    [self.captureSession commitConfiguration];
}

#pragma mark - Instance methods

- (void)startCapture {
    if (!self.captureSession.isRunning) {
        [self.captureSession startRunning];
    }
}

- (void)stopCapture {
    if (self.captureSession.isRunning) {
        [self.captureSession stopRunning];
    }
}

- (BOOL)switchDevicePosition {
    AVCaptureDevice *targetDevice = nil;
    if (_captureDevicePosition == AVCaptureDevicePositionFront) {
        targetDevice = [self backCamera];
    } else {
        targetDevice = [self frontCamera];
    }
    BOOL result = NO;
    NSError *error = nil;
    AVCaptureDeviceInput *targetInput = [[AVCaptureDeviceInput alloc] initWithDevice:targetDevice error:&error];
    if (!error) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.videoInput];
        if ([self.captureSession canAddInput:targetInput]) {
            [self.captureSession addInput:targetInput];
            self.videoInput = targetInput;
            _captureDevicePosition = _captureDevicePosition == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
            self.cameraDevice = targetDevice;
            result = YES;
        } else {
            [self.captureSession addInput:self.videoInput];
            NSLog(@"addInput failed!");
        }
        AVCaptureConnection *captureConnetion = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        captureConnetion.videoOrientation = _videoOrientation;
        if (captureConnetion.supportsVideoMirroring) {
            // 前置镜像后置不镜像
            captureConnetion.videoMirrored = self.captureDevicePosition == AVCaptureDevicePositionFront;
        }
        [self.captureSession commitConfiguration];
        
    } else {
        NSLog(@"Initialize AVCaptureDeviceInput failed.");
    }
    return result;
}

- (BOOL)switchSessionPreset:(AVCaptureSessionPreset)preset {
    BOOL result = NO;
    [self.captureSession beginConfiguration];
    if ([self.captureSession canSetSessionPreset:preset]) {
        self.captureSession.sessionPreset = preset;
        _captureSessionPreset = preset;
        result = YES;
    }
    [self.captureSession commitConfiguration];
    if (!result) {
        NSLog(@"⭐️switchSessionPreset failed.");
    }
    return result;
}

#pragma mark - AVCaptureDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (!self.captureSession.isRunning) {
        return;
    }
    if (output == self.videoDataOutput) {
        NSLog(@"⭐️视频输出");
        if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didOutputVideoSampleBuffer:)]) {
            [self.delegate camera:self didOutputVideoSampleBuffer:sampleBuffer];
        }
        [[XPYPerformanceTester sharedTester] frameRateTest];
        
    } else {
        NSLog(@"⭐️音频输出");
        if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didOutputAudioSampleBuffer:)]) {
            [self.delegate camera:self didOutputAudioSampleBuffer:sampleBuffer];
        }
    }
}

#pragma mark - Setters

- (void)setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation {
    _videoOrientation = videoOrientation;
    AVCaptureConnection *captureConnetion = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    captureConnetion.videoOrientation = videoOrientation;
}

- (void)setFrameRate:(int32_t)frameRate {
    _frameRate = frameRate;
    if (frameRate <= 0) {
        // 恢复为默认
        if ([self.cameraDevice lockForConfiguration:nil]) {
            self.cameraDevice.activeVideoMaxFrameDuration = kCMTimeInvalid;
            self.cameraDevice.activeVideoMinFrameDuration = kCMTimeInvalid;
            [self.cameraDevice unlockForConfiguration];
        }
    } else {
        // 判断设备是否支持该帧率
        BOOL isSupported = YES;
        NSArray<AVFrameRateRange *> *frameRateRanges = self.cameraDevice.activeFormat.videoSupportedFrameRateRanges;
        for (AVFrameRateRange *frameRateRange in frameRateRanges) {
            if (frameRateRange.maxFrameRate < frameRate || frameRateRange.minFrameRate > frameRate) {
                isSupported = NO;
                break;
            }
        }
        NSAssert(isSupported, @"Frame rate is not be supported");
        if (isSupported) {
            if ([self.cameraDevice lockForConfiguration:nil]) {
                self.cameraDevice.activeVideoMaxFrameDuration = CMTimeMake(1, frameRate);
                self.cameraDevice.activeVideoMinFrameDuration = CMTimeMake(1, frameRate);
                [self.cameraDevice unlockForConfiguration];
            }
        }
    }
}

#pragma mark - Getters

- (BOOL)isRunning {
    return self.captureSession.isRunning;
}

- (AVCaptureDeviceInput *)microphoneInput {
    
    if (!_microphoneInput) {
        NSError *error = nil;
        _microphoneInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self microphoneDevice] error:&error];
        if (error) {
            NSLog(@"获取麦克风输入失败");
        }
    }
    return _microphoneInput;
}

- (AVCaptureDevice *)frontCamera {
    AVCaptureDevice *device = nil;
    if (@available(iOS 10.2, *)) {
        device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        if (!device) {
            device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        }
    } else {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *captureDevice in devices) {
            if (captureDevice.position == AVCaptureDevicePositionFront) {
                device = captureDevice;
                break;
            }
        }
    }
    return device;
}

- (AVCaptureDevice *)backCamera {
    AVCaptureDevice *device = nil;
    if (@available(iOS 10.2, *)) {
        device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        if (!device) {
            device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        }
    } else {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *captureDevice in devices) {
            if (captureDevice.position == AVCaptureDevicePositionBack) {
                device = captureDevice;
                break;
            }
        }
    }
    return device;
}

- (AVCaptureDevice *)microphoneDevice {
    AVCaptureDevice *device = nil;
    if (@available(iOS 10.0, *)) {
        device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInMicrophone mediaType:AVMediaTypeAudio position:AVCaptureDevicePositionUnspecified];
    } else {
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    }
    return device;
}

- (AVCaptureAudioDataOutput *)audioDataOutput {
    if (!_audioDataOutput) {
        _audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioDataOutput setSampleBufferDelegate:self queue:audioCaptureQueue];
    }
    return _audioDataOutput;
}

- (AVCaptureVideoDataOutput *)videoDataOutput {
    if (!_videoDataOutput) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(self.captureFormat)};
        [_videoDataOutput setSampleBufferDelegate:self queue:videoCaptureQueue];
    }
    return _videoDataOutput;
}

@end
