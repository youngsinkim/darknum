//
//  DBMethod.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 10. 11..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "DBMethod.h"
#import "Course.h"
#import "Major.h"
#import "Faculty.h"
#import "Student.h"
#import "Staff.h"

@implementation DBMethod


#pragma mark 즐겨찾기 (Course)목록 조회
/// 즐겨찾기 (기수)목록 가져오기
+ (NSArray *)loadDBFavoriteCourses
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    if (moc == nil) {
        NSLog(@"After managedObjectContext: %@", moc);
        return nil;
    }

    NSManagedObjectContext *threadedMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    threadedMoc.parentContext = moc;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(course == 'FACULTY') OR (course == 'STAFF') OR (favyn == 'y')"];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    NSLog(@"즐겨찾기 (Course)목록 조회 수 : %d", [fetchedObjects count]);
    
    return fetchedObjects;
}

#pragma mark 전체 교수 목록 조회
/// 전체 교수 목록 가져오기
+ (NSArray *)loadDBAllFaculties
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    if (moc == nil) {
        NSLog(@"After managedObjectContext: %@", moc);
        return nil;
    }
    
    NSManagedObjectContext *threadedMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    threadedMoc.parentContext = moc;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setResultType:NSDictionaryResultType];
//    [fetchRequest setRelationshipKeyPathsForPrefetching:@[@"major"]];
//    NSDictionary *properties = [entity propertiesByName];
//    NSMutableArray *propertiesToFetch = [NSMutableArray arrayWithArray:[properties allValues]];// arrayWithObject:[properties allValues], @"major.title", nil];
//    [propertiesToFetch addObject:@"major.title"];
//    [propertiesToFetch addObject:@"major.title_en"];
//    [fetchRequest setPropertiesToFetch:[propertiesToFetch mutableCopy]];
//    //    [fetchRequest setPropertiesToFetch:@[@"major.title", @"email", @"memberidx", @"name", @"mobile", @"name_en", @"office", @"office_en", @"photourl", @"tel", @"viewphotourl"]];
//    //    [fetchRequest setPropertiesToFetch:@[@"majortitle", @"major.title"]];
//    [fetchRequest setReturnsObjectsAsFaults:NO];
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(major.major == %@)", _majorInfo[@"major"]];
//    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor;
    if ([[UserContext shared].language isEqualToString:kLMKorean]) {
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    } else {
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name_en" ascending:YES];
    }
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    NSLog(@"전체 교수 조회 수 : %d", [fetchedObjects count]);
    
    return fetchedObjects;
}


#pragma mark 기수 목록 업데이트
/// 전체 기수목록 DB 추가 및 업데이트
+ (void)saveDBCourseClasses:(NSArray *)courseClasses
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    if (moc == nil) {
        NSLog(@"After managedObjectContext: %@", moc);
        return;
    }

//    NSManagedObjectContext *parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//    [parentContext setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    //    [mainMoc setParentContext:writeMoc];
    
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:moc];
    
    NSManagedObjectContext *findContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [findContext setParentContext:moc];
    
    __block BOOL done = NO;
    
    [childContext performBlock:^{
        
        for (NSDictionary *info in courseClasses)
        {
            Course *course = nil;
            __block NSMutableArray *fetchedObjects = nil;
            NSLog(@"저장할 기수 : %@", info[@"title"]);
            
            [childContext performBlockAndWait:^{
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:moc];
                [fetchRequest setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course == %@ AND courseclass == %@", info[@"course"], info[@"courseclass"]];
                [fetchRequest setPredicate:predicate];
                
                NSArray *objects = [childContext executeFetchRequest:fetchRequest error:nil];
                fetchedObjects = [objects mutableCopy];
                NSLog(@"기수 찾았나? %d", [fetchedObjects count]);
            }];
            
            if ([fetchedObjects count] > 0)
            {
                // 기존에 존재하던 기수 과정이면 내용 업데이트
                course = fetchedObjects[0];
                
                // ( NSManagedObject <- NSDictionary )
                NSLog(@"업데이트 (기수)과정 : course(%@), courseclass(%@), title(%@), favyn(%@), count (%@)", course.course, course.courseclass, course.title, course.favyn, course.count);
                course.count = info[@"count"];
                course.course = info[@"course"];
                course.courseclass = info[@"courseclass"];
                course.favyn = info[@"favyn"];
                course.title = info[@"title"];
                course.title_en = info[@"title_en"];
//                course.type = info["type"];
            }
            else
            {
                // 기존 목록에 없으면 추가 (INSERT)
                course = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:childContext];
                
                // ( NSManagedObject <- NSDictionary )
                course.count = info[@"count"];
                course.course = info[@"course"];
                course.courseclass = info[@"courseclass"];
                course.favyn = info[@"favyn"];
                course.title = info[@"title"];
                course.title_en = info[@"title_en"];
                //                course.type = info["type"];
                
                // 교수, 교직원, 학색 타입 부여
                if ([info[@"course"] isEqualToString:@"FACULTY"]) {
                    course.type = @"2";
                } else if ([info[@"course"] isEqualToString:@"STAFF"]) {
                    course.type = @"3";
                } else {
                    course.type = @"1";
                }
                
                NSLog(@"추가 (기수)과정(%@) : course(%@), courseclass(%@), title(%@), favyn(%@), count (%@)", course.type, course.course, course.courseclass, course.title, course.favyn, course.count);
            }
            
            NSLog(@"(%@)과정 목록 DB 저장 성공!", course.courseclass);
            [childContext save:nil];
            
        } // for
        
        done = YES;
//        _isCourseSaveDone = YES;
        NSLog(@"..... CourseClass done .....");
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [moc save:nil];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
            NSArray *objects = [moc executeFetchRequest:request error:nil];
            NSLog(@"전체 기수 저장 Done: %d objects written", [objects count]);
            
            // 업데이트된 (기수)과정 목록 즐겨찾기 화면에 반영
//            [_favorites setArray:[self loadDBFavoriteCourses]];
//            
//            if ([_favorites count] > 0) {
//                NSLog(@".......... updateTable ..........");
//                [self refreshFavoriteTable];
//                //                [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
//            }
//            
//            if (_isSavingFavorites == NO) {
//                [self performSelector:@selector(saveDBFavoriteUpdates) withObject:nil];
//            }
            
        });
        
    }]; // childContext
    
//    // execute a read request after 0.5 second
//    double delayInSeconds = 0.1;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
//        
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
//        [moc performBlockAndWait:^{
//            
//            NSArray *objects = [moc executeFetchRequest:request error:nil];
//            NSLog(@"In between read: read %d objects", [objects count]);
//        }];
//    });
}


#pragma mark 교수 전공목록 DB 저장
/// 교수 전공목록 DB 업데이트
+ (void)saveDBMajors:(NSArray *)majors
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    if (moc == nil) {
        NSLog(@"After managedObjectContext: %@", moc);
        return;
    }

    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:moc];
    
    NSManagedObjectContext *findContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [findContext setParentContext:moc];
    
//    NSLog(@"parent: %@,   child : %@,    find: %@,  main : %@", parentContext, childContext, findContext, appDelegate.managedObjectContext);
    __block BOOL done = NO;
    
    [childContext performBlock:^{
        
        for (NSDictionary *info in majors)
        {
            Major *major = nil;
            __block NSMutableArray *fetchedObjects = nil;
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            
            // 이미 존재하는 전공인지 확인
            [childContext performBlockAndWait:^{
                NSLog(@"찾을 전공 : %@, %@", info[@"major"], info[@"title"]);
                
                NSEntityDescription * entity = [NSEntityDescription entityForName:@"Major" inManagedObjectContext:moc];
                [fetchRequest setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"major == %@", info[@"major"]];
                [fetchRequest setPredicate:predicate];
                
                NSArray *array = [childContext executeFetchRequest:fetchRequest error:nil];
                fetchedObjects = [array mutableCopy];
                NSLog(@"찾은 전공 개수 : %d", [fetchedObjects count]);
                
            }]; // childContext
            
            if ([fetchedObjects count] > 0)
            {
                major = fetchedObjects[0];
                
                // ( NSManagedObject <- NSDictionary )
                major.major = info[@"major"];
                major.title = info[@"title"];
                major.title_en = info[@"title_en"];
                NSLog(@"업데이트 전공 : major(%@), title(%@) title_en(%@)", major.major, major.title, major.title_en);
            }
            else
            {
                major = (Major *)[NSEntityDescription insertNewObjectForEntityForName:@"Major" inManagedObjectContext:childContext];
                
                // ( NSManagedObject <- NSDictionary )
                major.major = info[@"major"];
                major.title = info[@"title"];
                major.title_en = info[@"title_en"];
                //                major.facultys;
                
                NSLog(@"추가 전공 : major(%@), title(%@), title_en(%@0", major.major, major.title, major.title_en);
            }
            
            NSLog(@"(%@)전공 DB 저장 성공!", major.title);
            [childContext save:nil];
        }
        
        done = YES;
//        _isMajorSaveDone = YES;
        NSLog(@"..... major done .....");
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [moc save:nil];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Major"];
            NSArray *objects = [moc executeFetchRequest:request error:nil];
            NSLog(@"전공 저장 Done: %d objects written", [objects count]);
            
//            if (_isSavingFavorites == NO) {
//                [self performSelector:@selector(saveDBFavoriteUpdates) withObject:nil];
//            }
        });
        
    }]; // childContext
    
    // execute a read request after 0.5 second
//    double delayInSeconds = 0.1;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
//        
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Major"];
//        [moc performBlockAndWait:^{
//            
//            NSArray *objects = [moc executeFetchRequest:request error:nil];
//            NSLog(@"In between read: read %d objects", [objects count]);
//        }];
//    });

}


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
