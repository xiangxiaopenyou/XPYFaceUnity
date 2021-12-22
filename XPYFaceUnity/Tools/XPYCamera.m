//
//  XPYCamera.m
//  XPYFaceUnity
//
//  Created by 项林平 on 2021/12/14.
//

#import "XPYCamera.h"

/// 弱引用对象
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;

/// 强引用对象
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;

@interface XPYCamera ()<AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) AVCaptureConnection *captureConnetion;

@property (nonatomic, strong) AVCaptureDevice *cameraDevice;
/// 前置摄像头输入
@property (nonatomic, strong) AVCaptureDeviceInput *frontCameraInput;
/// 后置摄像头输入
@property (nonatomic, strong) AVCaptureDeviceInput *backCameraInput;
/// 麦克风输入
@property (nonatomic, strong) AVCaptureDeviceInput *microphoneInput;
/// 视频数据输出
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
/// 音频数据输出
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;

@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;

@property (nonatomic, assign) int captureFormat;

@property (nonatomic, assign) AVCaptureSessionPreset captureSessionPreset;
/// 操作队列
@property (nonatomic, strong) dispatch_queue_t operationQueue;
/// 视频采集队列
@property (nonatomic, strong) dispatch_queue_t videoCaptureQueue;
/// 音频采集队列
@property (nonatomic, strong) dispatch_queue_t audioCaptureQueue;

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
        _captureDevicePosition = position;
        _captureFormat = captureFormat;
        _captureSessionPreset = preset;
    }
    return self;
}

#pragma mark - Instance methods

- (void)startCapturing {
    @weakify(self)
    [self addOperationToOperationQueueWithBlock:^{
        @strongify(self)
        if (!self.captureSession.isRunning) {
            [self.captureSession startRunning];
        }
    }];
}

- (void)stopCapturing {
    @weakify(self)
    [self addOperationToOperationQueueWithBlock:^{
        @strongify(self)
        if (self.captureSession.isRunning) {
            [self.captureSession stopRunning];
        }
    }];
}

#pragma mark - Private methods

- (void)addOperationToOperationQueueWithBlock:(dispatch_block_t)block {
    block();
    if (dispatch_get_specific(operationQueueKey)) {
        block();
    } else {
        dispatch_sync(self.operationQueue, ^{
            block();
        });
    }
}

#pragma mark - AVCaptureDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (output == self.videoDataOutput) {
        NSLog(@"⭐️视频输出");
    } else {
        NSLog(@"⭐️音频输出");
    }
}

#pragma mark - Getters

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        @weakify(self)
        [self addOperationToOperationQueueWithBlock:^{
            @strongify(self)
            self->_captureSession = [[AVCaptureSession alloc] init];
            [self->_captureSession beginConfiguration];
            AVCaptureDeviceInput *input = self.captureDevicePosition == AVCaptureDevicePositionFront ? self.frontCameraInput : self.backCameraInput;
            if ([self->_captureSession canAddInput:input]) {
                [self->_captureSession addInput:input];
            }
            if ([self->_captureSession canAddInput:self.microphoneInput]) {
                [self->_captureSession addInput:self.microphoneInput];
            }
            if ([self->_captureSession canAddOutput:self.videoDataOutput]) {
                [self->_captureSession addOutput:self.videoDataOutput];
            }
            if ([self->_captureSession canAddOutput:self.audioDataOutput]) {
                [self->_captureSession addOutput:self.audioDataOutput];
            }
            if ([self->_captureSession canSetSessionPreset:self.captureSessionPreset]) {
                self->_captureSession.sessionPreset = self.captureSessionPreset;
            } else {
                self->_captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
            }
            if ([input.device lockForConfiguration:nil]) {
                input.device.activeVideoMaxFrameDuration = CMTimeMake(1, 30);
                [input.device unlockForConfiguration];
            }
            [self->_captureSession commitConfiguration];
        }];
    }
    return _captureSession;
}

- (AVCaptureConnection *)captureConnetion {
    if (!_captureConnetion) {
        @weakify(self)
        [self addOperationToOperationQueueWithBlock:^{
            @strongify(self)
            self->_captureConnetion = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
            self->_captureConnetion.automaticallyAdjustsVideoMirroring = NO;
            [self->_captureConnetion setVideoOrientation:AVCaptureVideoOrientationPortrait];
            if (self->_captureConnetion.supportsVideoMirroring && self.captureDevicePosition == AVCaptureDevicePositionFront) {
                self->_captureConnetion.videoMirrored = YES;
            } else {
                self->_captureConnetion.videoMirrored = NO;
            }
        }];
    }
    return _captureConnetion;
}

- (AVCaptureDeviceInput *)frontCameraInput {
    if (!_frontCameraInput) {
        NSError *error = nil;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        if (error) {
            NSLog(@"获取前置摄像头失败");
        }
    }
    return _frontCameraInput;
}

- (AVCaptureDeviceInput *)backCameraInput {
    if (!_backCameraInput) {
        NSError *error = nil;
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        if (error) {
            NSLog(@"获取后置摄像头失败");
        }
    }
    return _backCameraInput;
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
        [_audioDataOutput setSampleBufferDelegate:self queue:self.audioCaptureQueue];
    }
    return _audioDataOutput;
}

- (AVCaptureVideoDataOutput *)videoDataOutput {
    if (!_videoDataOutput) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(self.captureFormat)};
        [_videoDataOutput setSampleBufferDelegate:self queue:self.videoCaptureQueue];
    }
    return _videoDataOutput;
}

- (dispatch_queue_t)operationQueue {
    if (!_operationQueue) {
        _operationQueue = dispatch_queue_create("xiang.operationQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_operationQueue, &operationQueueKey, (__bridge void *)self, NULL);
    }
    return _operationQueue;
}

- (dispatch_queue_t)videoCaptureQueue {
    if (!_videoCaptureQueue) {
        _videoCaptureQueue = dispatch_queue_create("xiang.videoCaptureQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _videoCaptureQueue;
}

- (dispatch_queue_t)audioCaptureQueue {
    if (!_audioCaptureQueue) {
        _audioCaptureQueue = dispatch_queue_create("xiang.audioCaptureQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _audioCaptureQueue;
}

@end
