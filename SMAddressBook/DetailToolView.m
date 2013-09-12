//
//  DetailToolView.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 13..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "DetailToolView.h"

@interface DetailToolView ()

@property (strong, nonatomic) UIButton *telBtn;
@property (strong, nonatomic) UIButton *smsBtn;
@property (strong, nonatomic) UIButton *emailBtn;
@property (strong, nonatomic) UIButton *kakaoBtn;
@property (strong, nonatomic) UIButton *addressBtn;

@end

@implementation DetailToolView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColorFromRGB(0xFBFAF3);
        
        [self setupToolbarUI];
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


- (void)setupToolbarUI
{
    CGSize viewSize = self.frame.size;
//    NSLog(@"size (%f, %f)", viewSize.width, viewSize.height);
    
    // 배경 라인 박스
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, 320.0f, viewSize.height)];
    [bgView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3f].CGColor];
    [bgView.layer setBorderWidth:1.0f];
    
    [self addSubview:bgView];
    
    
    // 툴 버튼
    NSInteger tag = 500;
    NSArray *buttonList = [NSArray arrayWithObjects:
                           [NSArray arrayWithObjects:@"recommend_icon_adress", @"recommend_icon_adress", nil],
                           [NSArray arrayWithObjects:@"recommend_icon_adress", @"recommend_icon_adress", nil],
                           [NSArray arrayWithObjects:@"recommend_icon_adress", @"recommend_icon_adress", nil],
                           [NSArray arrayWithObjects:@"recommend_icon_adress", @"recommend_icon_adress", nil],
                           [NSArray arrayWithObjects:@"recommend_icon_adress", @"recommend_icon_adress", nil],
                           nil];
    
    CGFloat width = 300.0f / [buttonList count];
    CGPoint point = CGPointMake(10.0f, 10.0f);
//    NSInteger idx = 0;
    
    for (NSArray *buttons in buttonList)
    {
        UIButton *toolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        toolBtn.tag = tag++;
        toolBtn.frame = CGRectMake(point.x, point.y, 50.0f, 50.0f);
        
        NSString *normalImage = [NSString stringWithFormat:@"%@", [buttons objectAtIndex:0]];
//        NSString *pressedImage = [NSString stringWithFormat:@"%@", [postfix objectAtIndex:2]];
//        NSString *selectedImage = [NSString stringWithFormat:@"%@", [postfix objectAtIndex:3]];
        
        //taggingButton.center = CGPointMake(point.x, point.y);
        [toolBtn setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
//            [taggingButton setImage:[UIImage imageNamed:pressedImage] forState:UIControlStateHighlighted];
//            [taggingButton setImage:[UIImage imageNamed:pressedImage] forState:UIControlStateSelected];
//        [toolBtn setImage:[[SnapStyleCommon getEmoTagImageArray:idx] objectAtIndex:0] forState:UIControlStateNormal];
//        [taggingButton setImage:[[SnapStyleCommon getEmoTagImageArray:idx] objectAtIndex:1] forState:UIControlStateHighlighted];
//        [taggingButton setImage:[[SnapStyleCommon getEmoTagImageArray:idx] objectAtIndex:1] forState:UIControlStateSelected];
        [toolBtn addTarget:self action:@selector(onBtnTag:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:toolBtn];
        
        point.x += width;
    }
    
}


#pragma mark - UIButton selector

- (void)onBtnTag:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSLog(@"button tag : %i", btn.tag);
    
    NSInteger toolTag = btn.tag - 500;
    
    if ([_delegate respondsToSelector:@selector(didSelectedToolTag:)]) {
        [_delegate didSelectedToolTag:[NSNumber numberWithInt:toolTag]];
    }
}

@end
