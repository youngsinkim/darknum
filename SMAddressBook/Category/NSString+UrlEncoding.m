//
//  NSString+UrlEncoding.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 15..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "NSString+UrlEncoding.h"

@implementation NSString (UrlEncoding)

- (NSString *)URLEncodedString
{
    NSString *result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                    (CFStringRef)self,
                                                                                    NULL,
                                                                                    CFSTR("!*'\"();:@&=+$,/?%#[]% "),
//                                                                                    CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                    kCFStringEncodingUTF8);
    return result;
//    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
//                                                                                 (__bridge CFStringRef)self,
//                                                                                 NULL,
//                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
//                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

- (NSString*)URLDecodedString
{
	NSString *result = (__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                    (CFStringRef)self,
                                                                                                    CFSTR(""),
                                                                                                    kCFStringEncodingUTF8);
    return result;
}

@end
