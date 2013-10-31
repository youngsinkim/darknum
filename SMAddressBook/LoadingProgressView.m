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
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSTimer *timer;
@property (assign) CGFloat currentPos;



@end

@implementation LoadingProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.timer = nil;
        self.progress = 0.0f;
        self.maxValue = 0;
        self.curValue = 0;
        
        // 배경 (dimmed) 뷰
        _bgView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _bgView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];

        [self addSubview:_bgView];
        
        
        // 박스 뷰
        _boxView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 140.0f)];
        _boxView.center = CGPointMake(_bgView.frame.size.width / 2, _bgView.frame.size.height / 2);
        _boxView.backgroundColor = [UIColor whiteColor];
        
        [_bgView addSubview:_boxView];
//        _boxView.hidden = YES;
        
        CGRect boxFrame = _boxView.frame;
        CGFloat yOffset = 0.0f;

        // 타이틀
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, yOffset, boxFrame.size.width, 26.0f)];
        _titleLabel.backgroundColor = [UIColor blackColor];
        _titleLabel.textColor = [UIColor lightGrayColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = LocalizedString(@"update download title", @"업데이트 다운로드");
        
        [_boxView addSubview:_titleLabel];
        yOffset += 30.0f;
        

        // 메시지
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, yOffset, boxFrame.size.width - 20.0f, 60.0f)];
        _msgLabel.backgroundColor = [UIColor clearColor];
        _msgLabel.textColor = [UIColor darkGrayColor];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _msgLabel.font = [UIFont systemFontOfSize:12.0f];
        _msgLabel.numberOfLines = 4;
        _msgLabel.text = LocalizedString(@"update download msg", @"업데이트 메시지");
        
        [_boxView addSubview:_msgLabel];
        yOffset += 70.0f;

        // 프로그래스 바
        NSLog(@"%f, %f, %f, %f", boxFrame.origin.x, boxFrame.origin.y, boxFrame.size.width, boxFrame.size.height);
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame =  CGRectMake(20.0f, yOffset, 240.0f, 10.0f);
//        _progressView.center = CGPointMake(_bgView.frame.size.width / 2, _bgView.frame.size.height / 3);
        
        [_boxView addSubview:_progressView];
        yOffset += 10.0f;
       

        // 메시지
        _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, yOffset, boxFrame.size.width - 20.0f, 20.0f)];
        _percentLabel.backgroundColor = [UIColor clearColor];
        _percentLabel.textColor = [UIColor darkGrayColor];
        _percentLabel.textAlignment = NSTextAlignmentCenter;
        _percentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _percentLabel.font = [UIFont systemFontOfSize:12.0f];
//        _percentLabel.text = @"Downloading (0 / 0)";
        
        [_boxView addSubview:_percentLabel];
        
        
        
//        _hud = [[MBProgressHUD alloc] initWithView:self];
//        _hud.tag = 777777;
//        _hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
////        _hud.backgroundColor = [UIColor yellowColor];
//        _hud.color = [UIColor whiteColor];
//
//        [_boxView addSubview:_hud];
//        [_hud hide:YES];

        self.hidden = YES;
//        self.userInteractionEnabled = YES;

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
//
//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    CGRect boxFrame = _boxView.frame;
//    CGFloat yOffset = 0.0f;
//
//    yOffset += 30.0f;
//    _msgLabel.frame = CGRectMake(10.0f, yOffset, boxFrame.size.width - 20.0f, 60.0f);
//    yOffset += 70.0f;
//    _progressView.frame =  CGRectMake(20.0f, yOffset, 240.0f, 10.0f);
//
//    yOffset += 10.0f;
//    _percentLabel.frame = CGRectMake(10.0f, yOffset, boxFrame.size.width - 20.0f, 20.0f);
//}
//
- (void)setPercent:(NSString *)percent
{
    _percent = percent;
    _percentLabel.text = _percent;
//    [self setNeedsDisplay];
}

- (void)start:(NSInteger)cur total:(NSInteger)tot
{
    _curValue = cur;
    _maxValue = tot;
//    _progressView.progress = 0;
    
    NSLog(@"loading progress start...... ( %d / %d )", _curValue, _maxValue);
    
////    [NSThread detachNewThreadSelector:@selector(workerProgress:) toTarget:self withObject:[NSNumber numberWithFloat:max]];
////    if ([_delegate respondsToSelector:@selector(myProgressTask:)]) {
////        [_delegate myProgressTask:info];
////        [NSThread detachNewThreadSelector:@selector(myProgressTask:) toTarget:_delegate withObject:self];
////    }
//    [self performSelectorInBackground:@selector(workerProgress:) withObject:[NSNumber numberWithFloat:max]];
//    self.hidden = NO;
//
//    return;
////    [NSThread detachNewThreadSelector:@selector(workerProgress:) toTarget:self withObject:info];
////    [self performSelectorInBackground:@selector(workerProgress:) withObject:info];
////    if (_hud != nil) {
////        [_hud showWhileExecuting:@selector(myProgressTask:) onTarget:self withObject:self animated:YES];
////        [_hud showAnimated:YES whileExecutingBlock:nil];
////        [_hud show:YES];
////    }

//    if (_timer == nil) {
//        NSLog(@"progress timer start...... (max : %f", max);
//
////    NSNumber *expired = @0.2f;
//    NSDictionary *info = @{@"expired":[NSNumber numberWithFloat:max]};
//    _currentPos = _progressView.progress;
//    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector: @selector(updateProgress:) userInfo:info repeats:YES];
//    }
    
    if (self.timer == nil) {
        if (_maxValue == 0) {
            NSLog(@"---------- progress max = 0 ----------");
        }
        
//        NSDictionary *userInfo = @{@"start":@"0.0", @"end":@"0.1"};
//        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(updateUI:) userInfo:userInfo repeats:YES];
    
        self.hidden = NO;
        _progressView.progress = 0;
    } else  {
        NSLog(@"---------- progress timer error !!! ----------");
    }
}

- (void)stop
{
    NSLog(@"프로그래스 stop");
    
//    if (self.myTimer != nil) {
//        _percentLabel.text = [NSString stringWithFormat:@"Download (%d / %d)", _curValue, _maxValue];
//        return;
//    }
    [UIView animateWithDuration:1.3f
                     animations:^{
//                         _currentPos = 1.0f;
//                         count = 10;
//                         NSLog(@"프로그래스 숨김 : %f", _currentPos);
                         _percentLabel.text = [NSString stringWithFormat:@"Download (%d / %d)", _maxValue, _maxValue];
                         _progressView.progress = 1.0f;
                     }
                     completion:^(BOOL finished) {

                         self.hidden = YES;
                         _progressView.progress = 10;
//                         _currentPos = 0;
                         
                         NSLog(@"프로그래스 숨김 완료");
                         
                     }];
}

- (void)setPos:(CGFloat)pos withValue:(NSInteger)value
{
    _curValue = value;
//    CGFloat position = (float)(((float)_curValue / (float)_maxValue) * 10.0f);
//    if (count < position)
//    {
//        count = position;
//    }
//    NSLog(@"===== progress set pos : %d", _curValue);
//    NSString *countStr = [NSString stringWithFormat:@"Download (%d / %d)", _curValue, _maxValue];
//    self.percentLabel.text = countStr;

//    if (_curValue <= _maxValue)
    {
//        count = _curValue;
//        self.progressView.progress = (float)pos / 10.0f;
//        float prevFloat = self.progressView.progress;
        
        [UIView animateWithDuration:1.0f
                         animations:^{
                             NSLog(@"+++++++++++++ animations");
                             self.progressView.progress = (float)pos / 10.0f;
                             if (pos == 10) {
                                 _percentLabel.text = [NSString stringWithFormat:@"Download (%d / %d)", _maxValue, _maxValue];
                             }
                         } completion:^(BOOL finished) {
                             NSLog(@"+++++++++++++ completion");
                             self.progressView.progress = (float)pos / 10.0f;
                             _percentLabel.text = [NSString stringWithFormat:@"Download (%d / %d)", _curValue, _maxValue];
                         }];
        
//        if (self.timer == nil)
//        {
//            NSString *start = [NSString stringWithFormat:@"%.1f", _progressView.progress];
//            NSNumber *end = [NSNumber numberWithFloat:pos];
//            NSDictionary *userInfo = @{@"start":start, @"end":end};
//            NSLog(@".......... 프로그래스 시작 값 : %@", userInfo);
//            
//            self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(updateUI:) userInfo:userInfo repeats:YES];
//        }
    }
    [self layoutSubviews];
}

static CGFloat count = 0.0f;

- (void)updateUI:(NSTimer *)timer
{
    NSDictionary *userInfo;
    CGFloat expired = 0.0f;
    
    if ([timer.userInfo isKindOfClass:[NSDictionary class]]) {
        userInfo = timer.userInfo;
        NSLog(@".......... 프로그래스 제한 값 : %@", userInfo);
        count = [userInfo[@"start"] floatValue];
        expired = [userInfo[@"end"] floatValue];
        if (expired > 10.0f) {
            expired = 10.0f;
        }
    }
//    dispatch_async(dispatch_get_main_queue(), ^{
    count++;

    if (count <= expired)
    {
        NSLog(@"(%f/%f) 프로그래스 설정 값 = %d / %d", count, expired, _curValue, _maxValue);
//        self.percentLabel.text = [NSString stringWithFormat:@"Download %d %%",count*10];
        NSInteger cnt = (NSInteger)count;
        if (cnt >= _maxValue) {
            cnt = _maxValue;
        }
        self.percentLabel.text = [NSString stringWithFormat:@"Download (%d / %d)", _curValue, _maxValue];
        
        self.progressView.progress = (float)count / 10.0f;

        NSLog(@"프로그래스 값 : %f", self.progressView.progress);
//        NSLog(@"..... progress() .....");//, self.progressView.progress);
    }
    else
    {
        NSLog(@".......... 프로그래스 끝 : %f/%f", count, expired);
//        self.hidden = YES;
        [self.myTimer invalidate];
        self.myTimer = nil;

//        if (count == 10)
        {
//            NSLog(@"프로그래스 완료되어 종료 처리...");
            if ([_delegate respondsToSelector:@selector(myProgressTask:)]) {
                _percentLabel.text = [NSString stringWithFormat:@"Download (%d / %d)", _curValue, _maxValue];
                [_delegate myProgressTask:nil];
            }
        }
    }
//    });
}

- (void)workerBee
{
//    dispatch_queue_t myQueue = dispatch_queue_create("dbQueue", NULL);
//    dispatch_async(myQueue, ^{
    
//        @autoreleasepool
//        {
//            for (float i = 0; i < 1; i += 0.1)
//            {
//                //            dispatch_queue_t myQueue = dispatch_queue_create("dbQueue", NULL);
//                //            dispatch_async(myQueue, ^{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self updateProgress:[NSNumber numberWithFloat:i]];
//                    //                [self performSelectorInBackground:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:i]];
//                    
//                    //                dispatch_async(dispatch_get_main_queue(), ^{
//                    //                    [_progressView setNeedsDisplay];
//                    //                });
//                    usleep(10);
//                });
//            }
//        }
//    });
}
//
//- (void)updateProgress:(NSNumber*)number
//{
//    NSLog("Progress is now: %@", number);
//    [_progressView setProgress:[number floatValue]];
//}



- (void)workerProgress:(NSNumber *)number
{
    NSLog(@"work progress thread");
    if (_timer == nil)
    {
//        NSNumber *expired = @0.2f;
        NSDictionary *info = @{@"expired":number};

        _currentPos = _progressView.progress;
        NSLog(@"스케쥴 타이머 cur : %f, max : %f", _currentPos, [number floatValue]);
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateProgress:) userInfo:info repeats:YES];
    }
    
//
////    @autoreleasepool
//    {
//        float pos = 0.0f;
////        for (float i = 0; i<1; i+= 0.1)
//        while (pos < 1.0f)
//        {
//            [self performSelectorInBackground:@selector(updateProgress) withObject:[NSNumber numberWithFloat:pos]];
//            pos += 0.1f;
//            sleep(500);
//        }
//    }
}
//
//- (void)updateProgress:(NSTimer *)timer
//{
//    NSDictionary *dict = [timer userInfo];
//    CGFloat expired = [dict[@"expired"] floatValue];
//
//    _currentPos += 0.01;
//    NSLog("프로그래스 업데이트 ( %f / %f 까지 )", _currentPos, expired);
//    [self setProgress:_currentPos];
//
//    if (_currentPos >= expired) {
//        [self.timer invalidate];
//        self.timer = nil;
//    }
////    [progressView setProgress:[number floatValue]];
//}

- (void)updateProgress
{
    @autoreleasepool
    {
        _progressView.progress += 0.1f;
        [self setNeedsDisplay];
    }
}

- (void)setProgress:(CGFloat)progress
{
    NSLog(@"setProgress : %f", progress);

	if (progress > 1.0f)
		progress = 1.0f ;
	if (progress < 0.0f)
		progress = 0.0f ;
    
	_progressView.progress = progress;
    
	[self setNeedsDisplay];

}


- (void)onStart:(NSInteger)position withType:(ProgressType)type
{
    NSLog(@"---------- show progress ----------");
    if (type == ProgressTypeFavoriteSetting) {
        _titleLabel.text = LocalizedString(@"Favorite Setting Title", @"즐겨찾기 주소록 재설정");
        _msgLabel.text = LocalizedString(@"Favorite Setting Msg", @"즐겨찾기 설정 메시지");
    } else {
        _titleLabel.text = LocalizedString(@"update download title", @"업데이트 다운로드");
        _msgLabel.text = LocalizedString(@"update download msg", @"업데이트 메시지");
    }
    [self setHidden:NO];    // 프로그래스 노출
    _percentLabel.text = [NSString stringWithFormat:@"(Download 0 / %d)", position];
}

static float progCnt = 0.0f;
- (void)onProgress:(NSInteger)current total:(NSInteger)total
{
    if (current > 0 && total > 0)
    {
        if (current >= total) {
            current = total;
        }
        float position = (float)(current / total);
        NSLog(@"---------- onProgress ( %f ) ----------", position);
        
        if (position > 1.0f)
            position = 1.0f;
        if (position < 0.0f)
            position = 0.0f;
        
        if (position > progCnt) {
            progCnt = position;
        }
        _progressView.progress = progCnt;
        progCnt += 0.05;
        _percentLabel.text = [NSString stringWithFormat:@"(Download %d / %d)", current, total];
        
        [self setNeedsDisplay];
    }
}

- (void)onStop
{
    NSLog(@"---------- hide progress ----------");
    [self setHidden:YES];    // 프로그래스 숨기기
}

@end
