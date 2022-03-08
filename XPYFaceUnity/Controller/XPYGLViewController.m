//
//  XPYGLViewController.m
//  XPYCamera
//
//  Created by 项林平 on 2021/4/23.
//

#import "XPYGLViewController.h"

#import "XPYGLModel.h"

#import "XPYGLBackgroundView.h"
#import "XPYGLTriangleView.h"
#import "XPYGLPictureRenderView.h"

@interface XPYGLViewController ()

@property (nonatomic, strong) XPYGLModel *glModel;

@end

@implementation XPYGLViewController

- (instancetype)initWithGLModel:(XPYGLModel *)glModel {
    self = [super init];
    if (self) {
        self.glModel = glModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.title = self.glModel.title;
    
    switch (self.glModel.type) {
        case XPYGLViewTypeBackground:{
            XPYGLBackgroundView *glView = [[XPYGLBackgroundView alloc] initWithFrame:self.view.bounds];
            [self.view addSubview:glView];
        }
            break;
        case XPYGLViewTypeTriangle:{
            XPYGLTriangleView *glTriangleView = [[XPYGLTriangleView alloc] initWithFrame:self.view.bounds];
            [self.view addSubview:glTriangleView];
        }
            break;
        case XPYGLViewTypeCircle: {
            
        }
            break;
        case XPYGLViewTypePicture: {
            XPYGLPictureRenderView *renderView = [[XPYGLPictureRenderView alloc] initWithFrame:self.view.bounds];
            [self.view addSubview:renderView];
        }
            break;
    }
}

@end
