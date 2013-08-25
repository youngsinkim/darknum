//
//  Course.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Student;

@interface Course : NSManagedObject

@property (nonatomic, retain) NSString * count;
@property (nonatomic, retain) NSString * course;
@property (nonatomic, retain) NSString * courseclass;
@property (nonatomic) BOOL favyn;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * title_en;
@property (nonatomic, retain) NSSet *students;
@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addStudentsObject:(Student *)value;
- (void)removeStudentsObject:(Student *)value;
- (void)addStudents:(NSSet *)values;
- (void)removeStudents:(NSSet *)values;

@end
