//
//  DetailViewCell.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 9..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

//#import "MMHorizontalListViewCell.h"

@interface DetailViewCell : UIView

@property (assign, nonatomic) MemberType memType;
@property (strong, nonatomic) NSDictionary *cellInfo;
@property (strong, nonatomic) UIImageView *profileImage;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *nameValueLabel;
@property (strong, nonatomic) UILabel *classLabel;
@property (strong, nonatomic) UILabel *classValueLabel;
@property (strong, nonatomic) UILabel *majorLabel;
@property (strong, nonatomic) UILabel *majorValueLabel;
@property (strong, nonatomic) UILabel *telLabel;
@property (strong, nonatomic) UILabel *telValueLabel;
@property (strong, nonatomic) UILabel *mobileLabel;
@property (strong, nonatomic) UILabel *mobileValueLabel;
@property (strong, nonatomic) UILabel *emailLabel;
@property (strong, nonatomic) UILabel *emailValueLabel;
@property (strong, nonatomic) UILabel *officeLabel;
@property (strong, nonatomic) UILabel *officeValueLabel;
@property (strong, nonatomic) UILabel *companyLabel;
@property (strong, nonatomic) UILabel *companyValueLabel;
@end
