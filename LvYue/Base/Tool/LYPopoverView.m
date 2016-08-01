//
//  LYPopoverView.m
//  LvYue
//
//  Created by KentonYu on 16/7/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYPopoverView.h"

static LYPopoverView *popoverView;

static NSString *const LYPopoverViewTableViewCellIdentity = @"LYPopoverViewTableViewCellIdentity";
static CGFloat const LYPopoverViewItemHeight              = 35.f; // item 高度
static CGFloat const LYPopoverViewItemIconWH              = 20.f; // icon 宽高
static CGFloat const LYPopoverViewItemWordFontSize        = 16.f; // 字体大小
static CGFloat const LYPopoverViewItemEdgeH               = 10.f; // 左右内边距

@interface LYPopoverView () <
    UITableViewDelegate,
    UITableViewDataSource>

@property (nonatomic, strong) UITableView *contentTableView;

@property (nonatomic, assign) LYPopoverViewItemType type;
@property (nonatomic, weak) id<LYPopoverViewDataSource> delegate;
@property (nonatomic, strong) NSArray<NSDictionary *> *contentTableViewDataArray;

@end


@implementation LYPopoverView

+ (instancetype)popover {
    if (!popoverView) {
        popoverView              = [[LYPopoverView alloc] init];
        popoverView.arrowSize    = CGSizeZero;
        popoverView.maskType     = DXPopoverMaskTypeBlack;
        popoverView.animationIn  = 0.2f;
        popoverView.animationOut = 0.2f;
        popoverView.applyShadow  = NO;
    }
    return popoverView;
}

+ (instancetype)showPopoverViewAtPoint:(CGPoint)point
                                inView:(UIView *)inView
                                  type:(LYPopoverViewItemType)type
                              delegate:(id<LYPopoverViewDataSource>)delegate {

    [LYPopoverView popover].type     = type;
    [LYPopoverView popover].delegate = delegate;

    if ([delegate respondsToSelector:@selector(popoverViewDataSource:)]) {
        popoverView.contentTableViewDataArray = [delegate popoverViewDataSource:popoverView];
    }

    [popoverView showAtPoint:point popoverPostion:DXPopoverPositionDown withContentView:popoverView.contentTableView inView:inView];
    return popoverView;
}

+ (void)dismiss {
    if (!popoverView) {
        return;
    }
    [popoverView dismiss];
}

#pragma mark TableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return popoverView.contentTableViewDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LYPopoverViewItemHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LYPopoverViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LYPopoverViewTableViewCellIdentity forIndexPath:indexPath];
    [cell configData:popoverView.type title:popoverView.contentTableViewDataArray[indexPath.row][@"title"] iconName:popoverView.contentTableViewDataArray[indexPath.row][@"icon"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([popoverView.delegate respondsToSelector:@selector(popoverViewDidSelected:)]) {
        [popoverView.delegate popoverViewDidSelected:indexPath.row];
    }
    [popoverView dismiss];
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

#pragma mark - Pravite

- (CGSize)p_caculateTableViewSize {
    __block CGFloat width;
    __block CGFloat height;

    // 只有 icon 就直接返回
    if (popoverView.type == LYPopoverViewItemTypeOnlyIcon) {
        return CGSizeMake(LYPopoverViewItemIconWH + LYPopoverViewItemEdgeH * 2.f, LYPopoverViewItemIconWH * popoverView.contentTableViewDataArray.count);
    }

    // 计算文字的宽度和高度
    [popoverView.contentTableViewDataArray enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSDictionary *dic = @{
            NSFontAttributeName: [UIFont systemFontOfSize:LYPopoverViewItemWordFontSize]
        };
        CGSize size = [obj[@"title"] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
        width       = MAX(width, size.width);
        height += LYPopoverViewItemHeight;
    }];

    // 加上特殊的地方的大小
    if (popoverView.type == LYPopoverViewItemTypeIconTitle || popoverView.type == LYPopoverViewItemTypeTitleIcon) {
        width += (LYPopoverViewItemEdgeH + LYPopoverViewItemIconWH);
    }

    width += LYPopoverViewItemEdgeH * 2;

    // 宽度太小不好看。。。。
    if (width < 100.f) {
        width = 100.f;
    }

    return CGSizeMake(width, height);
}

#pragma mark - Getter

- (UITableView *)contentTableView {
    if (!_contentTableView) {
        _contentTableView = ({
            CGSize size               = [popoverView p_caculateTableViewSize];
            UITableView *tableView    = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStylePlain];
            tableView.delegate        = self;
            tableView.dataSource      = self;
            tableView.rowHeight       = LYPopoverViewItemHeight;
            tableView.scrollEnabled   = NO;
            tableView.backgroundColor = [UIColor redColor];
            [tableView registerClass:[LYPopoverViewTableViewCell class] forCellReuseIdentifier:LYPopoverViewTableViewCellIdentity];
            tableView;
        });
    }
    return _contentTableView;
}

@end

@interface LYPopoverViewTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, assign) LYPopoverViewItemType type;

@end

@implementation LYPopoverViewTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)configData:(LYPopoverViewItemType)type title:(NSString *)title iconName:(NSString *__nullable)iconName {

    self.type = type;

    switch (type) {
        case LYPopoverViewItemTypeDefault: {
            self.titleLabel.text = title;
            [self.titleLabel sizeToFit];
            break;
        }
        case LYPopoverViewItemTypeIconTitle:
        case LYPopoverViewItemTypeTitleIcon: {
            self.titleLabel.text = title;
            [self.titleLabel sizeToFit];
            self.iconImageView.image = [UIImage imageNamed:iconName];
            break;
        }
        case LYPopoverViewItemTypeOnlyIcon: {
            self.iconImageView.image = [UIImage imageNamed:iconName];
            break;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    switch (self.type) {
        case LYPopoverViewItemTypeDefault: {
            self.titleLabel.frame = CGRectMake((CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(self.titleLabel.frame)) / 2.f, (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(self.titleLabel.frame)) / 2.f, CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
            break;
        }
        case LYPopoverViewItemTypeIconTitle: {
            self.iconImageView.frame = CGRectMake(LYPopoverViewItemEdgeH, (CGRectGetHeight(self.contentView.frame) - LYPopoverViewItemIconWH) / 2.f, LYPopoverViewItemIconWH, LYPopoverViewItemIconWH);
            self.titleLabel.frame    = CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + LYPopoverViewItemEdgeH, (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(self.titleLabel.frame)) / 2.f, CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
            break;
        }
        case LYPopoverViewItemTypeTitleIcon: {
            self.titleLabel.frame    = CGRectMake(LYPopoverViewItemEdgeH, (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(self.titleLabel.frame)) / 2.f, CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
            self.iconImageView.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + LYPopoverViewItemEdgeH, (CGRectGetHeight(self.contentView.frame) - LYPopoverViewItemIconWH) / 2.f, LYPopoverViewItemIconWH, LYPopoverViewItemIconWH);
            break;
        }
        case LYPopoverViewItemTypeOnlyIcon: {
            self.iconImageView.frame = CGRectMake((CGRectGetWidth(self.contentView.frame) - LYPopoverViewItemIconWH) / 2.f, (CGRectGetHeight(self.contentView.frame) - LYPopoverViewItemIconWH) / 2.f, LYPopoverViewItemIconWH, LYPopoverViewItemIconWH);
            break;
        }
    }
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.font     = [UIFont systemFontOfSize:LYPopoverViewItemWordFontSize];
            [self.contentView addSubview:label];
            label;
        });
    }
    return _titleLabel;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            [self.contentView addSubview:imageView];
            imageView;
        });
    }
    return _iconImageView;
}

@end
