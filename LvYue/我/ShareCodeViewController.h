//
//  ShareCodeViewController.h
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/15.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface ShareCodeViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UILabel *codeLabel;

- (IBAction)shareFriend:(UIButton *)sender;
- (IBAction)shareWeixin:(UIButton *)sender;
- (IBAction)shareQQ:(UIButton *)sender;
- (IBAction)shareWeibo:(UIButton *)sender;

@end
