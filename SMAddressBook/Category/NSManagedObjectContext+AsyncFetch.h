//
//  NSManagedObjectContext+AsyncFetch.h
//  SMAddressBook
//
//  Created by sochae on 13. 9. 27..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (AsyncFetch)

- (void)executeFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *objects, NSError *error))completion;

@end
