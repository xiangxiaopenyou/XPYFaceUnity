//
//  XPYTabBarController.m
//  XPYCamera
//
//  Created by 项林平 on 2021/6/11.
//

#import "XPYTabBarController.h"

#import "XPYMainViewController.h"
#import "XPYCameraViewController.h"

@interface XPYTabBarController ()

@end

@implementation XPYTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    XPYMainViewController *glController = [[XPYMainViewController alloc] init];
    glController.title = @"OpenGL";
    UINavigationController *navigation1 = [[UINavigationController alloc] initWithRootViewController:glController];
    
    XPYCameraViewController *cameraController = [[XPYCameraViewController alloc] init];
    cameraController.title = @"Camera";
    UINavigationController *navigation2 = [[UINavigationController alloc] initWithRootViewController:cameraController];
    
    self.tabBar.translucent = NO;
    self.tabBar.backgroundColor = [UIColor whiteColor];
    
    [self setViewControllers:@[navigation1, navigation2]];
}

@end
