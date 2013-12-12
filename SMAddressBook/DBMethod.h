//
//  DBMethod.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 10. 11..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBMethod : NSObject

/// 즐겨찾기 (기수)목록 가져오기
+ (NSArray *)loadDBFavoriteCourses;

/// 전체 교수 목록 가져오기
+ (NSArray *)loadDBAllFaculties;

/// 전체 기수목록 DB 추가 및 업데이트
+ (void)saveDBCourseClasses:(NSArray *)courseClasses;

/// 교수 전공목록 DB 업데이트
+ (void)saveDBMajors:(NSArray *)majors;

/// 사용자 정보 조회
+ (NSArray *)findCourseClass:(NSString *)courseclass;

/// 사용자 정보 조회
+ (NSArray *)findDBMyInfo;

// 데이터베이스 초기화
+ (void)resetDatabase;

@end
