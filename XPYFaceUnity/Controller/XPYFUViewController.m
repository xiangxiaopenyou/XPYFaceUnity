//
//  XPYFUViewController.m
//  XPYCamera
//
//  Created by 项林平 on 2021/6/11.
//

#import "XPYFUViewController.h"
#import "FUDemoManager.h"
#import "FUManager.h"
#import "XPYPerformanceTester.h"

@interface XPYFUViewController ()<FURenderKitDelegate>

@property (nonatomic, strong) FUGLDisplayView *displayView;

@end

@implementation XPYFUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.displayView];
    
    [[FUManager shareManager] startCaptureWithDisplayView:self.displayView renderDelegate:self];
    
    CGFloat height = 0;
    if (@available(iOS 11.0, *)) {
        height = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    [FUDemoManager setupFaceUnityDemoInController:self originY:CGRectGetHeight(self.view.frame) - 100 - height];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[FURenderKit shareRenderKit] stopInternalCamera];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[FURenderKit shareRenderKit] startInternalCamera];
}

#pragma mark - FURenderKitDelegate
- (BOOL)renderKitShouldDoRender {
    return YES;
}
- (void)renderKitWillRenderFromRenderInput:(FURenderInput *)renderInput {
}
- (void)renderKitDidRenderToOutput:(FURenderOutput *)renderOutput {
    
}

#pragma mark - Getters

- (FUGLDisplayView *)displayView {
    if (!_displayView) {
        _displayView = [[FUGLDisplayView alloc] initWithFrame:self.view.bounds];
    }
    return _displayView;
}

@end
