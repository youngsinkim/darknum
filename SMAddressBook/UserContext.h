//
//  UserContext.h
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserContext : NSObject

@property (assign, nonatomic) BOOL isAutoLogin;

+ (UserContext *)shared;

@end
