//
//  SearchResultViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 8..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudentToolView.h"

@interface SearchResultViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, StudentToolViewDelegate>

//@property (strong, nonatomic) NSDictionary *info;

- (id)initWithInfo:(NSDictionary *)searchInfo;

@end
