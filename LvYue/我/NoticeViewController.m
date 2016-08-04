//
//  NoticeViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/3/23.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "NoticeViewController.h"

@interface NoticeViewController () {
    UITextField *startField;
    UITextField *endField;
    UISwitch *mySwitch;
    UILabel *explainLabel;
}

@end

@implementation NoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title                = @"通知与消息";
    self.view.backgroundColor = RGBACOLOR(244, 245, 246, 1);

    UIView *setView         = [[UIView alloc] initWithFrame:CGRectMake(0, 15, SCREEN_WIDTH, 44)];
    setView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:setView];

    UILabel *noteLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 24)];
    noteLabel1.text     = @"设置时段";
    [setView addSubview:noteLabel1];

    startField              = [[UITextField alloc] initWithFrame:CGRectMake(115, 10, 60, 24)];
    startField.borderStyle  = UITextBorderStyleRoundedRect;
    startField.keyboardType = UIKeyboardTypeNumberPad;
    if ([LYUserService sharedInstance].userDetail.startTime.length > 0) {
        startField.text = [LYUserService sharedInstance].userDetail.startTime;
    } else {
        startField.placeholder = @"23";
    }
    [setView addSubview:startField];

    UIView *line         = [[UIView alloc] initWithFrame:CGRectMake(180, 21, 15, 1)];
    line.backgroundColor = [UIColor blackColor];
    [setView addSubview:line];

    endField              = [[UITextField alloc] initWithFrame:CGRectMake(200, 10, 60, 24)];
    endField.borderStyle  = UITextBorderStyleRoundedRect;
    endField.keyboardType = UIKeyboardTypeNumberPad;
    if ([LYUserService sharedInstance].userDetail.endTime.length > 0) {
        endField.text = [LYUserService sharedInstance].userDetail.endTime;
    } else {
        endField.placeholder = @"7";
    }
    [setView addSubview:endField];

    UIView *noteView         = [[UIView alloc] initWithFrame:CGRectMake(0, 15 + 59, SCREEN_WIDTH, 44)];
    noteView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:noteView];

    UILabel *noteLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 24)];
    noteLabel2.text     = @"勿扰模式";
    [noteView addSubview:noteLabel2];

    mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 6, 60, 24)];
    if ([LYUserService sharedInstance].userDetail.endTime.length > 0) {
        mySwitch.on = YES;
    } else {
        mySwitch.on = NO;
    }
    [mySwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [noteView addSubview:mySwitch];

    explainLabel      = [[UILabel alloc] initWithFrame:CGRectMake(15, 128 + 59, SCREEN_WIDTH - 30, 20)];
    explainLabel.text = @"勿扰模式打开后，您设置的时间段内将关闭所有通知。";
    explainLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:explainLabel];
}

- (void)switchAction:(UISwitch *)bSwitch {
    if (startField.text.length == 0 || endField.text.length == 0) {
        [MBProgressHUD showError:@"请输入自定义时间"];
        return;
    } else if ([startField.text integerValue] > 24 || [endField.text integerValue] > 24) {
        [MBProgressHUD showError:@"时间格式错误"];
        return;
    }
    BOOL isButtonOn = [mySwitch isOn];
    if (isButtonOn) {
        [LYUserService sharedInstance].userDetail.startTime = startField.text;
        [LYUserService sharedInstance].userDetail.endTime   = endField.text;
        mySwitch.on                                         = YES;
        explainLabel.text                                   = [NSString stringWithFormat:@"打开后%@：00到%@：00关闭所有通知", [LYUserService sharedInstance].userDetail.startTime, [LYUserService sharedInstance].userDetail.endTime];
        /*---------------- 配置apns ---------------*/
        EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
        //    设置推送免打扰时段
        options.noDisturbStatus    = ePushNotificationNoDisturbStatusCustom;
        options.noDisturbingStartH = [[LYUserService sharedInstance].userDetail.startTime integerValue];
        options.noDisturbingEndH   = [[LYUserService sharedInstance].userDetail.endTime integerValue];
        //异步上传保存推送配置
        [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:nil onQueue:nil];
    } else {
        [LYUserService sharedInstance].userDetail.startTime = @"";
        [LYUserService sharedInstance].userDetail.endTime   = @"";
        mySwitch.on                                         = NO;
        explainLabel.text                                   = @"打开后23：00到7：00关闭所有通知";
        /*---------------- 配置apns ---------------*/
        EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
        //    设置推送免打扰时段
        options.noDisturbStatus    = ePushNotificationNoDisturbStatusCustom;
        options.noDisturbingStartH = 24;
        options.noDisturbingEndH   = 24;
        //异步上传保存推送配置
        [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:nil onQueue:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
