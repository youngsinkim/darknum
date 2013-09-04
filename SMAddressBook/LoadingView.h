//
//  LoadingView.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 24..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView
{
    UIView *_backgroundView;
    UIProgressView *_progressView;
    UIActivityIndicatorView *_activityIndicatorView;
    
    UILabel *_notificationLabel;
    
    NSString *_notificationString;
    BOOL _showProgress;

}

@property (nonatomic, retain) NSString *notificationString;
@property (nonatomic, assign) BOOL showProgress;
@property (nonatomic, retain) UIProgressView *progressView;


- (void)setBackgroundSize:(NSString *)message;
- (void)show;
- (void)stop;

@end
