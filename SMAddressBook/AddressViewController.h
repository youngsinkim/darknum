//
//  AddressViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "BaseViewController.h"

@interface AddressViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithType:(MemberType)memType info:(NSDictionary *)info;

@end
