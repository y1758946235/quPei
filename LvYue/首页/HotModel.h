//
//  HotModel.h
//  LvYue
//
//  Created by 郑洲 on 16/3/18.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotModel : NSObject
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *imgName;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *intro;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic,assign) CGFloat imageHeight;
@property (nonatomic,assign) CGFloat textHeight;
@property (nonatomic,assign) CGFloat cellHeight;

- (id)initWithDict:(NSDictionary *)dict;
@end
