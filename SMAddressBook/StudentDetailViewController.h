//
//  StudentDetailViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "BaseViewController.h"
#import "MMHorizontalListView.h"

/// 학생 상세보기 뷰 컨트롤러
@interface StudentDetailViewController : BaseViewController <MMHorizontalListViewDataSource, MMHorizontalListViewDelegate>

- (id)initWithInfo:(NSArray *)items;

@end
