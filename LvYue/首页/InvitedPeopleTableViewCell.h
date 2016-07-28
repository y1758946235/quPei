//
//  InvitedPeopleTableViewCell.h
//  LvYue
//
//  Created by 郑洲 on 16/4/11.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeopleModel.h"

@interface InvitedPeopleTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL isMyself;
@property (nonatomic, strong) NSMutableArray *btnArr;

@property (nonatomic, strong) UIButton *peopleBtn;

- (void)createWithModel:(PeopleModel *)model;

@end
