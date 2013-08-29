//
//  UserContext.h
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>

///////////////////////////////////////////////////////////////
/// plist 정보
#define USERINFO        @"UserInfo"
#define kAutoLogin      @"AutoLogin"    //< 자동 로그인 여부 (자동 여부 설정에 따라 로그인 창 화면 노출 결정)
#define kAcceptTerms    @"AcceptTerms"  //< 약관 동의 여부 (약관 동의 여부에 따라 약관 화면 노출 결정)
#define kSetProfile     @"SetProfile"   //< 내 프로필 설정 여부 (내 정보 설정에 따라 최초 로그인 시 프로필 화면 노출 결정)
#define kLoginInfo      @"LoginInfo"
#define kUserId         @"userId"
#define kUserPwd        @"userPwd"
#define kUserCertNo     @"certno"

@interface UserContext : NSObject

@property (strong, nonatomic) NSMutableDictionary *loginInfo;   // 로그인 데이터
@property (strong, nonatomic) NSString *certNo;
@property (assign) BOOL isLogined;                      // 로그인 여부 메모리 저장
@property (assign, nonatomic) BOOL isAutoLogin;        //< 자동 로그인 설정 여부
@property (assign, nonatomic) BOOL isAcceptTerms;      //< 약관 동의 여부
@property (assign, nonatomic) BOOL isExistProfile;     //< 내 정보 설정 여부

+ (UserContext *)shared;

- (void)loadAppSetting;
@end
