//
//  XPYFUViewController.m
//  XPYCamera
//
//  Created by 项林平 on 2021/6/11.
//

#import "XPYFUViewController.h"
#import "FUDemoManager.h"
#import "FUManager.h"

@interface XPYFUViewController ()<FURenderKitDelegate>

@property (nonatomic, strong) FUGLDisplayView *displayView;

@end

@implementation XPYFUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.displayView];
    
    [[FUManager shareManager] startCaptureWithDisplayView:self.displayView renderDelegate:self];
    
    [FUDemoManager setupFaceUnityDemoInView:self.view originY:CGRectGetHeight(self.view.frame) - 100];
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
