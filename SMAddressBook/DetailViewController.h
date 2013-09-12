//
//  DetailViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 26..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MMHorizontalListView.h"
#import "DetailToolView.h"

@interface DetailViewController : BaseViewController <MMHorizontalListViewDataSource, MMHorizontalListViewDelegate, DetailToolViewDelegate, ABNewPersonViewControllerDelegate, ABPersonViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *contacts;         //< 주소록 목록

- (id)initWithType:(MemberType)type;

@end
