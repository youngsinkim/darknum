//
//  DBMethod.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 10. 11..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "DBMethod.h"

@implementation DBMethod

#pragma mark - 내 정보 조회

/// 사용자 정보 조회
+ (NSArray *)findCourseClass:(NSString *)courseclass
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    if (moc == nil) {
        NSLog(@"After managedObjectContext: %@", moc);
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSLog(@"Find 과정 기수 : %@", courseclass);
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"courseclass == %@", courseclass];
    [fetchRequest setPredicate:predicate];

    [fetchRequest setResultType:NSDictionaryResultType];

    NSError *error = nil;
    NSArray *filtered = [moc executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Filtered DB count : %d", [filtered count]);
    
    return filtered;
}

/// 사용자 정보 조회
+ (NSArray *)findDBMyInfo
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    if (moc == nil) {
        NSLog(@"After managedObjectContext: %@", moc);
        return nil;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // select Table
    NSEntityDescription *entity = nil;
    NSPredicate *predicate = nil;
    MemberType memType = (MemberType)[UserContext shared].memberType;
    NSString *userKey = [UserContext shared].userKey;
    NSLog(@"자신의 타입 : %d, 고유키 : %@", memType, userKey);
    
    if (memType == MemberTypeStudent) {
        // 학생 table
        entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:moc];
        
        predicate = [NSPredicate predicateWithFormat:@"(studcode == %@)", userKey];
    }
    else if (memType == MemberTypeFaculty)
    {
        // 교수 table
        entity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:moc];
        
        predicate = [NSPredicate predicateWithFormat:@"(memberidx == %@)", userKey];
    }
    else if (memType == MemberTypeStaff)
    {
        // 교직원 table
        entity = [NSEntityDescription entityForName:@"Staff" inManagedObjectContext:moc];
        
        predicate = [NSPredicate predicateWithFormat:@"(memberidx == %@)", userKey];
    }
    
    if (entity == nil || predicate == nil) {
        return nil;
    }
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray *filtered = [moc executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Filtered DB count : %d", [filtered count]);
    
    return filtered;
}

@end
