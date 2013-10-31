//
//  NSDictionary+UTF8.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 18..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (UTF8)

- (NSDictionary*)dictionaryByUTF8Encode;
- (NSDictionary*)dictionaryByUTF8Decode;

@end
