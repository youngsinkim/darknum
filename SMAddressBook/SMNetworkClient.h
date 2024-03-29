//
//  SMNetworkClient.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 22..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "AFHTTPClient.h"

#define SERVER_URL          @"https://biz.snu.ac.kr"

#define apiClassesKey       @"http://biz.snu.ac.kr/fb/classes"
#define apiMajorKey         @"http://biz.snu.ac.kr/fb/majors"
#define apiFavoriteKey      @"http://biz.snu.ac.kr/fb/updated"

/// response JSON key codes
#define kErrorCode      @"errcode"
#define kErrorMsg       @"errmsg"
#define kData           @"data"

// input key codes
//#define kUserId         @"userid"
//#define kScode          @"scode"

//#define kCertNo         @"certno"
//#define kMemType        @"memtype"
//#define kLastUpdate     @"lastupdate"
//#define kUpdateCount    @"updatecount"


@interface SMNetworkClient : AFHTTPClient

+ (SMNetworkClient *)sharedClient;

/// Network Error 처리
- (void)showNetworkError:(NSError *)error;

#pragma mark - Restful API
/// 2. 로그인 요청
- (void)postLogin:(NSDictionary *)param block:(void (^)(NSDictionary *result, NSError *error))block;

/// 3. 과정기수 목록
- (void)postClasses:(NSDictionary *)param block:(void (^)(NSArray *result, NSError *error))block;

/// 4-1. 기수별 학생 목록
- (void)postStudents:(NSDictionary *)param block:(void (^)(NSMutableArray *result, NSError *error))block;

/// 6. 교수전공 목록
- (void)postMajors:(NSDictionary *)param block:(void (^)(NSArray *result, NSError *error))block;

/// 12. 즐겨찾기 업데이트 목록
- (void)postFavorites:(NSDictionary *)param block:(void (^)(NSDictionary *result, NSError *error))block;

// 즐겨찾기 업데이트 (추가 / 삭제)
- (void)updateFavorites:(NSDictionary *)param block:(void (^)(NSDictionary *result, NSError *error))block;

/// 7. 내 정보 조회(학생) / 9-1. 내 정보 조회(교수) / 9-2. 내 정보 조회(교직원)
- (void)postMyInfo:(NSDictionary *)param block:(void (^)(NSDictionary *result, NSError *error))block;

/// 8. 내 정보 저장(학생)
- (void)updateMyInfo:(NSDictionary *)param block:(void (^)(NSDictionary *result, NSError *error))block;

/// 14. 본인인증 요청
- (void)postAuth:(NSDictionary *)param block:(void (^)(NSDictionary *result, NSError *error))block;

/// 15. 인증번호 받기
- (void)postAuthSms:(NSDictionary *)param block:(void (^)(NSDictionary *result, NSError *error))block;

/// otn test API
//- (void)getVodTotalList:(NSDictionary *)param block:(void (^)(NSMutableDictionary *dData, NSError *error))block;

@end
