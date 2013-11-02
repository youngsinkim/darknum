//
//  MenuCell.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellH          42.0f

@interface MenuCell : UITableViewCell

@property (strong, nonatomic) UILabel *menuLabel;
//@property (strong, nonatomic) NSDictionary *cellInfo;
@property (strong, nonatomic) NSString *iconName;

@end
