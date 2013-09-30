//
//  NSURLRequest+SSL.h
//  SMAddressBook
//
//  Created by sochae on 13. 9. 30..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (SSL) <NSURLConnectionDelegate>

/// for SSL
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;

@end
