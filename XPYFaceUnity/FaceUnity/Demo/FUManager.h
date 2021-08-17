//
//  FUManager.h
//  FULiveDemo
//
//  Created by 刘洋 on 2017/8/18.
//  Copyright © 2017年 刘洋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FURenderKit/FURenderKit.h>
#import <FURenderKit/FUGLDisplayView.h>

@interface FUManager : NSObject

+ (FUManager *)shareManager;

/// 调用SDK摄像头采集
/// @param displayView 展示视图
/// @param delegate 代理对象
- (void)startCaptureWithDisplayView:(FUGLDisplayView *)displayView renderDelegate:(id)delegate;

/// 销毁全部道具
- (void)destoryItems;

/// 切换摄像头
- (void)onCameraChange;

@end
