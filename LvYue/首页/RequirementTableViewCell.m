//
//  RequirementTableViewCell.m
//  LvYue
//
//  Created by 郑洲 on 16/4/6.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "RequirementTableViewCell.h"
#import "RequirementCollectionViewCell.h"

@interface RequirementTableViewCell()<UICollectionViewDelegate, UICollectionViewDataSource> {
    UICollectionView *_collectionView;
}

@end

@implementation RequirementTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)createWithData:(NSArray *)dataArray {
    _dataArray = dataArray;
    [_collectionView reloadData];
    _collectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, (_dataArray.count / 4 + 1) * 35);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        flowLayout.minimumInteritemSpacing = 5;
        flowLayout.minimumLineSpacing = 5;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_collectionView];
        
        [_collectionView registerClass:[RequirementCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((SCREEN_WIDTH - 40)/4, 25);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RequirementCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.label.text = _dataArray[indexPath.row][@"name"];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"turnToDetail" object:self userInfo:@{@"type":_dataArray[indexPath.row][@"name"],@"number":_dataArray[indexPath.row][@"number"]}];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
