//
//  Util.m
//  SMAddressBook
//
//  Created by sochae on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "Util.h"

/// 단말 전화번호 사용을 위해 추가 
extern NSString* CTSettingCopyMyPhoneNumber();

@implementation Util

/// 단말 전화 번호
+ (NSString *)phoneNumber
{
    NSString *orgPhone = CTSettingCopyMyPhoneNumber();
    
    int location = orgPhone.length - 10;
    int length = orgPhone.length;
    NSString *phone = [NSString stringWithFormat:@"0%@", [orgPhone substringWithRange:NSMakeRange(location, length - location)]];
    NSLog(@"Phone : %@", phone);    // phone = "+821025297368";
    
    // TODO: 임시로 하드 코딩함 (API 연동)
    phone = @"01023873856";
    
    return phone;
}

@end