//
//  Major.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Faculty;

@interface Major : NSManagedObject

@property (nonatomic, retain) NSString * major;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * title_en;
@property (nonatomic, retain) NSSet *facultys;
@end

@interface Major (CoreDataGeneratedAccessors)

- (void)addFacultysObject:(Faculty *)value;
- (void)removeFacultysObject:(Faculty *)value;
- (void)addFacultys:(NSSet *)values;
- (void)removeFacultys:(NSSet *)values;

@end
