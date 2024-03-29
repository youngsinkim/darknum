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

#define kProfileInfo    @"ProfileInfo"  //< 내 프로필 정보
#define kLastUpdate     @"LastUpdate"   //< 마지막 서버에서 업데이트 받은 시간

#define kAutoLogin      @"AutoLogin"    //< 자동 로그인 여부 (자동 여부 설정에 따라 로그인 창 화면 노출 결정)
#define kAcceptTerms    @"AcceptTerms"  //< 약관 동의 여부 (약관 동의 여부에 따라 약관 화면 노출 결정)
#define kSetProfile     @"SetProfile"   //< 내 프로필 설정 여부 (내 정보 설정에 따라 최초 로그인 시 프로필 화면 노출 결정)

// login info.
#define kScode          @"scode"        //< 암호화된 휴대폰번호
#define kCertNo         @"certno"
#define kMemType        @"memtype"
#define kUpdateCount    @"updatecount"
#define kMyClass        @"myclass"
#define kMyCourse       @"mycourse"

#define kUserId         @"userId"
#define kUserPwd        @"userPwd"
#define kUserKey        @"userkey"

#define kSavedId        @"savedUserId"

#define kDetailGuide    @"detailGuide"  // 디테일 화면 가이드 표시 (최초에만 표시하고 이후는 표시하지 않기 위해 저장)

@interface UserContext : NSObject

@property (strong, nonatomic) NSMutableDictionary *profileInfo; //< 내 정보(프로필) 데이터
@property (strong, nonatomic) NSString *lastUpdateDate;         //< 업데이트 시간 (마지막 서버 연동 시간 저장, 이 시간 값을 기준으로 서버의 새로운 데이터를 받아온다.)
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userPwd;
@property (strong, nonatomic) NSString *userKey;                //< 자싞의 KEY 정보 (학생의 경우 studcode, 교수/교직원의 경우 memberidx값을 Key로 핚다)

@property (strong, nonatomic) NSString *certNo;                 //< 회원인증코드
@property (strong, nonatomic) NSString *memberType;             //< 내 멤버 종류 (1:student, 2:faculty, 3:staff)
@property (strong, nonatomic) NSString *updateCount;            //< 즐겨찾기 목록 업데이트된 개수
                                                                /* (이 값이 0보다 크면 업데이트 항목이 있는 것으로 판단하여,
                                                                    과정별 기수 목록 / 교수 전공 목록 / 즐겨찾기 업데이트 목록을 서버에서 받아온다.) */
@property (strong, nonatomic) NSString *myClass;                //< 자싞의 과정기수코드 (학생의 경우만 값이 있으면, 교수/교직원의 경우는 값이 NULL이다.)
@property (strong, nonatomic) NSString *myCourse;               //< 자싞의 과정코드 (EMBA/GMBA/SMBA 중 하나)
@property (strong, nonatomic) NSString *language;               // 설정 언어 정보

@property (strong, nonatomic) NSString *appUpdateUrl;           //< 업데이트 url 정보 (AppStore Url)


@property (assign, nonatomic) BOOL isAutoLogin;         //< 자동 로그인 설정 값 (이 값에 따라 로그인 창을 띄울지 말지를 결정한다.)
@property (assign, nonatomic) BOOL isAcceptTerms;       //< 약관 동의 설정 값 (약관 동의 안한 경우, 최초나 로그인 시에 약관 동의 화면을 노출하기 위해 사용)
@property (assign, nonatomic) BOOL isExistProfile;      //< 내 정보 설정 갑시 (내 정보를 설정하지 않은 경우, 최초나 로그인 시에 프로필 화면을 노출하기 위해 사용)
@property (assign, nonatomic) BOOL isSavedID;           //< 아이디 저장 여부

@property (assign) BOOL isLogined;                      //< 현재 로그인 상태 저장


//@property (strong, nonatomic) NSString *myPhoneNumber;  //< 단말 전화번호 (파일에는 저장하지 않음)

+ (UserContext *)shared;

- (void)loadAppSetting;

@end
