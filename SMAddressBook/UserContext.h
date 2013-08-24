//
//  UserContext.h
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserContext : NSObject

@property (strong, nonatomic) NSMutableDictionary *loginInfo;   // 로그인 데이터
@property (assign) BOOL isAutoLogin;        //< 자동 로그인 설정 여부
@property (assign) BOOL isAcceptTerms;      //< 약관 동의 여부

+ (UserContext *)shared;

@end
