//
//  MessageCell.m
//  LvYue
//
//  Created by apple on 15/10/6.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "MessageCell.h"
#import "UIImageView+WebCache.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"

@implementation MessageCell

- (void)awakeFromNib {
    
    self.iconView.layer.cornerRadius = 3.0;
    self.iconView.clipsToBounds = YES;
    self.unReadCountBtn.layer.cornerRadius = 10.0;
    self.unReadCountBtn.clipsToBounds = YES;
}

+ (MessageCell *)messageCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseName = @"messageCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseName];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:nil options:nil] lastObject];
    } else {
        cell.iconView.image = nil;
        cell.nameLabel.text = @"";
        cell.lastMessageLabel.text = @"";
    }
    return cell;
}


- (void)fillDataWithConversation:(EMConversation *)conversation {
    
    //如果是单聊类型
    if (conversation.conversationType == eConversationTypeChat) {
        [self getUserDetailWithUserID:conversation.chatter];
    }
    
    //如果是群聊类型
    else {
        [self getGroupDetailWithGroupID:conversation.chatter];
    }
}


- (void)getUserDetailWithUserID:(NSString *)userID {
    
    [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
        __block NSDictionary *resultDict;
        //打开数据库
        if ([kAppDelegate.dataBase open]) {
            //条件查询
            NSString *searchSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE userID = '%@'",@"User",userID];
            FMResultSet *result = [kAppDelegate.dataBase executeQuery:searchSql];
            BOOL isExist = NO;
            while ([result next]) {
                isExist = YES;
                NSString *userID = [result stringForColumn:@"userID"];
                NSString *name = [result stringForColumn:@"name"];
                NSString *remark = [result stringForColumn:@"remark"];
                NSString *icon = [result stringForColumn:@"icon"];
                resultDict = @{@"userID":userID,@"name":name,@"remark":remark,@"icon":icon};
            }
            if (isExist) {
                [kAppDelegate.dataBase close];
                if (resultDict[@"remark"] && !([[NSString stringWithFormat:@"%@",resultDict[@"remark"]] isEqualToString:@""]) && !([[NSString stringWithFormat:@"%@",resultDict[@"remark"]] isEqualToString:@"(null)"])) {
                    self.nameLabel.text = resultDict[@"remark"];
                } else {
                    self.nameLabel.text = resultDict[@"name"];
                }
                [self.iconView sd_setImageWithURL:[NSURL URLWithString:resultDict[@"icon"]]];
            } else {
                [kAppDelegate.dataBase close];
                //不存在,请求
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/getInfo",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"friend_user_id":userID} success:^(id successResponse) {
                    if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                        NSDictionary *user = successResponse[@"data"][@"user"];
                        NSString *userID = [NSString stringWithFormat:@"%@",user[@"id"]];
                        NSString *name = [NSString stringWithFormat:@"%@",user[@"name"]];
                        NSString *remark = [NSString stringWithFormat:@"%@",user[@"remark"]];
                        NSString *icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,user[@"icon"]];
                        resultDict = @{@"userID":userID,@"name":name,@"remark":remark,@"icon":icon};
                        if (resultDict[@"remark"] && !([[NSString stringWithFormat:@"%@",resultDict[@"remark"]] isEqualToString:@""]) && !([[NSString stringWithFormat:@"%@",resultDict[@"remark"]] isEqualToString:@"(null)"])) {
                            self.nameLabel.text = remark;
                        } else {
                            self.nameLabel.text = name;
                        }
                        [self.iconView sd_setImageWithURL:[NSURL URLWithString:icon]];
                        //存入数据库
                        [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                            if ([kAppDelegate.dataBase open]) {
                                NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')",@"User",@"userID",@"name",@"remark",@"icon",userID,name,remark,icon];
                                BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                                if (isSuccess) {
                                    MLOG(@"插入数据成功!");
                                } else {
                                    MLOG(@"插入数据失败!");
                                }
                                [kAppDelegate.dataBase close];
                            }
                        }];
                    }
                } andFailure:^(id failureResponse) {
                }];
            }
        } else {
            MLOG(@"打开数据库失败!");
        }
    }];
}


- (void)getGroupDetailWithGroupID:(NSString *)easemob_id {
    
    [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
        __block NSDictionary *resultDict;
        //打开数据库
        if ([kAppDelegate.dataBase open]) {
            //条件查询
            NSString *searchSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE easemob_id = '%@'",@"Group",easemob_id];
            FMResultSet *result = [kAppDelegate.dataBase executeQuery:searchSql];
            BOOL isExist = NO;
            while ([result next]) {
                isExist = YES;
                NSString *groupID = [result stringForColumn:@"groupID"];
                NSString *name = [result stringForColumn:@"name"];
                NSString *desc = [result stringForColumn:@"desc"];
                NSString *icon = [result stringForColumn:@"icon"];
                resultDict = @{@"groupID":groupID,@"easemob_id":easemob_id,@"name":name,@"desc":desc,@"icon":icon};
            }
            if (isExist) {
                [kAppDelegate.dataBase close];
                self.nameLabel.text = resultDict[@"name"];
                [self.iconView sd_setImageWithURL:[NSURL URLWithString:resultDict[@"icon"]]];
            } else {
                [kAppDelegate.dataBase close];
                //不存在,请求
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/getInfoByEasemobId",REQUESTHEADER] andParameter:@{@"easemob_id":easemob_id} success:^(id successResponse) {
                    if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                        NSDictionary *group = successResponse[@"data"][@"group"];
                        NSString *groupID = [NSString stringWithFormat:@"%@",group[@"id"]];
                        NSString *name = [NSString stringWithFormat:@"%@",group[@"name"]];
                        NSString *desc = [NSString stringWithFormat:@"%@",group[@"desc"]];
                        NSString *icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,group[@"icon"]];
                        resultDict = @{@"groupID":groupID,@"easemob_id":easemob_id,@"name":name,@"desc":desc,@"icon":icon};
                        self.nameLabel.text = resultDict[@"name"];
                        [self.iconView sd_setImageWithURL:[NSURL URLWithString:icon]];
                        //存入数据库
                        [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                            if ([kAppDelegate.dataBase open]) {
                                NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@','%@') VALUES('%@','%@','%@','%@','%@')",@"Group",@"groupID",@"easemob_id",@"name",@"desc",@"icon",groupID,easemob_id,name,desc,icon];
                                BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                                if (isSuccess) {
                                    MLOG(@"插入数据成功!");
                                } else {
                                    MLOG(@"插入数据失败!");
                                }
                                [kAppDelegate.dataBase close];
                            }
                        }];
                    }
                } andFailure:^(id failureResponse) {
                }];
            }
        } else {
            MLOG(@"打开数据库失败!");
        }
    }];
}


@end
