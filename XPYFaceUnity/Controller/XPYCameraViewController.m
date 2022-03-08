//
//  XPYCameraViewController.m
//  XPYCamera
//
//  Created by 项林平 on 2021/4/12.
//

#import "XPYCameraViewController.h"
#import "XPYCamera.h"

#import <AVFoundation/AVFoundation.h>

@interface XPYCameraViewController ()

@property (nonatomic, strong) XPYCamera *camera;

@end

@implementation XPYCameraViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //预览层
    self.camera = [[XPYCamera alloc] init];
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.camera.captureSession];
    previewLayer.frame = self.view.layer.frame;
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    
    NSLog(@"===%@===", self.camera.captureSessionPreset);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换" style:UIBarButtonItemStylePlain target:self action:@selector(switchAction:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分辨率" style:UIBarButtonItemStylePlain target:self action:@selector(switchPresetAction:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.camera startCapture];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.camera stopCapture];
}

- (void)switchAction:(UIBarButtonItem *)sender {
    [self.camera switchDevicePosition];
}

- (void)switchPresetAction:(UIBarButtonItem *)sender {
    [self.camera switchSessionPreset:AVCaptureSessionPreset640x480];
    NSLog(@"===%@===", self.camera.captureSessionPreset);
}

@end
