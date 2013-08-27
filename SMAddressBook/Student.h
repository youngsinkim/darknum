//
//  Student.h
//  SMAddressBook
//
//  Created by sochae on 13. 8. 27..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface Student : NSManagedObject

@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * company_en;
@property (nonatomic, retain) NSString * department;
@property (nonatomic, retain) NSString * department_en;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * name_en;
@property (nonatomic, retain) NSString * photourl;
@property (nonatomic, retain) NSNumber * remove;
@property (nonatomic, retain) NSNumber * share_company;
@property (nonatomic, retain) NSNumber * share_email;
@property (nonatomic, retain) NSNumber * share_mobile;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * status_en;
@property (nonatomic, retain) NSString * studcode;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * title_en;
@property (nonatomic, retain) Course *class_info;

@end
