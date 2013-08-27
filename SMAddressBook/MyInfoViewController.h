//
//  MyInfoViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MemberTypeStudent,
    MemberTypeFaculty,
    MemberTypeStaff,
    MemberTypeUnknown
} MemberType;

@interface MyInfoViewController : BaseViewController

@property (nonatomic, assign) MemberType mType; // 멤버 타입 ( 타입별로 화면 구성 변경 )

@end
