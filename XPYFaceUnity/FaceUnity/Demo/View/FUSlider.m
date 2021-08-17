//
//  FUSlider.m
//  FUAPIDemoBar
//
//  Created by L on 2018/6/27.
//  Copyright © 2018年 L. All rights reserved.
//

#import "FUSlider.h"

@interface FUSlider ()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UIView *line;

@end

@implementation FUSlider

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setThumbImage:[UIImage imageNamed:@"expource_slider_dot"] forState:UIControlStateNormal];
        [self setMinimumTrackTintColor:[UIColor colorWithRed:55/255.0 green:151/255.0 blue:240/255.0 alpha:1]];
        [self setMaximumTrackTintColor:[UIColor whiteColor]];
        
        UIImage *bgImage = [UIImage imageNamed:@"slider_tip_bg"];
        self.bgImgView = [[UIImageView alloc] initWithImage:bgImage];
        self.bgImgView.frame = CGRectMake(0, -bgImage.size.height, bgImage.size.width, bgImage.size.height);
        [self addSubview:self.bgImgView];
        
        self.tipLabel = [[UILabel alloc] initWithFrame:self.bgImgView.frame];
        self.tipLabel.textColor = [UIColor darkGrayColor];
        self.tipLabel.font = [UIFont systemFontOfSize:14];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.tipLabel];
        
        self.bgImgView.hidden = YES;
        self.tipLabel.hidden = YES;
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_middleView) {
        CGFloat middY = [self getSubViewsMidY];
        self.middleView = [[UIView alloc] initWithFrame:CGRectMake(2, middY, 100, 4)];
        self.middleView.backgroundColor = [UIColor colorWithRed:55/255.0 green:151/255.0 blue:240/255.0 alpha:1];
        self.middleView.hidden = YES;
        [self insertSubview:self.middleView atIndex: self.subviews.count - 1];
    }
    
    if (!_line) {
        self.line = [[UIView alloc] init];
        self.line.backgroundColor = [UIColor whiteColor];
        self.line.layer.masksToBounds = YES ;
        self.line.layer.cornerRadius = 1.0 ;
        self.line.hidden = YES;
        [self insertSubview:self.line atIndex: self.subviews.count - 1];
    }
    
    self.line.frame = CGRectMake(CGRectGetWidth(self.frame) / 2.0 - 1.0, CGRectGetHeight(self.frame) / 2.0 - 4.5, 2.0, 9.0) ;
    
    CGFloat value = self.value ;
    [self setValue:value animated:NO];
}


- (CGFloat)getSubViewsMidY {
    CGFloat midY = 7.0;
    //暂时hock 系统slider 进度条的位置，后续有改变再修改即可（个人认为变动几率不是很大）
    for (UIView *subView in self.subviews) {
        Class subViewClass = NSClassFromString(@"_UISlideriOSVisualElement");
        if ([subView isKindOfClass:subViewClass]) {
            for (UIView *desView in subView.subviews) {
                if ([desView isKindOfClass:[UIView class]]) {
                    midY = desView.frame.origin.y;
                    break;
                }
            }
        }
    }
    return midY;
}

- (void)setBidirection:(BOOL)bidirection {
    _bidirection = bidirection;
    if (bidirection) {
        self.line.hidden = NO ;
        self.middleView.hidden = NO ;
        [self setMinimumTrackTintColor:[UIColor whiteColor]];
    } else {
        self.line.hidden = YES ;
        self.middleView.hidden = YES ;
        [self setMinimumTrackTintColor:[UIColor colorWithRed:55/255.0 green:151/255.0 blue:240/255.0 alpha:1]];
    }
}


// 后设置 value
- (void)setValue:(float)value animated:(BOOL)animated   {
    [super setValue:value animated:animated];

    if (_bidirection) {
        self.tipLabel.text = [NSString stringWithFormat:@"%d",(int)(value * 100 - 50)];
        CGFloat currentValue = value - 0.5 ;
        CGFloat width = currentValue * (self.frame.size.width - 4);
        if (width < 0 ) {
            width = -width ;
        }
        CGFloat X = currentValue > 0 ? self.frame.size.width / 2.0 : self.frame.size.width / 2.0 - width ;
        CGRect frame = self.middleView.frame ;
        frame = CGRectMake(X, frame.origin.y, width, frame.size.height) ;
        self.middleView.frame = frame ;
    } else {
        self.tipLabel.text = [NSString stringWithFormat:@"%d",(int)(value * 100)];
    }
    
    CGFloat x = value * (self.frame.size.width - 20) - self.tipLabel.frame.size.width * 0.5 + 10;
    CGRect frame = self.tipLabel.frame;
    frame.origin.x = x;
    
    self.bgImgView.frame = frame;
    self.tipLabel.frame = frame;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.tipLabel.hidden = NO;
    self.bgImgView.hidden = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.tipLabel.hidden = YES;
    self.bgImgView.hidden = YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.tipLabel.hidden = YES;
    self.bgImgView.hidden = YES;
}

@end
