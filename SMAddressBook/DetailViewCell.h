//
//  DetailViewCell.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 9..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

//#import "MMHorizontalListViewCell.h"

/// 주소록 상세정보 화면 (셀)
@interface DetailViewCell : UIView

@property (assign, nonatomic) MemberType memType;
@property (strong, nonatomic) NSDictionary *cellInfo;
@property (strong, nonatomic) UIImageView *profileImage;

@end
