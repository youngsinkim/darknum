//
//  ModelUtil.h
//  SMAddressBook
//
//  Created by sochae on 13. 9. 27..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelUtil : NSObject

+ (NSArray *)fetchManagedObjects:(NSString *)entityName predicate:(NSPredicate *)predicate sort:(NSArray *)sortDescriptors moc:(NSManagedObjectContext *)moc;

+ (NSManagedObject *)fetchManagedObject:(NSString *)entityName predicate:(NSPredicate *)predicate sort:(NSArray *)sortDescriptors moc:(NSManagedObjectContext *)moc;

@end

