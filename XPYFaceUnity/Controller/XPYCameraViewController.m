//
//  XPYCameraViewController.m
//  XPYCamera
//
//  Created by 项林平 on 2021/4/12.
//

#import "XPYCameraViewController.h"
#import "XPYCamera.h"
#import "XPYGLRenderView.h"
#import "XPYGLDefines.h"

#import "XPYDropdownDefine.h"

#import <AVFoundation/AVFoundation.h>

@interface XPYCameraViewController ()<XPYCameraDelegate, XPYDropdownViewDelegate>

@property (nonatomic, strong) XPYCamera *camera;

@property (nonatomic, strong) XPYGLRenderView *renderView;

@end

@implementation XPYCameraViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.renderView = [[XPYGLRenderView alloc] initWithFrame:self.view. bounds];
    self.renderView.renderContentMode = XPYGLRenderViewContentModeAspectFill;
    [self.view addSubview:self.renderView];
    
    //预览层
    self.camera = [[XPYCamera alloc] initWithCameraPosition:AVCaptureDevicePositionFront captureFormat:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange captureSessionPreset:AVCaptureSessionPreset1920x1080];
    self.camera.delegate = self;
    
    NSLog(@"===%@===", self.camera.captureSessionPreset);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换" style:UIBarButtonItemStylePlain target:self action:@selector(switchAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分辨率" style:UIBarButtonItemStylePlain target:self action:@selector(switchPresetAction:)];
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
    XPYDropdownConfigurations *config = [[XPYDropdownConfigurations alloc] init];
    config.dropdownBackgroundColor = [UIColor blackColor];
    config.mainBackgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    config.cellSelectedColor = [UIColor colorWithWhite:0 alpha:0.2];
    config.titleColor = [UIColor whiteColor];

    XPYDropdownItemModel *model1 = [XPYDropdownItemModel makeModel:1 icon:nil title:@"480x640" titleColor:nil];
    XPYDropdownItemModel *model2 = [XPYDropdownItemModel makeModel:2 icon:nil title:@"720x1280" titleColor:nil];
    XPYDropdownItemModel *model3 = [XPYDropdownItemModel makeModel:3 icon:nil title:@"1080x1920" titleColor:nil];

    CGFloat pointX = CGRectGetWidth(self.view.bounds) - 50.f;
    
    CGFloat pointY = 64;
    if (@available(iOS 11.0, *)) {
        pointY = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top + 44;
    }
    XPYDropdownView *dropdownView = [[XPYDropdownView alloc] initWithItemsArray:@[model1, model2, model3] configurations:config arrowPoint:CGPointMake(pointX, pointY)];
    dropdownView.delegate = self;
    [dropdownView show];
}

- (void)dropdownView:(XPYDropdownView *)sender didClickItem:(XPYDropdownItemModel *)model {
    switch (model.itemIndex) {
        case 1:
            [self.camera switchSessionPreset:AVCaptureSessionPreset640x480];
            break;
        case 2:
            [self.camera switchSessionPreset:AVCaptureSessionPreset1280x720];
            break;
        case 3:
            [self.camera switchSessionPreset:AVCaptureSessionPreset1920x1080];
            break;
        default:
            break;
    }
}

- (void)camera:(XPYCamera *)camera didOutputAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}

- (void)camera:(XPYCamera *)camera didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [self.renderView renderBuffer:buffer];
}

@end
