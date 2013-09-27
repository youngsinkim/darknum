//
//  LoadingProgressView.h
//  SMAddressBook
//
//  Created by sochae on 13. 9. 16..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoadingProgressView;
@protocol LoadingProgressViewDelegate <NSObject>

- (void)myProgressTask:(NSDictionary *)info;

@end


@interface LoadingProgressView : UIView

@property id<LoadingProgressViewDelegate> delegate;
@property (assign, nonatomic) CGFloat progress;
@property (assign, nonatomic) CGFloat pos;
@property (strong, nonatomic) NSString *percent;
//@property (nonatomic, retain) NSString *notificationString;
//@property (nonatomic, assign) BOOL showProgress;
@property (nonatomic, strong) NSTimer *myTimer;

//- (void)setBackgroundSize:(NSString *)message;
- (void)start;
- (void)stop;
//- (void)setProgress:(CGFloat)pos;

//- (void)setPos:(CGFloat)pos withIndex:(CGFloat)idx max:(CGFloat)max;
@end
