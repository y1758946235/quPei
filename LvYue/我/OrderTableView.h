//
//  OrderTableView.h
//  豆客项目
//
//  Created by Xia Wei on 15/9/29.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTableView : UIView

@property (nonatomic,strong) NSString *guideName;//导游姓名
@property (nonatomic,strong) NSString *guideNum;//联系电话
@property (nonatomic,strong) NSString *guidePrice;
@property (nonatomic,strong) NSString *guideId;
@property(nonatomic,strong)NSString *startTime;
@property(nonatomic,strong)NSString *endTime;
@property(nonatomic,strong)UIButton *buyBtn;
@property (nonatomic,strong) NSString *content;//服务内容
@property(nonatomic,strong) NSString *price;//应付金额
@property(nonatomic,strong) UIButton *cancelBtn;
@property(nonatomic,assign) BOOL timeIsSuitable;
@property(nonatomic,strong)UITextField *textField;//支付金额

- (id) initWithFrame:(CGRect)frame;

@end
