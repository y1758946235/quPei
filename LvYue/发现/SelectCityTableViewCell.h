//
//  SelectCityTableViewCell.h
//  LvYue
//
//  Created by LHT on 15/11/18.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectCityTableViewCell : UITableViewCell

+ (SelectCityTableViewCell *)myCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

- (void)fillDataWithCity:(NSString *)cityName;

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@end
