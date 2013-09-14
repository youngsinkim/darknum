//
//  NSString+UrlEncoding.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 15..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UrlEncoding)

- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;

@end
