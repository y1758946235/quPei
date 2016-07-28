//
//  PhotoDetailViewController.h
//  欧陆风庭
//
//  Created by 蒋俊 on 15/7/24.
//  Copyright (c) 2015年 eage. All rights reserved.
//

#import <UIKit/UIKit.h>
//点击图片 图片详情界面

typedef  void (^ReturnPhotoBlock)(BOOL isDelete);
@interface PhotoDetailViewController : UIViewController
@property (nonatomic,strong) UIImage *image;

@property (nonatomic,copy) ReturnPhotoBlock returnPhotoBlock;

- (void)returnPhoto:(ReturnPhotoBlock)block;
@end
