//
//  FavoriteCell.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 29..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFavoriteCellH  50
@interface FavoriteCell : UITableViewCell

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *iconName;
@property (assign, nonatomic) NSInteger count;

- (void)setMemType:(NSInteger)type WidhCount:(NSInteger)count;
@end
