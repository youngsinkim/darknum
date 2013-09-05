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
    NSString *phone = CTSettingCopyMyPhoneNumber();
    
    return phone;
}

@end
