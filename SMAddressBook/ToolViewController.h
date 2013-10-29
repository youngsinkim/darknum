//
//  ToolViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToolViewCell.h"
#import <MessageUI/MessageUI.h>

typedef enum {
    ToolViewTypeSms,
    ToolViewTypeEmail,
    ToolViewTypeUnknown
} ToolViewType;

@interface ToolViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, ToolViewCellDelegate, MFMessageComposeViewControllerDelegate>

@property (assign) ToolViewCellType cellType;

- (id)initWithInfo:(NSMutableArray *)items viewType:(ToolViewType)type memberType:(MemberType)memType;

@end
