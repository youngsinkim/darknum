//
//  DetailViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 26..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMHorizontalListView.h"

@interface DetailViewController : UIViewController <MMHorizontalListViewDataSource, MMHorizontalListViewDelegate>

@property (strong, nonatomic) NSMutableArray *contacts;         //< 주소록 목록

@end
