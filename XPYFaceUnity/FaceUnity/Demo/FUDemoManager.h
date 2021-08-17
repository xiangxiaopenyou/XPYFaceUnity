//
//  FUDemoManager.h
//  FUDemo
//
//  Created by 项林平 on 2021/6/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FUDemoManager : NSObject

/// 直接调用Demo类方法
/// @param view 目标视图
/// @param originY Demo视图在目标视图上的Y坐标（这里指的是底部功能选择栏的Y坐标，X坐标默认为0）
+ (instancetype)setupFaceUnityDemoInView:(UIView *)view originY:(CGFloat)originY;

@end

NS_ASSUME_NONNULL_END
