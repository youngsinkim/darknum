//
//  AddressCell.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 2..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAddressCellH   60.0f

@interface AddressCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *cellInfo;
@property (assign) MemberType memType;

@end
