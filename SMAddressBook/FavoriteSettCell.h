//
//  FavoriteSettCell.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 8..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FavoriteSettCellH   42.0f

@class FavoriteSettCell;

@protocol FavoriteSettCellDelegate <NSObject>

// 체크 버튼 선택 이벤트
- (void)onFavoriteCheckTouched:(id)sender;

@end


@interface FavoriteSettCell : UITableViewCell

@property id<FavoriteSettCellDelegate> delegate;
@property (strong, nonatomic) UILabel *classLabel;
@property (strong, nonatomic) NSDictionary *cellInfo;
@property (assign, nonatomic) BOOL hidden;
@property (assign, nonatomic) BOOL favEnabled;
@property (assign, nonatomic) bool favyn;

@end
