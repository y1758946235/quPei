//
//  HomeTableView.m
//  豆客项目
//
//  Created by Xia Wei on 15/9/25.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "HomeTableView.h"
#import "HomePageTableCell.h"
#import "DetailDataViewController.h"
#import "NewHomeTableViewCell.h"

@interface HomeTableView(){
    UINib *nib;
}

@property(nonatomic,strong)NSMutableArray *sexArray;

@end

@implementation HomeTableView

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        //创建性别测试数据
        _sexArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 100;i ++) {
            [_sexArray addObject:@"female"];
        }
        _sexArray[2] = @"male";
    }
    return self;
}

//设置cell的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 84;
    return 194;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.guideArray.count;
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.guideArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    HomePageTableCell *cell = [HomePageTableCell myCellWithTableView:tableView andIndexPath:indexPath];
//    if (self.guideArray.count) {
//        HomeModel *model = self.guideArray[indexPath.row];
//         [cell fillDataWith:model];
//    }
//    return cell;
    
    NewHomeTableViewCell *cell = [NewHomeTableViewCell cellWithTableView:tableView andIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HomeModel *model = self.guideArray[indexPath.row];
    DetailDataViewController *deta = [[DetailDataViewController alloc] init];
    deta.friendId = [model.id integerValue];
    [self.navi pushViewController:deta animated:YES];
}


@end
