//
//  LoadingView.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 24..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView ()

@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;

@end

static LoadingView *_shared = nil;

@implementation LoadingView

+ (LoadingView *)shared
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _shared = [[LoadingView alloc] init];
    });
    
    return _shared;
}

//+ (id)alloc
//{
//	@synchronized([LoadingView class])
//	{
//        NSAssert(_shared == nil, @"Attempted to allocate a second instance of a singleton.");
//        _shared = [super alloc];
//        
//        return _shared;
//	}
//    
//	// to avoid compiler warning
//	return nil;
//}
//
//- (id)copyWithZone:(NSZone *)zone {
//    return self;
//}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
//        UIView *bgView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//        bgView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
//        bgView.userInteractionEnabled = YES;
//        
//        [self addSubview:bgView];
        
        // 로딩바
        self.loadingIndicator = [[UIActivityIndicatorView alloc] //initWithFrame:CGRectMake(100.0f, 200.0f, 30.0f, 30.0f)];
                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingIndicator.frame = self.bounds;
        _loadingIndicator.center = self.center;
//        [self.loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [self.loadingIndicator setHidesWhenStopped:YES];
        [self.loadingIndicator startAnimating];
        
        [self addSubview:self.loadingIndicator];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    // draw a box with rounded corners to fill the view -
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5.0f];
    [[UIColor colorWithWhite:0.8 alpha:0.5] setFill];
    [roundedRect fillWithBlendMode:kCGBlendModeNormal alpha:1];

}

- (void)start
{
    if (![_loadingIndicator isAnimating]) {
        [_loadingIndicator startAnimating];
    }
}

- (void)stop
{
    if ([_loadingIndicator isAnimating]) {
        [_loadingIndicator stopAnimating];
    }
}

@end
