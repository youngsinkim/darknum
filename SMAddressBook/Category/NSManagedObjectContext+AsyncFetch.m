//
//  NSManagedObjectContext+AsyncFetch.m
//  SMAddressBook
//
//  Created by sochae on 13. 9. 27..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "NSManagedObjectContext+AsyncFetch.h"

@implementation NSManagedObjectContext (AsyncFetch)

- (void)executeFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *objects, NSError *error))completion
{
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [backgroundContext performBlock:^{
        backgroundContext.persistentStoreCoordinator = coordinator;
        
        // Fetch into shared persistent store in background thread
        NSError *error = nil;
        NSArray *fetchedObjects = [backgroundContext executeFetchRequest:request error:&error];
        
        [self performBlock:^{
            
            if (fetchedObjects)
            {
                // Collect object IDs
                NSMutableArray *mutObjectIds = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
                for (NSManagedObject *obj in fetchedObjects) {
                    [mutObjectIds addObject:obj.objectID];
                }
                
                // Fault in objects into current context by object ID as they are available in the shared persistent store
                NSMutableArray *mutObjects = [[NSMutableArray alloc] initWithCapacity:[mutObjectIds count]];
                for (NSManagedObjectID *objectID in mutObjectIds)
                {
                    NSManagedObject *obj = [self objectWithID:objectID];
                    [mutObjects addObject:obj];
                }
                
                if (completion) {
                    NSArray *objects = [mutObjects copy];
                    completion(objects, nil);
                }
                
            }
            else
            {
                if (completion) {
                    completion(nil, error);
                }
            }
        }];
        
    }];
    
}

@end
