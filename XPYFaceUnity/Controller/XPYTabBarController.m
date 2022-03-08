//
//  XPYTabBarController.m
//  XPYCamera
//
//  Created by 项林平 on 2021/6/11.
//

#import "XPYTabBarController.h"

#import "XPYMainViewController.h"
#import "XPYFUViewController.h"
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
    
    XPYFUViewController *fuSDKController = [[XPYFUViewController alloc] init];
    fuSDKController.title = @"FUSDK";
    UINavigationController *navigation2 = [[UINavigationController alloc] initWithRootViewController:fuSDKController];
    
    XPYCameraViewController *cameraController = [[XPYCameraViewController alloc] init];
    cameraController.title = @"Camera";
    UINavigationController *navigation3 = [[UINavigationController alloc] initWithRootViewController:cameraController];
    
    self.tabBar.translucent = NO;
    self.tabBar.backgroundColor = [UIColor grayColor];
    
    [self setViewControllers:@[navigation1, navigation2, navigation3]];
}

@end
