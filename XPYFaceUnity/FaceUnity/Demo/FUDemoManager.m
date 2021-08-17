//
//  FUDemoManager.m
//  FUDemo
//
//  Created by 项林平 on 2021/6/17.
//

#import "FUDemoManager.h"
#import "FUBottomBar.h"
#import "FUBeautyFunctionView.h"
#import "FUOthersFunctionView.h"

#import "FUBeautySkinViewModel.h"
#import "FUBeautyShapeViewModel.h"
#import "FUFilterViewModel.h"
#import "FUStickerViewModel.h"
#import "FUMakeupViewModel.h"
#import "FUBeautyBodyViewModel.h"

@interface FUDemoManager ()<FUFunctionViewDelegate>

/// 底部功能选择栏
@property (nonatomic, strong) FUBottomBar *bottomBar;
/// 美肤功能视图
@property (nonatomic, strong) FUBeautyFunctionView *skinView;
/// 美型功能视图
@property (nonatomic, strong) FUBeautyFunctionView *shapeView;
/// 滤镜功能视图
@property (nonatomic, strong) FUOthersFunctionView *filterView;
/// 贴纸功能视图
@property (nonatomic, strong) FUOthersFunctionView *stickerView;
/// 美妆功能视图
@property (nonatomic, strong) FUOthersFunctionView *makeupView;
/// 美体功能视图
@property (nonatomic, strong) FUBeautyFunctionView *bodyView;

@property (nonatomic, strong) FUBeautySkinViewModel *beautySkinViewModel;
@property (nonatomic, strong) FUBeautyShapeViewModel *beautyShapeViewModel;
@property (nonatomic, strong) FUFilterViewModel *filterViewModel;
@property (nonatomic, strong) FUStickerViewModel *stickerViewModel;
@property (nonatomic, strong) FUMakeupViewModel *makeupViewModel;
@property (nonatomic, strong) FUBeautyBodyViewModel *beautyBodyViewModel;

/// 全部模块
@property (nonatomic, copy) NSArray<FUViewModel *> *viewModels;

/// 全部功能视图数组
@property (nonatomic, copy) NSArray<FUFunctionView *> *moduleViews;

/// 当前正在显示的视图对应的模块类型，-1表示当前无功能视图显示
@property (nonatomic, assign) FUModuleType showingModuleType;

@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, assign) CGFloat demoOriginY;

@end

@implementation FUDemoManager

#pragma mark - Class methods
+ (instancetype)setupFaceUnityDemoInView:(UIView *)view originY:(CGFloat)originY {
    return [[self alloc] initWithTargetView:view originY:originY];
}

#pragma mark - Initialization
- (instancetype)initWithTargetView:(UIView *)view originY:(CGFloat)originY {
    self = [super init];
    if (self) {
        NSAssert(view != nil, @"目标视图不能为空");
        self.targetView = view;
        self.demoOriginY = originY;
        
        // 加载默认效果
        NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification" ofType:@"bundle"];
        FUBeauty *beauty = [[FUBeauty alloc] initWithPath:path name:@"FUBeauty"];
        // 默认精细磨皮
        beauty.heavyBlur = 0;
        beauty.blurType = 2;
        // 默认自定义脸型
        beauty.faceShape = 4;
        [FURenderKit shareRenderKit].beauty = beauty;
        
        // 设置美肤、美型、滤镜的默认值
        [self.beautySkinViewModel recover];
        [self.beautyShapeViewModel recover];
        [self.filterViewModel recover];
        
        [view addSubview:self.bottomBar];
        [view addSubview:self.skinView];
        [view addSubview:self.shapeView];
        [view addSubview:self.filterView];
        [view addSubview:self.stickerView];
        [view addSubview:self.makeupView];
        [view addSubview:self.bodyView];
        
        // 分割线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, originY, CGRectGetWidth(view.bounds), 1)];
        lineView.backgroundColor = [UIColor colorWithRed:229/ 255.f green:229/255.f blue:229/255.f alpha:0.2];
        [view addSubview:lineView];
    }
    return self;
}

#pragma mark - Private methods
- (void)resolveModuleOperations:(NSInteger)item {
    NSInteger count = self.moduleViews.count;
    if (item >= count) {
        return;
    }
    
    if (item == -1) {
        // 隐藏当前视图
        [self hideFunctionView:self.moduleViews[self.showingModuleType] animated:YES];
    } else {
        // 获取需要显示的目标视图
        if (self.showingModuleType >= 0) {
            // 当前已经有显示的视图时，需要先隐藏当前视图，再显示目标视图
            [self hideFunctionView:self.moduleViews[self.showingModuleType] animated:NO];
            [self showFunctionView:self.moduleViews[item]];
        } else {
            // 当前无显示的视图时，直接显示目标视图
            [self showFunctionView:self.moduleViews[item]];
        }
    }
    // 保存显示的类型
    self.showingModuleType = item;
}


/// 显示功能视图
/// @param functionView 功能视图
- (void)showFunctionView:(FUFunctionView *)functionView {
    if (!functionView) {
        return;
    }
    functionView.hidden = NO;
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        functionView.transform = CGAffineTransformMakeScale(1, 1);
        functionView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}


/// 隐藏功能视图
/// @param functionView 功能视图
/// @param animated 是否需要动画（切换功能时先隐藏当前显示的视图不需要动画，直接隐藏时需要动画）
- (void)hideFunctionView:(FUFunctionView *)functionView animated:(BOOL)animated {
    if (!functionView) {
        return;
    }
    if (animated) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            functionView.transform = CGAffineTransformMakeScale(1, 0.001);
            functionView.alpha = 0;
        } completion:^(BOOL finished) {
            functionView.hidden = YES;
        }];
    } else {
        functionView.transform = CGAffineTransformMakeScale(1, 0.001);
        functionView.alpha = 0;
        functionView.hidden = YES;
    }
}

#pragma mark - FUFunctionViewDelegate
- (void)functionView:(FUFunctionView *)functionView didSelectFunctionAtIndex:(NSInteger)index {
    FUViewModel *viewModel = functionView.viewModel;
    viewModel.selectedIndex = index;
    [viewModel updateData:viewModel.model.moduleData[index]];
    if (!viewModel.isRendering) {
        [viewModel startRender];
    }
}

- (void)functionView:(FUFunctionView *)functionView didChangeSliderValue:(CGFloat)value {
    NSLog(@"%@", @(value));
    FUSubModel *subModel = functionView.viewModel.model.moduleData[functionView.viewModel.selectedIndex];
    subModel.currentValue = value * subModel.ratio;
    [functionView.viewModel updateData:subModel];
}

- (void)functionViewDidEndSlide:(FUFunctionView *)functionView {
    switch (functionView.viewModel.model.type) {
        case FUModuleTypeBeautySkin:{
            [self.skinView refreshSubViews];
        }
            break;
        case FUModuleTypeBeautyShape:{
            [self.shapeView refreshSubViews];
        }
            break;
        case FUModuleTypeBeautyBody:{
            [self.bodyView refreshSubViews];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Getters
- (FUBottomBar *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[FUBottomBar alloc] initWithFrame:CGRectMake(0, self.demoOriginY, CGRectGetWidth(self.targetView.bounds), FUBottomBarHeight) viewModels:self.viewModels moduleOperationHandler:^(NSInteger item) {
            [self resolveModuleOperations:item];
        }];
    }
    return _bottomBar;
}

- (FUBeautyFunctionView *)skinView {
    if (!_skinView) {
        _skinView = [[FUBeautyFunctionView alloc] initWithFrame:CGRectMake(0, self.demoOriginY - FUFunctionViewHeight, CGRectGetWidth(self.targetView.bounds), FUFunctionViewHeight) viewModel:self.viewModels[FUModuleTypeBeautySkin]];
        _skinView.delegate = self;
    }
    return _skinView;
}

- (FUBeautyFunctionView *)shapeView {
    if (!_shapeView) {
        _shapeView = [[FUBeautyFunctionView alloc] initWithFrame:CGRectMake(0, self.demoOriginY - FUFunctionViewHeight, CGRectGetWidth(self.targetView.bounds), FUFunctionViewHeight) viewModel:self.viewModels[FUModuleTypeBeautyShape]];
        _shapeView.delegate = self;
    }
    return _shapeView;
}

- (FUOthersFunctionView *)filterView {
    if (!_filterView) {
        _filterView = [[FUOthersFunctionView alloc] initWithFrame:CGRectMake(0, self.demoOriginY - FUFunctionViewHeight, CGRectGetWidth(self.targetView.bounds), FUFunctionViewHeight) viewModel:self.viewModels[FUModuleTypeFilter]];
        _filterView.delegate = self;
    }
    return _filterView;
}

- (FUOthersFunctionView *)stickerView {
    if (!_stickerView) {
        _stickerView = [[FUOthersFunctionView alloc] initWithFrame:CGRectMake(0, self.demoOriginY - FUFunctionViewHeight, CGRectGetWidth(self.targetView.bounds), FUFunctionViewHeight) viewModel:self.viewModels[FUModuleTypeSticker]];
        _stickerView.delegate = self;
    }
    return _stickerView;
}

- (FUOthersFunctionView *)makeupView {
    if (!_makeupView) {
        _makeupView = [[FUOthersFunctionView alloc] initWithFrame:CGRectMake(0, self.demoOriginY - FUFunctionViewHeight, CGRectGetWidth(self.targetView.bounds), FUFunctionViewHeight) viewModel:self.viewModels[FUModuleTypeMakeup]];
        _makeupView.delegate = self;
    }
    return _makeupView;
}

- (FUBeautyFunctionView *)bodyView {
    if (!_bodyView) {
        _bodyView = [[FUBeautyFunctionView alloc] initWithFrame:CGRectMake(0, self.demoOriginY - FUFunctionViewHeight, CGRectGetWidth(self.targetView.bounds), FUFunctionViewHeight) viewModel:self.viewModels[FUModuleTypeBeautyBody]];
        _bodyView.delegate = self;
    }
    return _bodyView;
}

- (NSArray<FUViewModel *> *)viewModels {
    if (!_viewModels) {
        _viewModels = [@[self.beautySkinViewModel, self.beautyShapeViewModel, self.filterViewModel, self.stickerViewModel, self.makeupViewModel, self.beautyBodyViewModel] copy];
    }
    return _viewModels;
}

- (NSArray<FUFunctionView *> *)moduleViews {
    if (!_moduleViews) {
        _moduleViews = [@[self.skinView, self.shapeView, self.filterView, self.stickerView, self.makeupView, self.bodyView] copy];
    }
    return _moduleViews;
}

- (FUBeautySkinViewModel *)beautySkinViewModel {
    if (!_beautySkinViewModel) {
        _beautySkinViewModel = [[FUBeautySkinViewModel alloc] initWithSelectedIndex:-1 needSlider:YES];
    }
    return _beautySkinViewModel;
}

- (FUBeautyShapeViewModel *)beautyShapeViewModel {
    if (!_beautyShapeViewModel) {
        _beautyShapeViewModel = [[FUBeautyShapeViewModel alloc] initWithSelectedIndex:-1 needSlider:YES];
    }
    return _beautyShapeViewModel;
}

- (FUFilterViewModel *)filterViewModel {
    if (!_filterViewModel) {
        _filterViewModel = [[FUFilterViewModel alloc] initWithSelectedIndex:1 needSlider:YES];
    }
    return _filterViewModel;
}

- (FUStickerViewModel *)stickerViewModel {
    if (!_stickerViewModel) {
        _stickerViewModel = [[FUStickerViewModel alloc] initWithSelectedIndex:0 needSlider:NO];
    }
    return _stickerViewModel;
}

- (FUMakeupViewModel *)makeupViewModel {
    if (!_makeupViewModel) {
        _makeupViewModel = [[FUMakeupViewModel alloc] initWithSelectedIndex:0 needSlider:YES];
    }
    return _makeupViewModel;
}

- (FUBeautyBodyViewModel *)beautyBodyViewModel {
    if (!_beautyBodyViewModel) {
        _beautyBodyViewModel = [[FUBeautyBodyViewModel alloc] initWithSelectedIndex:-1 needSlider:YES];
    }
    return _beautyBodyViewModel;
}


@end
