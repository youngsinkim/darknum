//
//  SMNetworkClient.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 22..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "AFHTTPClient.h"

@interface SMNetworkClient : AFHTTPClient

+ (SMNetworkClient *)sharedClient;

/// Network Error 처리
- (void)showNetworkError:(NSError *)error;

#pragma mark - Restful API
/// 로그인 요청
- (void)postLogin:(NSDictionary *)param block:(void (^)(NSMutableDictionary *dData, NSError *error))block;

/// otn test API
- (void)getVodTotalList:(NSDictionary *)param block:(void (^)(NSMutableDictionary *dData, NSError *error))block;

@end
