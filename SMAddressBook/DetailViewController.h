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
#import <EasyTableView.h>

@interface DetailViewController : UIViewController <EasyTableViewDelegate, MMHorizontalListViewDataSource, MMHorizontalListViewDelegate, DetailToolViewDelegate, ABNewPersonViewControllerDelegate, ABPersonViewControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSMutableArray *contacts;         //< 주소록 목록
@property (assign, nonatomic) NSInteger currentIdx;

- (id)initWithType:(MemberType)type;

@end
