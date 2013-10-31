//
//  TermsViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 24..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermsViewController : BaseViewController <UIWebViewDelegate, NSURLConnectionDelegate>

@property (assign, nonatomic) BOOL isByMenu;   // 왼쪽 메뉴 선택으로 뷰를 띄우는지 확인
//@property (assign) BOOL isHideAcceptBtn;

// 메뉴에서 약관 동의 화면을 띄울 경우, [동의함] 버튼 삭제
- (void)hideAcceptBtn;

@end
