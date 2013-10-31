//
//  FavoriteViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 23..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteToolView.h"
#import "LoadingProgressView.h"

@interface FavoriteViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, FavoriteToolViewDelegate, LoadingProgressViewDelegate>

@end
