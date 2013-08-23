//
//  Classes.h
//  SMAddressBook
//
//  Created by sochae on 13. 8. 23..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Classes : NSManagedObject

@property (nonatomic, retain) NSString * course;
@property (nonatomic, retain) NSString * courseclass;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * title_en;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSNumber * favyn;
@property (nonatomic, retain) NSSet *students;
@end

@interface Classes (CoreDataGeneratedAccessors)

- (void)addStudentsObject:(NSManagedObject *)value;
- (void)removeStudentsObject:(NSManagedObject *)value;
- (void)addStudents:(NSSet *)values;
- (void)removeStudents:(NSSet *)values;

@end
