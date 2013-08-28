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
        _sharedUserContext.loginInfo = [[NSMutableDictionary alloc] initWithCapacity:3];
        _sharedUserContext.isLogined = NO;
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
        //
        [self loadAppSetting];
    
        //		vcCallStack = [[NSMutableArray alloc] initWithCapacity:20];
        //		self.feedCounter = [[[FeedCounter alloc] init] autorelease];
        
        //        self.userToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_TOKEN"];
        //        self.userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_ID"];
        //        self.userProfileImage = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_IMAGE"];
        //        self.nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_NICKNAME"];
        //		self.deviceToken = @"DEVICE_TOKEN";
    }
    
	return self;
}

#pragma mark -

/// App 세팅 읽어오기
- (void)loadAppSetting
{
    // TODO: 로그인 데이터 읽어오기
    _isAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoLogin];
    _isAcceptTerms = [[NSUserDefaults standardUserDefaults] boolForKey:kAcceptTerms];
    _isExistProfile = [[NSUserDefaults standardUserDefaults] boolForKey:kSetProfile];
    
    [_loginInfo setDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kLoginInfo]];
    _certNo = [[NSUserDefaults standardUserDefaults] objectForKey:@"certno"];
    
    NSLog(@"login = %@", _loginInfo);
    NSLog(@"App Setting Info : auto_login(%d), accept_terms(%d), certno = %@", _isAutoLogin, _isAcceptTerms, _certNo);

}

/// 로그인 화면 저장하기
//- (void)setLoginInfo:(NSMutableDictionary *)loginInfo
//{
//    /// TODO: 로그인 데이터 파일로 저장하는 루틴 추가
//    [[NSUserDefaults standardUserDefaults] setObject:loginInfo forKey:kLoginInfo];
////    [[NSUserDefaults standardUserDefaults] setObject:loginInfo[@"certno"] forKey:@"certno"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
////    _certNo = loginInfo[@"certno"];
////    NSLog(@"login = %@", _certNo);
//    _loginInfo = loginInfo;
//}

/// 자동 로그인 설정
- (void)setIsAutoLogin:(BOOL)isAutoLogin
{
    [[NSUserDefaults standardUserDefaults] setBool:isAutoLogin forKey:kAutoLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _isAutoLogin = isAutoLogin;
    NSLog(@"auto_login= %d", _isAutoLogin);

}

/// 약관 동의 설정
- (void)setIsAcceptTerms:(BOOL)isAcceptTerms
{
    [[NSUserDefaults standardUserDefaults] setBool:isAcceptTerms forKey:kAcceptTerms];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _isAcceptTerms = isAcceptTerms;
}

/// 내 정보(profile) 설정
- (void)setIsExistProfile:(BOOL)isExistProfile
{
    [[NSUserDefaults standardUserDefaults] setBool:isExistProfile forKey:kSetProfile];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _isExistProfile = isExistProfile;
}

@end
