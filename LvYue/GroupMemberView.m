//
//  GroupMemberView.m
//  LvYue
//
//  Created by apple on 15/10/19.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "GroupMemberView.h"
#import "MemberButton.h"
#import "GroupMemberModel.h"

#define GrowMargin 15.0f
#define GColumMargin 15.0f
#define GCountOfARow 4

@interface GroupMemberView ()

@property (nonatomic, strong) NSArray *modelArray;

@property (nonatomic, assign) BOOL isHolder;

@end

@implementation GroupMemberView

- (instancetype)initWithFrame:(CGRect)frame memberModelArray:(NSArray *)modelArray isHolder:(BOOL)isHolder isFull:(BOOL)isFull {
    
    if (self = [super initWithFrame:frame]) {
        CGFloat memberItemWidth = (kMainScreenWidth-5*GColumMargin) / 4;
        CGFloat memberItemHeight = memberItemWidth + 30;
        self.backgroundColor = [UIColor whiteColor];
        //初始化行数
        int rowCount = 0;
        
        if (isHolder) { //如果是群主视角
            if (isFull) { //如果已经满员
                rowCount = (int)((modelArray.count-1) / GCountOfARow) + 1;
                for (int i = 0; i < modelArray.count; i ++) {
                    int currentRow = i / GCountOfARow;
                    int currentColum = i % GCountOfARow;
                    if (i < modelArray.count) {
                        MemberButton *item = [[MemberButton alloc] initWithFrame:CGRectMake(GColumMargin * (currentColum+1) + memberItemWidth * currentColum, GrowMargin * (currentRow+1) + memberItemHeight * currentRow, memberItemWidth, memberItemHeight) groupMemberModel:modelArray[i] isGroupHolder:(i==0?YES:NO)];
                        [item addTarget:self action:@selector(clickMemberIcon:) forControlEvents:UIControlEventTouchUpInside];
                        [self addSubview:item];
                    }
                }
            } else { //如果未满员
                rowCount = (int)((modelArray.count) / GCountOfARow) + 1;
                for (int i = 0; i < modelArray.count+1; i ++) {
                    int currentRow = i / GCountOfARow;
                    int currentColum = i % GCountOfARow;
                    if (i < modelArray.count) {
                        MemberButton *item = [[MemberButton alloc] initWithFrame:CGRectMake(GColumMargin * (currentColum+1) + memberItemWidth * currentColum, GrowMargin * (currentRow+1) + memberItemHeight * currentRow, memberItemWidth, memberItemHeight) groupMemberModel:modelArray[i] isGroupHolder:(i==0?YES:NO)];
                        [item addTarget:self action:@selector(clickMemberIcon:) forControlEvents:UIControlEventTouchUpInside];
                        [self addSubview:item];
                    }
                    if (i == modelArray.count) {
                        int currentRow = (int)modelArray.count / GCountOfARow;
                        int currentColum = (int)modelArray.count % GCountOfARow;
                        UIButton *addItem = [UIButton buttonWithType:UIButtonTypeCustom];
                        addItem.frame = CGRectMake(GColumMargin * (currentColum+1) + memberItemWidth * currentColum, GrowMargin * (currentRow+1) + memberItemHeight * currentRow, memberItemWidth, memberItemWidth);
                        addItem.layer.cornerRadius = memberItemWidth / 2;
                        addItem.clipsToBounds = YES;
                        addItem.layer.borderColor = [UIColor lightGrayColor].CGColor;
                        addItem.layer.borderWidth = 1.0;
                        [addItem setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
                        [addItem addTarget:self action:@selector(clickAddMembersBtn:) forControlEvents:UIControlEventTouchUpInside];
                        [self addSubview:addItem];
                    }
                }
            }
        } else { //如果是普通组员视角
            rowCount = (int)((modelArray.count-1) / GCountOfARow) + 1;
            for (int i = 0; i < modelArray.count; i ++) {
                int currentRow = i / GCountOfARow;
                int currentColum = i % GCountOfARow;
                if (i < modelArray.count) {
                    MemberButton *item = [[MemberButton alloc] initWithFrame:CGRectMake(GColumMargin * (currentColum+1) + memberItemWidth * currentColum, GrowMargin * (currentRow+1) + memberItemHeight * currentRow, memberItemWidth, memberItemHeight) groupMemberModel:modelArray[i] isGroupHolder:(i==0?YES:NO)];
                    [item addTarget:self action:@selector(clickMemberIcon:) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:item];
                }
            }
        }
        //设置长和宽
        self.frame = CGRectMake(0, 0, kMainScreenWidth, (rowCount+1) * GrowMargin + rowCount * memberItemHeight);
    }
    return self;
}

#pragma mark - 监听点击头像
- (void)clickMemberIcon:(UIButton *)sender {
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clickToGroupMemberDetail" object:sender];
}

#pragma mark - 监听点击添加成员按钮
- (void)clickAddMembersBtn:(UIButton *)sender {
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addGroupMembers" object:sender];
}

@end
