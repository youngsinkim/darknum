//
//  ToolViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToolViewCell.h"

typedef enum {
    ToolViewTypeSms,
    ToolViewTypeEmail,
    ToolViewTypeUnknown
} ToolViewType;

@interface ToolViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, ToolViewCellDelegate>

- (id)initWithInfo:(NSMutableArray *)items viewType:(ToolViewType)type;

@end
