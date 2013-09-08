//
//  FavoriteSettingViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteSettCell.h"

/// 즐겨찾기 뷰 컨트롤러
@interface FavoriteSettingViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, FavoriteSettCellDelegate>

@end
