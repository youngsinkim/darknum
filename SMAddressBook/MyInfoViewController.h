//
//  MyInfoViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef enum {
//    MemberTypeStudent = 1,
//    MemberTypeFaculty = 2,
//    MemberTypeStaff = 3,
//    MemberTypeUnknown
//} MemberType;

@interface MyInfoViewController : BaseViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate>

@property (assign, nonatomic) MemberType memType; // 멤버 타입 ( 타입별로 화면 구성 변경 )

//- (id)initWithMemberType:(MemberType)type;

@end
