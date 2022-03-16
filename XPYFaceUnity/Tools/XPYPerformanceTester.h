//
//  XPYPerformanceTester.h
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/2/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYPerformanceTester : NSObject

+ (instancetype)sharedTester;

/// 默认配置（CPU, Memory）
- (BOOL)setup;

/// 自定义配置
/// @param itemsString 额外测试项（为空时默认配置）
/// @param fileName 结果输出文件名（为空时默认为当前时间）
/// @param needsDefaultItems 是否需要默认测试项（YES：默认测试项后面拼接自定义测试项 NO：只输出自定义测试项）
- (BOOL)setupWithItems:(nullable NSString *)itemsString
              fileName:(nullable NSString *)fileName
     needsDefaultItems:(BOOL)needsDefaultItems;

/// 写入一次测试结果
/// @param dataString 测试数据
- (void)writeData:(nullable NSString *)dataString;

/// 帧率测试
- (void)frameRateTest;

@end

NS_ASSUME_NONNULL_END
