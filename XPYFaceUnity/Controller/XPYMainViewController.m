//
//  XPYMainViewController.m
//  XPYCamera
//
//  Created by 项林平 on 2021/4/23.
//

#import "XPYMainViewController.h"
#import "XPYGLViewController.h"
#import "XPYGLModel.h"

@interface XPYMainViewController ()

@property (nonatomic, copy) NSArray<XPYGLModel *> *dataSource;

@end

@implementation XPYMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"XPYMainCell"];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XPYMainCell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.row].title;
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XPYGLViewController *glController = [[XPYGLViewController alloc] initWithGLModel:self.dataSource[indexPath.row]];
    [self.navigationController pushViewController:glController animated:YES];
}

#pragma mark - Getters
- (NSArray *)dataSource {
    if (!_dataSource) {
        
        XPYGLModel *model1 = [[XPYGLModel alloc] init];
        model1.type = XPYGLViewTypeBackground;
        model1.title = @"基本背景";
        
        XPYGLModel *model2 = [[XPYGLModel alloc] init];
        model2.type = XPYGLViewTypeTriangle;
        model2.title = @"三角形";
        
        XPYGLModel *model3 = [[XPYGLModel alloc] init];
        model3.type = XPYGLViewTypeCircle;
        model3.title = @"圆形";
        
        _dataSource = @[model1, model2, model3];
    }
    return _dataSource;
}

@end
