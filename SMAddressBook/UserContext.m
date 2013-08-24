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
    _isAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoLogin];
    _isAcceptTerms = [[NSUserDefaults standardUserDefaults] boolForKey:kAcceptTerms];
    
    NSLog(@"App Info : auto_login(%d), accept_terms(%d)", _isAutoLogin, _isAcceptTerms);
}

/// 자동 로그인 설정
- (void)setAutoLogin:(BOOL)bAutoLogin
{
    [[NSUserDefaults standardUserDefaults] setBool:bAutoLogin forKey:kAutoLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _isAutoLogin = bAutoLogin;
    
}

/// 약관 동의 설정
- (void)setAcceptTerms:(BOOL)bAcceptTerms
{
    [[NSUserDefaults standardUserDefaults] setBool:bAcceptTerms forKey:kAcceptTerms];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _isAcceptTerms = bAcceptTerms;
    
}

@end
