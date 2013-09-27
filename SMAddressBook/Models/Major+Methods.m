//
//  Major+Methods.m
//  SMAddressBook
//
//  Created by sochae on 13. 9. 27..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "Major+Methods.h"
#import "ModelUtil.h"

@implementation Major (Methods)

static NSString *entityName = @"Major";


+ (Major *)insertMajor:(NSString *)major title:(NSString *)title managedObjectContext:(NSManagedObjectContext *)moc
{
    Major *mo = (Major *)[NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                 inManagedObjectContext:moc];
    mo.major    = major;
    mo.title    = title;
    
    return mo;
}

+ (Major *)major:(NSString *)major managedObjectContext:(NSManagedObjectContext *)moc
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"major == %@", major];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    
    Major *mo = (Major *)[ModelUtil fetchManagedObject:entityName predicate:predicate sort:sortDescriptors moc:moc];
    
    return mo;
}

@end
