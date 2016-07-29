//
//  LYPopoverViewController.m
//  LvYue
//
//  Created by KentonYu on 16/7/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYPopoverViewController.h"

@implementation LYPopoverTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label  = [[UILabel alloc] init];
            label.font      = [UIFont systemFontOfSize:14.f];
            label.textColor = [UIColor blackColor];
            label;
        });
    }
    return _titleLabel;
}

- (void)configTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.titleLabel.frame = CGRectMake((self.contentView.width - self.titleLabel.width) / 2.f, (30.f - self.titleLabel.height) / 2.f, self.titleLabel.width, self.titleLabel.height);
}

@end


static NSString *const LYPopoverTableViewCellIdentity = @"LYPopoverTableViewCellIdentity";

@interface LYPopoverViewController () <
    UITableViewDataSource,
    UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LYPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView reloadData];
}

#pragma mark TableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemInfoArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LYPopoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LYPopoverTableViewCellIdentity forIndexPath:indexPath];
    [cell configTitle:self.itemInfoArray[indexPath.row][@"title"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.itemInfoArray[indexPath.row][@"block"]) {
        LYPopoverTableViewCellSelectedBlock block = self.itemInfoArray[indexPath.row][@"block"];
        block();
        // 释放 Block
        block = nil;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView   = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
            tableView.delegate       = self;
            tableView.dataSource     = self;
            tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
            [tableView registerClass:[LYPopoverTableViewCell class] forCellReuseIdentifier:LYPopoverTableViewCellIdentity];
            [self.view addSubview:tableView];
            tableView;
        });
    }
    return _tableView;
}


@end
