//
//  BaseViewController.h
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MFSideMenuContainerViewController.h>
#import "TitleView.h"

@interface BaseViewController : UIViewController
{
//    TitleView *_titleView;
}

@property (strong, nonatomic) UIButton *prevButton;
@property (strong, nonatomic) UIButton *searchButton;

/// 컨테이너 뷰 컨트롤러
- (MFSideMenuContainerViewController *)menuContainerViewController;

/// 네비게이션 왼쪽 메뉴 버튼
//- (void)leftMenuButtonClicked:(id)sender;

@end
