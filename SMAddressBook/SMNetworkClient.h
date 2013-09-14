//
//  SMNetworkClient.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 22..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "AFHTTPClient.h"

/// response JSON key codes
#define kErrorCode      @"errcode"
#define kErrorMsg       @"errmsg"
#define kData           @"data"

// input key codes
#define kUserId         @"userid"
#define kScode          @"scode"

#define kCertNo         @"certno"
#define kMemType        @"memtype"
#define kLastUpdate     @"lastupdate"
#define kUpdateCount    @"updatecount"


@interface SMNetworkClient : AFHTTPClient

+ (SMNetworkClient *)sharedClient;

/// Network Error 처리
- (void)showNetworkError:(NSError *)error;

#pragma mark - Restful API
/// 2. 로그인 요청
- (void)postLogin:(NSDictionary *)param block:(void (^)(NSMutableDictionary *dData, NSError *error))block;

/// 3. 과정기수 목록
- (void)postClasses:(NSDictionary *)param block:(void (^)(NSMutableDictionary *dData, NSError *error))block;

/// 4-1. 기수별 학생 목록
- (void)postStudents:(NSDictionary *)param block:(void (^)(NSMutableArray *result, NSError *error))block;

// 교수 전공 목록
- (void)postMajors:(NSDictionary *)param block:(void (^)(NSMutableArray *result, NSError *error))block;

// (업데이트된) 즐겨찾기 목록
- (void)postFavorites:(NSDictionary *)param block:(void (^)(NSMutableDictionary *result, NSError *error))block;

// 즐겨찾기 업데이트 (추가 / 삭제)
- (void)updateFavorites:(NSDictionary *)param block:(void (^)(NSMutableDictionary *result, NSError *error))block;

/// 내 (프로필)정보
- (void)postMyInfo:(NSDictionary *)param block:(void (^)(NSDictionary *result, NSError *error))block;

/// otn test API
- (void)getVodTotalList:(NSDictionary *)param block:(void (^)(NSMutableDictionary *dData, NSError *error))block;

@end
