//
//  LoadingView.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 24..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_MESSAGE         @"Just a moment"
#define HEIGHT_OFFSET                  60.0f

@interface LoadingView ()

@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;

@end

static LoadingView *_shared = nil;

@implementation LoadingView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.hidden = YES;
        self.userInteractionEnabled = YES;
        
        _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _backgroundView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5f];
        _backgroundView.layer.cornerRadius = 6.0f;
        _backgroundView.layer.masksToBounds = YES;
        
        [self addSubview:_backgroundView];
        
        
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectZero;
        
        [_backgroundView addSubview:_progressView];
        
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicatorView.frame = CGRectZero;
        
        [_backgroundView addSubview:_activityIndicatorView];
        
        
        _notificationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _notificationLabel.backgroundColor = [UIColor clearColor];
        _notificationLabel.font = [UIFont fontWithName:@"Helverica" size:16.0f];
        _notificationLabel.textAlignment = NSTextAlignmentCenter;
        _notificationLabel.textColor = [UIColor whiteColor];
        _notificationLabel.text = DEFAULT_MESSAGE;
        
        [_backgroundView addSubview:_notificationLabel];
        
        
        [self setBackgroundSize:DEFAULT_MESSAGE];
        
        self.showProgress = NO;
    }
    return self;
}


- (void)setShowProgress:(BOOL)showProgress  {
    _showProgress = showProgress;
    
    [self setBackgroundSize:_notificationString];
    
    if (_showProgress) {
        
        if ([_activityIndicatorView isAnimating]) {
            [_activityIndicatorView stopAnimating];
        }
        
        _progressView.hidden = NO;
        _progressView.frame = CGRectMake(0.0f, 0.0f, 230.0f, 10.0f);
        _progressView.center = CGPointMake(_backgroundView.frame.size.width / 2, _backgroundView.frame.size.height / 3);
    }
    else {
        
        _progressView.hidden = YES;
        
        _activityIndicatorView.hidden = NO;
        _activityIndicatorView.frame = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
        _activityIndicatorView.center = CGPointMake(_backgroundView.frame.size.width / 2, _backgroundView.frame.size.height / 3);
        
        [_activityIndicatorView startAnimating];
    }
    
}


- (void)setBackgroundSize:(NSString *)message   {
    
    NSString *notification = (message == nil)? DEFAULT_MESSAGE : message;
    
    CGSize indicatorSize = [notification sizeWithFont:_notificationLabel.font constrainedToSize:self.frame.size];
    
    _notificationLabel.text = notification;
    
    CGFloat width = (_showProgress)? 280.0f : indicatorSize.width + 20.0f;
    
    _backgroundView.frame = CGRectMake(0.0f, 0.0f, width, 80.0);
    _backgroundView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - HEIGHT_OFFSET);
    
    _notificationLabel.frame = CGRectMake(0.0f, 0.0f, indicatorSize.width, indicatorSize.height);
    _notificationLabel.center = CGPointMake(_backgroundView.frame.size.width / 2, _backgroundView.frame.size.height / 2 + 20.0f);
    
    _activityIndicatorView.frame = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    _activityIndicatorView.center = CGPointMake(_backgroundView.frame.size.width / 2, _backgroundView.frame.size.height / 3);
    
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_backgroundView.bounds];
    [_backgroundView.layer setMasksToBounds:NO];
    [_backgroundView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [_backgroundView.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
    [_backgroundView.layer setShadowOpacity:0.5f];
    [_backgroundView.layer setShadowRadius:2.5f];
    [_backgroundView.layer setShadowPath:shadowPath.CGPath];
    
    _backgroundView.layer.shadowPath = [shadowPath CGPath];
}


- (void)setNotificationString:(NSString *)notificationString    {
    _notificationString = notificationString;
    
    [self setBackgroundSize:_notificationString];
}


- (void)show    {
    
    self.hidden = NO;
    
    if (![_activityIndicatorView isAnimating]) {
        [_activityIndicatorView startAnimating];
    }
    
    /* Animation */
    _backgroundView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    
    [UIView animateWithDuration:0.2f animations:^{
        
        _backgroundView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2f animations:^{
            
            _backgroundView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            
        } completion:^(BOOL finished) {
            
            
        }];
    }];
}


- (void)stop    {
    
    self.hidden = YES;
    
    if ([_activityIndicatorView isAnimating]) {
        [_activityIndicatorView stopAnimating];
    }
}


- (void)layoutSubviews  {
    [super layoutSubviews];
    
    
}

@end
