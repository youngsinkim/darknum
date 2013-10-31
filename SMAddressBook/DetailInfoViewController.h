//
//  DetailInfoViewController.h
//  SMAddressBook
//
//  Created by sochae on 13. 9. 14..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailInfoViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *contacts;         //< 주소록 목록

- (id)initWithType:(MemberType)type;

@end
