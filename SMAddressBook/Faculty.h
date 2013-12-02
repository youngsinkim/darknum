//
//  Faculty.h
//  SMAddressBook
//
//  Created by 선옥 채 on 2013. 12. 3..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Major;

@interface Faculty : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * memberidx;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * name_en;
@property (nonatomic, retain) NSString * office;
@property (nonatomic, retain) NSString * office_en;
@property (nonatomic, retain) NSString * photourl;
@property (nonatomic, retain) NSString * remove;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSString * viewphotourl;
@property (nonatomic, retain) NSString * hasapp;
@property (nonatomic, retain) Major *major;

@end
