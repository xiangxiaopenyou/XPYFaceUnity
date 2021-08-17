//
//  XPYCameraViewController.m
//  XPYCamera
//
//  Created by 项林平 on 2021/4/12.
//

#import "XPYCameraViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "XPYTools.h"

#import "XPYGLView.h"

typedef NS_ENUM(NSInteger, XPYCaptureDeviceType) {
    XPYCaptureDeviceTypeFrontCamera,    // 前置摄像头
    XPYCaptureDeviceTypeBackCamera,     // 后置摄像头
    XPYCaptureDeviceTypeMicrophone      // 麦克风
};

@interface XPYCameraViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

/// 用于输入设备和输出设备的数据传递
@property (nonatomic, strong) AVCaptureSession *session;
/// 前置摄像头输入流对象
@property (nonatomic, strong) AVCaptureDeviceInput *frontDeviceInput;
/// 后置摄像头输入流对象
@property (nonatomic, strong) AVCaptureDeviceInput *backDeviceInput;
/// 麦克风输入
@property (nonatomic, strong) AVCaptureDeviceInput *microphoneDeviceInput;
/// 照片输出流对象
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
/// 视频输出流对象
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
/// 视频文件输出流
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutPut;

@property (nonatomic, strong) dispatch_queue_t videoOutputQueue;

@end

@implementation XPYCameraViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self.view.backgroundColor = [UIColor whiteColor];
    self.view = [[XPYGLView alloc] initWithFrame:self.view.bounds];
    
    //预览层
//    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
//    previewLayer.frame = self.view.layer.frame;
//
//    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
//    [self.view.layer insertSublayer:previewLayer atIndex:0];
//
//    [self.session startRunning];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}


#pragma mark - Getters
- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        [_session beginConfiguration];
        // 默认前置摄像头
        if ([_session canAddInput:self.frontDeviceInput]) {
            [_session addInput:self.frontDeviceInput];
        }
        if ([_session canAddOutput:self.imageOutput]) {
            [_session addOutput:self.imageOutput];
        }
        if ([_session canAddOutput:self.videoOutput]) {
            [_session addOutput:self.videoOutput];
        }
        if ([self.frontDeviceInput.device lockForConfiguration:nil]) {
            [self.frontDeviceInput.device setActiveVideoMaxFrameDuration:CMTimeMake(1, 30)];
            [self.frontDeviceInput.device unlockForConfiguration];
        }
        [_session commitConfiguration];
    }
    return _session;
}
- (AVCaptureDeviceInput *)frontDeviceInput {
    if (!_frontDeviceInput) {
        _frontDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self deviceWithDeviceType:XPYCaptureDeviceTypeFrontCamera] error:nil];
    }
    return _frontDeviceInput;
}
- (AVCaptureDeviceInput *)backDeviceInput {
    if (!_backDeviceInput) {
        _backDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self deviceWithDeviceType:XPYCaptureDeviceTypeBackCamera] error:nil];
    }
    return _backDeviceInput;
}
- (AVCaptureDeviceInput *)microphoneDeviceInput {
    if (!_microphoneDeviceInput) {
        _microphoneDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self deviceWithDeviceType:XPYCaptureDeviceTypeMicrophone] error:nil];
    }
    return _microphoneDeviceInput;
}

- (AVCaptureStillImageOutput *)imageOutput {
    if (!_imageOutput) {
        _imageOutput = [[AVCaptureStillImageOutput alloc] init];
        [_imageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
    }
    return _imageOutput;
}

- (AVCaptureVideoDataOutput *)videoOutput {
    if (!_videoOutput) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setAlwaysDiscardsLateVideoFrames:YES];
        [_videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        [_videoOutput setSampleBufferDelegate:self queue:self.videoOutputQueue];
    }
    return _videoOutput;
}

- (dispatch_queue_t)videoOutputQueue {
    if (!_videoOutputQueue) {
        _videoOutputQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    }
    return _videoOutputQueue;
}

/// 获取设备
/// @param deviceType 设备类型
- (AVCaptureDevice *)deviceWithDeviceType:(XPYCaptureDeviceType)deviceType {
    switch (deviceType) {
        case XPYCaptureDeviceTypeFrontCamera:{
            if (@available(iOS 10.0, *)) {
                return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
            } else {
                NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
                for (AVCaptureDevice *device in devices) {
                    if (device.position == AVCaptureDevicePositionFront) {
                        return device;
                    }
                }
                return nil;
            }
        }
            break;
        case XPYCaptureDeviceTypeBackCamera:{
            if (@available(iOS 10.0, *)) {
                return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
            } else {
                NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
                for (AVCaptureDevice *device in devices) {
                    if (device.position == AVCaptureDevicePositionBack) {
                        return device;
                    }
                }
                return nil;
            }
        }
            break;
        case XPYCaptureDeviceTypeMicrophone:{
            if (@available(iOS 10.0, *)) {
                return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInMicrophone mediaType:AVMediaTypeAudio position:AVCaptureDevicePositionUnspecified];
            } else {
                return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            }
        }
            break;
    }
}

@end
