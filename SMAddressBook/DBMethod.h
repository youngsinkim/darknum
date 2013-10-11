//
//  DBMethod.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 10. 11..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBMethod : NSObject

/// 사용자 정보 조회
+ (NSArray *)findCourseClass:(NSString *)courseclass;

/// 사용자 정보 조회
+ (NSArray *)findDBMyInfo;

@end
