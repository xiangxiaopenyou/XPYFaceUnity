//
//  FUSlider.h
//  FUAPIDemoBar
//
//  Created by L on 2018/6/27.
//  Copyright © 2018年 L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FUSlider : UISlider

/// 是否从中间双向滑动
@property (nonatomic, assign, getter=isBidirection) BOOL bidirection;

@end
