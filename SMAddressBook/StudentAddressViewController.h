//
//  StudentAddressViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "BaseViewController.h"
#import "StudentToolView.h"

@interface StudentAddressViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, StudentToolViewDelegate>

- (id)initWithInfo:(NSDictionary *)info;

@end
