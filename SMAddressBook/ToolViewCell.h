//
//  ToolViewCell.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 22..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ToolViewCell;

@protocol ToolViewCellDelegate <NSObject>

// 체크 버튼 선택 이벤트
- (void)onCheckTouched:(id)sender;

@end

@interface ToolViewCell : UITableViewCell

@property id<ToolViewCellDelegate> delegate;
@property (strong, nonatomic) NSDictionary *info;
@property (strong, nonatomic) UIButton *checkBtn;

@end
