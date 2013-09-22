//
//  SMNetworkClient.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 22..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "SMNetworkClient.h"
#import <AFJSONRequestOperation.h>
#import <JSONKit.h>
#import "NSDictionary+UTF8.h"

#define SERVER_URL          @"http://biz.snu.ac.kr"

//@interface SMNetworkClient : AFHTTPClient
//@end

@implementation SMNetworkClient

+ (SMNetworkClient *)sharedClient
{
    static SMNetworkClient *_sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SMNetworkClient alloc] initWithBaseURL:[NSURL URLWithString:SERVER_URL]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.parameterEncoding = AFFormURLParameterEncoding;// AFJSONParameterEncoding;
    
    // Accept HTTP Header;
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    
    // By default, the example ships with SSL pinning enabled for the app.net API pinned against the public key of adn.cer file included with the example. In order to make it easier for developers who are new to AFNetworking, SSL pinning is automatically disabled if the base URL has been changed. This will allow developers to hack around with the example, without getting tripped up by SSL pinning.
    //    if ([[url scheme] isEqualToString:@"https"] && [[url host] isEqualToString:@"alpha-api.app.net"]) {
    //        [self setDefaultSSLPinningMode:AFSSLPinningModePublicKey];
    //    }
    //
    //    self.defaultSSLPinningMode = AFSSLPinningModeNone;
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
//    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    
    
    return self;
}


#pragma mark - http common methods

/// Network Error 처리
- (void)showNetworkError:(NSError *)error
{
    NSLog(@"error ---- %@", [error localizedDescription]);
    NSDictionary *info = [NSDictionary dictionaryWithDictionary:[error userInfo]];
    NSLog(@"error UserInfo : %@", info);
    if (![info isEqual:[NSNull null]]) {
        NSString *message = info[kErrorMsg];
        if (message.length == 0) {
            message = NSLocalizedString(info[@"NSLocalizedDescription"], nil);
        }
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil]
         show];
    }
}

// json data 검사를 위해 override
- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [super getPath:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject){
               NSLog(@"successsssssssss");
               success(operation, responseObject);
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error){
               failure(operation, error);
           }
     ];
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    [super postPath:(NSString *)path
         parameters:(NSDictionary *)parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSDictionary *response = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                NSLog(@"response : %@", responseObject);

                if (![responseObject isKindOfClass:[NSNull class]])
                {
                    NSLog(@"error (%@) : %@", response[kErrorCode], response[kErrorMsg]);
                
                    if ([response[kErrorCode] integerValue] == 0)
                    {
                        // no errors.
                        success(operation, responseObject);
                    }
                    else
                    {
                        failure(operation, [NSError errorWithDomain:path code:[response[@"errcode"] intValue] userInfo:response]);
                    
//                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                                            message:response[kErrorMsg]
//                                                                           delegate:nil
//                                                                  cancelButtonTitle:LocalizedString(@"Ok", @"Ok")
//                                                                  otherButtonTitles:nil];
//                        [alertView show];

                    }
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                failure(operation, error);
            }
     ];
}

#pragma mark - API methods

/// Request Data : scode=5684825a51beb9d2fa05e4675d91253c&phone=01023873856&updatedate=0000-00-00 00:00:00&userid=ztest01&passwd=1111#
/// Response Data : {"errcode":"0","certno":"m9kebjkakte1tvrqfg90i9fh84","memtype":"1","updatecount":"218"}
/// 2. 로그인 요청
- (void)postLogin:(NSDictionary *)param block:(void (^)(NSDictionary *result, NSError *error))block
{
    static NSString * const kAPILogin = (SERVER_URL@"/fb/login");
    NSLog(@"API Path(%@) param :\n%@", kAPILogin, param);

    [self postPath:kAPILogin
        parameters:param
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               
               NSLog(@"HTTP POST API: %@", operation.request.URL);
               
               if (block)
               {
                    // (errcode = 0)인 경우만 성공으로 처리.
                    NSDictionary *response = (NSDictionary *)JSON;
                    NSLog(@"RESPONSE INFO: %@", response);

                    if (![response isKindOfClass:[NSNull class]])
                    {
                        block([NSDictionary dictionaryWithDictionary:[JSON valueForKeyPath:@"data"]], nil);

//                        NSLog(@"error (%d) : %@", [response[kErrorCode] integerValue], response[kErrorMsg]);
//                        if (![response[kErrorCode] integerValue] == 0)
//                        {
////                           block([NSMutableDictionary dictionaryWithDictionary:JSON], nil);
//                        }
//                        else
//                        {
//                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                                                message:response[kErrorMsg]
//                                                                               delegate:nil
//                                                                      cancelButtonTitle:LocalizedString(@"Ok", @"Ok")
//                                                                      otherButtonTitles:nil];
//                            [alertView show];
//                        }
                    }
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSLog(@"error : %@", [error description]);
                if (block) {
                    block([NSDictionary dictionary], error);
                }
            }];

}

/**
@brief  과정기수 목록
@brief  /fb/classes
@param  scode=5684825a51beb9d2fa05e4675d91253c&userid=ztest01&certno=m9kebjkakte1tvrqfg90i9fh84
 */
/// 3. 과정별 기수 목록
- (void)postClasses:(NSDictionary *)param block:(void (^)(NSArray *result, NSError *error))block
{
    static NSString * const kAPIClasses = (SERVER_URL@"/fb/classes");
    NSLog(@"API Path(%@) param :\n%@", kAPIClasses, param);

    [self postPath:kAPIClasses
        parameters:param
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               NSLog(@"HTTP POST API: %@", operation.request.URL);
               
               if (block) {
                   NSLog(@"RESPONSE JSON: %@", JSON);
                   
                   if ([NSJSONSerialization isValidJSONObject:[JSON valueForKeyPath:@"data"]]) {
                       block([NSArray arrayWithArray:[JSON valueForKeyPath:@"data"]], nil);
                   }
//                   block([NSDictionary dictionaryWithDictionary:JSON], nil);
//                   block([NSMutableDictionary dictionaryWithDictionary:[JSON valueForKeyPath:@"data"]], nil);
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (block) {
                   block([NSArray array], error);
               }
               NSLog(@"error : %@", [error description]);
           }];
    
}

/// 4-1. 기수별 학생 목록
- (void)postStudents:(NSDictionary *)param block:(void (^)(NSMutableArray *result, NSError *error))block
{
    static NSString * const kAPIStudents = (SERVER_URL@"/fb/students");
    NSLog(@"API Path(%@) param :\n%@", kAPIStudents, param);
    
    [self postPath:kAPIStudents
        parameters:param
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               NSLog(@"HTTP POST API: %@", operation.request.URL);
               
               if (block) {
                   NSLog(@"RESPONSE JSON: %@", [JSON valueForKeyPath:@"data"]);
//                   block([NSMutableDictionary dictionaryWithDictionary:JSON], nil);
                   NSMutableArray *array = [[NSMutableArray alloc] init];
                   if ([NSJSONSerialization isValidJSONObject:[JSON valueForKeyPath:@"data"]]) {
                       [array setArray:[JSON valueForKeyPath:@"data"]];
                   }

                   block([NSMutableArray arrayWithArray:array], nil);
               }
               
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               
               if (block) {
                   block([NSMutableArray array], error);
               }
               NSLog(@"error : %@", [error description]);
           }];
    
}


// 교수 전공 목록
- (void)postMajors:(NSDictionary *)param block:(void (^)(NSArray *result, NSError *error))block
{
    static NSString * const kAPIMajors = (SERVER_URL@"/fb/majors");
    NSLog(@"API Path(%@) param :\n%@", kAPIMajors, param);
    
    [self postPath:kAPIMajors
        parameters:param
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               NSLog(@"HTTP POST API: %@", operation.request.URL);
               
               if (block) {
                   NSLog(@"RESPONSE JSON: %@", [JSON valueForKeyPath:@"data"]);
                   
                   if ([NSJSONSerialization isValidJSONObject:[JSON valueForKeyPath:@"data"]]) {
                       block([NSArray arrayWithArray:[JSON valueForKeyPath:@"data"]], nil);
                   }
//                   block([NSMutableDictionary dictionaryWithDictionary:JSON], nil);
//                   block([NSMutableArray arrayWithArray:[JSON valueForKeyPath:@"data"]], nil);
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (block) {
                   block([NSArray array], error);
               }
               NSLog(@"error : %@", [error description]);
           }];
    
}

// (업데이트된) 즐겨찾기 목록
- (void)postFavorites:(NSDictionary *)param block:(void (^)(NSDictionary *result, NSError *error))block
{
    static NSString * const kAPIFavorites = (SERVER_URL@"/fb/updated");
    NSLog(@"API Path(%@) param :\n%@", kAPIFavorites, param);
    
    [self postPath:kAPIFavorites
        parameters:param
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               NSLog(@"HTTP POST API: %@", operation.request.URL);
               
               if (block) {
                   NSLog(@"RESPONSE JSON: %@", JSON);
                   
                   if ([NSJSONSerialization isValidJSONObject:[JSON valueForKeyPath:@"data"]]) {
                       block([NSDictionary dictionaryWithDictionary:[JSON valueForKeyPath:@"data"]], nil);
                   }
//                   block([NSDictionary dictionaryWithDictionary:JSON], nil);
//                   block([NSMutableArray arrayWithObjects:[JSON valueForKeyPath:@"data"], nil], nil);
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (block) {
                   block([NSDictionary dictionary], error);
               }
               NSLog(@"error : %@", [error description]);
           }];
    
}

// 즐겨찾기 업데이트 (추가 / 삭제)
- (void)updateFavorites:(NSDictionary *)param block:(void (^)(NSMutableDictionary *result, NSError *error))block
{
    static NSString * const kAPIFavoritesUpdate = (SERVER_URL@"/fb/updatefavorite");
    NSLog(@"API Path(%@) param :\n%@", kAPIFavoritesUpdate, param);
    
    [self postPath:kAPIFavoritesUpdate
        parameters:param
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               NSLog(@"HTTP POST API: %@", operation.request.URL);
               
               if (block) {
                   NSLog(@"RESPONSE JSON: %@", JSON);
                   block([NSMutableDictionary dictionaryWithDictionary:JSON], nil);
//                   block([NSMutableArray arrayWithObjects:[JSON valueForKeyPath:@"data"], nil], nil);
               }
               
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (block) {
                   block([NSMutableDictionary dictionary], error);
               }
               NSLog(@"error : %@", [error description]);
           }];
    
}

// 내 프로필 정보
- (void)postMyInfo:(NSDictionary *)param block:(void (^)(NSDictionary *result, NSError *error))block
{
    static NSString * const kAPIMyInfo = (SERVER_URL@"/fb/myinfo");
    NSLog(@"API Path(%@) param :\n%@", kAPIMyInfo, param);
    
    [self postPath:kAPIMyInfo
        parameters:param
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               NSLog(@"HTTP POST API: %@", operation.request.URL);
               
               if (block) {
                   NSLog(@"RESPONSE JSON: %@", JSON);
//                   block([NSMutableDictionary dictionaryWithDictionary:JSON], nil);
                   block([NSDictionary dictionaryWithDictionary:[JSON valueForKeyPath:@"data"]], nil);
               }
               
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (block) {
                   block([NSMutableDictionary dictionary], error);
               }
               NSLog(@"error : %@", [error description]);
           }];
    
}

@end
