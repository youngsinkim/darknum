//
//  Major+Methods.h
//  SMAddressBook
//
//  Created by sochae on 13. 9. 27..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "Major.h"

@interface Major (Methods)


@property (nonatomic, retain) NSString * major;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * title_en;
@property (nonatomic, retain) NSSet *facultys;

+ (Major *)insertMajor:(NSString *)major title:(NSString *)title managedObjectContext:(NSManagedObjectContext *)moc;

+ (Major *)major:(NSString *)major managedObjectContext:(NSManagedObjectContext *)moc;

@end
