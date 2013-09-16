//
//  LoadingProgressView.m
//  SMAddressBook
//
//  Created by sochae on 13. 9. 16..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "LoadingProgressView.h"
#import <QuartzCore/QuartzCore.h>


@interface LoadingProgressView ()
{
    //    UIActivityIndicatorView *_activityIndicatorView;
    //    UILabel *_notificationLabel;
    //    NSString *_notificationString;
    //    BOOL _showProgress;
    
}

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation LoadingProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.hidden = YES;
        self.userInteractionEnabled = YES;
        
        // 배경 (dimmed) 뷰
        _bgView = [[UIView alloc] initWithFrame:self.bounds];
        _bgView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];

        [self addSubview:_bgView];
        
        
        // 프로그래스 바
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame =  CGRectMake(0.0f, 0.0f, 230.0f, 10.0f);
        _progressView.center = CGPointMake(_bgView.frame.size.width / 2, _bgView.frame.size.height / 3);
        
        [_bgView addSubview:_progressView];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)start
{
    self.hidden = NO;
}

- (void)stop
{
    self.hidden = YES;
}

@end
