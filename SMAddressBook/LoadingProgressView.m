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
@property (strong, nonatomic) UIView *boxView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *msgLabel;
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
        
        
        // 박스 뷰
        _boxView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 140.0f)];
        _boxView.center = CGPointMake(_bgView.frame.size.width / 2, _bgView.frame.size.height / 2);
        _boxView.backgroundColor = [UIColor whiteColor];
        
        [_bgView addSubview:_boxView];
        
        CGRect boxFrame = _boxView.frame;

        // 타이틀
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, boxFrame.size.width, 30.0f)];
        _titleLabel.backgroundColor = [UIColor blackColor];
        _titleLabel.textColor = [UIColor lightGrayColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"즐겨찾기 업데이트";
        
        [_boxView addSubview:_titleLabel];
        

        // 타이틀
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 35.0f, boxFrame.size.width - 20.0f, 50.0f)];
        _msgLabel.backgroundColor = [UIColor clearColor];
        _msgLabel.textColor = [UIColor darkGrayColor];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _msgLabel.numberOfLines = 2;
        _msgLabel.text = @"변경된 즐겨찾기 목록을 업데이트 받고 있습니다.";
        
        [_boxView addSubview:_msgLabel];

        
        // 프로그래스 바
        NSLog(@"%f, %f, %f, %f", boxFrame.origin.x, boxFrame.origin.y, boxFrame.size.width, boxFrame.size.height);
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame =  CGRectMake(20.0f, boxFrame.size.height - 30.0f, 240.0f, 40.0f);
//        _progressView.center = CGPointMake(_bgView.frame.size.width / 2, _bgView.frame.size.height / 3);
        
        [_boxView addSubview:_progressView];
        
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
