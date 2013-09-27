//
//  ModelUtil.m
//  SMAddressBook
//
//  Created by sochae on 13. 9. 27..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "ModelUtil.h"

@implementation ModelUtil


+ (NSArray *)fetchManagedObjects:(NSString *)entityName predicate:(NSPredicate *)predicate sort:(NSArray *)sortDescriptors moc:(NSManagedObjectContext *)moc
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
	
	// Add a sort descriptor. Mandatory.
	[fetchRequest setSortDescriptors:sortDescriptors];
	fetchRequest.predicate = predicate;
	
	NSError *error;
	NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:&error];
	
	if (fetchResults == nil) {
		// Handle the error.
		NSLog(@"executeFetchRequest failed with error: %@", [error localizedDescription]);
	}
	
	return fetchResults;
}

+ (NSManagedObject *)fetchManagedObject:(NSString *)entityName predicate:(NSPredicate *)predicate sort:(NSArray *)sortDescriptors moc:(NSManagedObjectContext *)moc
{
	NSArray *fetchResults = [self fetchManagedObjects:entityName predicate:predicate sort:sortDescriptors moc:moc];
	
	NSManagedObject *managedObject = nil;
	
	if (fetchResults && [fetchResults count] > 0) {
		// Found record
		managedObject = [fetchResults objectAtIndex:0];
	}
	
	return managedObject;
}

@end
