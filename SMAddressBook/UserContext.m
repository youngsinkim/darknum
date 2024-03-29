//
//  UserContext.m
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "UserContext.h"

@implementation UserContext


static UserContext *_sharedUserContext = nil;

+ (UserContext *)shared
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedUserContext = [[UserContext alloc] initWithDefault];
    });
    
    return _sharedUserContext;
}

+ (id)alloc
{
	@synchronized([UserContext class])
    {
        NSAssert(_sharedUserContext == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedUserContext = [super alloc];
        
        //< 프로필 정보
        _sharedUserContext.profileInfo = [[NSMutableDictionary alloc] init];

        //< 최초 업데이트 시간 (0000-00-00 00:00:00)
        _sharedUserContext.lastUpdateDate = @"0000-00-00 00:00:00";// [[NSDateFormatter alloc] dateFromString:@"0000-00-00 00:00:00"];
        _sharedUserContext.userId = @"";        // 사용자 ID
        _sharedUserContext.userPwd = @"";       // 사용자 비밀번호
        _sharedUserContext.userKey = @"";       // 사용자 고유번혼 (studcode or memberidx)

        _sharedUserContext.certNo = @"";        // 로그인 토큰
        _sharedUserContext.memberType = @"";    // 내 멤버 종류
        _sharedUserContext.updateCount = @"";   // 서버에서 내려주는 업데이트 카운트 
        _sharedUserContext.myClass = @"";       // 나의 기수 과정 정보
        _sharedUserContext.myCourse = @"";      // 자신 과정 코드
        
        _sharedUserContext.isLogined = NO;      //< 최초 로그인 여부 (NO)
        _sharedUserContext.isAutoLogin = NO;    //< 최초 자동 로그인 값 (NO)
        _sharedUserContext.isAcceptTerms = NO;  //< 약관 동의 여부
        _sharedUserContext.isExistProfile = NO; //< 프로필 설정 여부
        _sharedUserContext.isSavedID = NO;

        _sharedUserContext.language = [TSLanguageManager selectedLanguage];
        _sharedUserContext.appUpdateUrl = @"";

        return _sharedUserContext;
	}
    
	// to avoid compiler warning
	return nil;
}

- (id)initWithDefault
{
	self = [super init];
	if (self != nil)
    {
        // 이전에 저장된 값 불러오기
        [self loadAppSetting];
    }
    
	return self;
}

#pragma mark -

/// App 세팅 읽어오기
- (void)loadAppSetting
{
    // TODO: 로그인 데이터 읽어오기
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kProfileInfo])
    {
//        [_profileInfo setDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"profile"]];
        [_profileInfo setDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kProfileInfo]];
//        NSLog(@"previous ProfileInfo : %@", [_profileInfo description]);
    }

    if ([[NSUserDefaults standardUserDefaults] objectForKey:kLastUpdate]) {
        _lastUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUpdate];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserId]) {
        _userId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserPwd]) {
        _userPwd = [[NSUserDefaults standardUserDefaults] objectForKey:kUserPwd];
    }

    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserKey]) {
        _userKey = [[NSUserDefaults standardUserDefaults] objectForKey:kUserKey];
    }

    if ([[NSUserDefaults standardUserDefaults] objectForKey:kCertNo]) {
        _certNo = [[NSUserDefaults standardUserDefaults] objectForKey:kCertNo];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kMemType]) {
        _memberType = [[NSUserDefaults standardUserDefaults] objectForKey:kMemType];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUpdateCount]) {
        _updateCount = [[NSUserDefaults standardUserDefaults] objectForKey:kUpdateCount];
    }

    if ([[NSUserDefaults standardUserDefaults] objectForKey:kMyClass]) {
        _myClass = [[NSUserDefaults standardUserDefaults] objectForKey:kMyClass];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kMyCourse]) {
        _myCourse = [[NSUserDefaults standardUserDefaults] objectForKey:kMyCourse];
    }

    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAutoLogin]) {
        _isAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoLogin];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAcceptTerms]) {
        _isAcceptTerms = [[NSUserDefaults standardUserDefaults] boolForKey:kAcceptTerms];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSetProfile]) {
        _isExistProfile = [[NSUserDefaults standardUserDefaults] boolForKey:kSetProfile];
    }

    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSavedId]) {
        _isSavedID = [[NSUserDefaults standardUserDefaults] boolForKey:kSavedId];
    }

    _language = [TSLanguageManager selectedLanguage];
    NSLog(@"현재 언어 : %@", _language);
    
    _appUpdateUrl = @"";

    NSLog(@"previous AppInfo : \nautoLogin(%d), acceptTerms(%d), isProfile(%d), certno(%@), memtype(%@), updatecnt(%@), updateTime:%@, userID(%@), passWD(%@), userKey(%@)",
          _isAutoLogin, _isAcceptTerms, _isExistProfile, _certNo, _memberType, _updateCount, _lastUpdateDate, _userId, _userPwd, _userKey);

}


/// 자동 로그인 설정
//- (void)setIsAutoLogin:(BOOL)isAutoLogin
//{
//    [[NSUserDefaults standardUserDefaults] setBool:isAutoLogin forKey:kAutoLogin];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    _isAutoLogin = isAutoLogin;
//    NSLog(@"auto_login= %d", _isAutoLogin);
//
//}


@end
