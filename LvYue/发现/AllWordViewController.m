//
//  AllWordViewController.m
//  LvYue
//
//  Created by LHT on 15/11/17.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "AllWordViewController.h"

@interface AllWordViewController ()

@end

@implementation AllWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.title.length < 1) {
        self.title = @"全文";
    }
    
    self.text = [[UITextView alloc] initWithFrame:self.view.frame];
    self.text.text = self.detail;
    self.text.font = [UIFont systemFontOfSize:16.0];
    self.text.editable = NO;
    [self.view addSubview:self.text];
}


@end
