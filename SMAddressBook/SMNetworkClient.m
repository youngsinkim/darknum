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

static NSString * const kAPILogin = (SERVER_URL @"/fb/login");

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
                                message:[error localizedDescription]
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
//
//- (void)postPath:(NSString *)path
//      parameters:(NSDictionary *)parameters
//         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    [super postPath:(NSString *)path
//         parameters:(NSDictionary *)parameters
//            success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                NSLog(@"successsssssssss");
//                success(operation, responseObject);
//            }
//            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                failure(operation, error);
//            }
//     ];
//}

#pragma mark - API methods

/// Request Data : scode=5684825a51beb9d2fa05e4675d91253c&phone=01023873856&updatedate=0000-00-00 00:00:00&userid=ztest01&passwd=1111#
/// Response Data : {"errcode":"0","certno":"m9kebjkakte1tvrqfg90i9fh84","memtype":"1","updatecount":"218"}
/// 로그인 요청
- (void)postLogin:(NSDictionary *)param block:(void (^)(NSMutableDictionary *dData, NSError *error))block
{
    NSLog(@"PARAN : %@", param);
    [self postPath:kAPILogin
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

@end
