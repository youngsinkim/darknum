//
//  Util.h
//  SMAddressBook
//
//  Created by sochae on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - iOS 7 method
NSUInteger DeviceSystemMajorVersion();
#define IS_LESS_THEN_IOS7 (DeviceSystemMajorVersion() < 7)



@interface Util : NSObject

/// iOS 7 이하 버전 체크
NSUInteger DeviceSystemMajorVersion();

/// 단말 전화 번호
+ (NSString *)phoneNumber;

@end

