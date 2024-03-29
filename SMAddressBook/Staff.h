//
//  Staff.h
//  SMAddressBook
//
//  Created by 선옥 채 on 2013. 12. 3..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Staff : NSManagedObject

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
@property (nonatomic, retain) NSString * work;
@property (nonatomic, retain) NSString * work_en;
@property (nonatomic, retain) NSString * hasapp;

@end
