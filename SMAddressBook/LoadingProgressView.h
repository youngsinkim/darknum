//
//  LoadingProgressView.h
//  SMAddressBook
//
//  Created by sochae on 13. 9. 16..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingProgressView : UIView


//@property (nonatomic, retain) NSString *notificationString;
//@property (nonatomic, assign) BOOL showProgress;


//- (void)setBackgroundSize:(NSString *)message;
- (void)start;
- (void)stop;

@end
