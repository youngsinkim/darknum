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
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                message:@"error"//[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:NSLocalizedString(@"OK", nil), nil]
     show];
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
                
                NSLog(@"response : %@", responseObject);
                NSDictionary *respResult = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                if (![responseObject isEqual:[NSNull null]]) {
                    NSLog(@"error code : %@", respResult[@"errcode"]);
                    if ([respResult[@"errcode"] isEqualToString:@"0"])
                    {
                        success(operation, responseObject);
                    }
                    else
                    {
                        failure(operation, [NSError errorWithDomain:@"Login" code:[respResult[@"errcode"] intValue] userInfo:nil]);
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
/// 로그인 요청
- (void)postLogin:(NSDictionary *)param block:(void (^)(NSMutableDictionary *result, NSError *error))block
{
    static NSString * const kAPILogin = (SERVER_URL@"/fb/login");
    NSLog(@"API Path(%@) param :\n%@", kAPILogin, param);

    [self postPath:kAPILogin
        parameters:param
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               NSLog(@"HTTP POST API: %@", operation.request.URL);
               
               if (block) {
                   NSLog(@"RESPONSE JSON: %@", JSON);
                   
//                   // (errcode = 0)인 경우만 성공으로 처리.
//                   //                   NSDictionary * = (NSDictionary *)JSON;
//                   if (![JSON isEqual:[NSNull null]])
//                   {
//                       NSLog(@"error code : %@", JSON[@"errcode"]);
//                       if (![JSON[@"errcode"] isEqualToString:@"0"]) {
//                           // alert
//                           
//                           return;
//                       }
//                   }

//                   block([NSMutableDictionary dictionaryWithDictionary:JSON], nil);
                   block([NSMutableDictionary dictionaryWithDictionary:[JSON valueForKeyPath:@"data"]], nil);
               }

           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (block) {
                   block([NSMutableDictionary dictionary], error);
               }
               NSLog(@"error : %@", [error description]);
           }];

}

/**
@brief  과정기수 목록
@brief  /fb/classes
@param  scode=5684825a51beb9d2fa05e4675d91253c&userid=ztest01&certno=m9kebjkakte1tvrqfg90i9fh84
@return {"errcode" : "0",
         "data" : [{
                     "title" : "교수진",
                     "count" : "112",
                     "course" : "FACULTY",
                     "courseclass" : "",
                     "title_en" : "Faculty"
                    },
                     {
                     "title" : "교직원",
                     "count" : "58",
                     "course" : "STAFF",
                     "courseclass" : ""
                     },
                     {
                     "favyn" : "n",
                     "title" : "EMBA 1기",
                     "count" : "0",
                     "course" : "EMBA",
                     "courseclass" : "EMBA09001",
                     "title_en" : "Class of EMBA 2009"
                     }]
         }
*/

// 과정별 기수 목록
- (void)postClasses:(NSDictionary *)param block:(void (^)(NSMutableDictionary *result, NSError *error))block
{
    static NSString * const kAPIClasses = (SERVER_URL@"/fb/classes");
    NSLog(@"API Path(%@) param :\n%@", kAPIClasses, param);

    [self postPath:kAPIClasses
        parameters:param
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               NSLog(@"HTTP POST API: %@", operation.request.URL);
               
               if (block) {
                   NSLog(@"RESPONSE JSON: %@", JSON);
                   block([NSMutableDictionary dictionaryWithDictionary:JSON], nil);
//                   block([NSMutableDictionary dictionaryWithDictionary:[JSON valueForKeyPath:@"data"]], nil);
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
