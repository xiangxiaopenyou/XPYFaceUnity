//
//  AppDelegate.m
//  XPYCamera
//
//  Created by 项林平 on 2021/4/12.
//

#import "AppDelegate.h"
#import "XPYTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self.window makeKeyAndVisible];
    
    XPYTabBarController *tabBarController = [[XPYTabBarController alloc] init];
    
    self.window.rootViewController = tabBarController;
    
    return YES;
}

@end
