//
//  StudentToolView.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "StudentToolView.h"
#import "UIButton+UIButtonExt.h"

@interface StudentToolView ()

@property (strong, nonatomic) UIButton *smsBtn;
@property (strong, nonatomic) UIButton *emailBtn;
@property (strong, nonatomic) UIButton *contactBtn;
@end

@implementation StudentToolView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColorFromRGB(0xFBFAF3);

        [self setupStudentToolUI];
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

- (void)setupStudentToolUI
{
    CGSize viewSize = self.frame.size;
    //    NSLog(@"size (%f, %f)", viewSize.width, viewSize.height);
    
    self.backgroundColor = [UIColor blueColor];
    
    // 배경 라인 박스
//    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, 320.0f, viewSize.height)];
//    [bgView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3f].CGColor];
//    [bgView.layer setBorderWidth:1.0f];
//    
//    [self addSubview:bgView];

    
    // 툴 버튼
    NSInteger tag = 300;
    NSArray *buttonList = [NSArray arrayWithObjects:
                           [NSArray arrayWithObjects:@"ic_fn_sms", @"ic_fn_sms", LocalizedString(@"sms", @"문자"), nil],
                           [NSArray arrayWithObjects:@"ic_fn_mail", @"ic_fn_mail", LocalizedString(@"email", @"메일"), nil],
//                           [NSArray arrayWithObjects:@"recommend_icon_adress", @"recommend_icon_adress", nil],
                           nil];
    
    CGFloat width = 300.0f / [buttonList count];
    CGPoint point = CGPointMake(100.0f, 10.0f);
    
    for (NSArray *buttons in buttonList)
    {
        UIButton *toolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        toolBtn.tag = tag++;
        toolBtn.frame = CGRectMake(point.x, point.y, 40.0f, 40.0f);
        
        NSString *normalImage = [NSString stringWithFormat:@"%@", [buttons objectAtIndex:0]];
        //        NSString *pressedImage = [NSString stringWithFormat:@"%@", [postfix objectAtIndex:2]];
        //        NSString *selectedImage = [NSString stringWithFormat:@"%@", [postfix objectAtIndex:3]];
        
        //taggingButton.center = CGPointMake(point.x, point.y);
        [toolBtn setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
        //            [taggingButton setImage:[UIImage imageNamed:pressedImage] forState:UIControlStateHighlighted];
        
//        [toolBtn setTitle:buttons[2] forState:UIControlStateNormal];
//        [toolBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [toolBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//        [toolBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];

        [toolBtn addTarget:self action:@selector(onBtnTag:) forControlEvents:UIControlEventTouchUpInside];
//        [toolBtn centerImageAndTitle:10.0f];
        
        [self addSubview:toolBtn];
        
        point.x += 80;
    }
//    CGFloat xStart = 5.0f;
//    CGFloat yOffset = 10.0f;
//    
//    // 문자 버튼
//    _smsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _smsBtn.frame = CGRectMake(xStart, yOffset, 110.0f, 30.0f);
//    [_smsBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"favorite_setting", @"즐겨찾기 설정")] forState:UIControlStateNormal];
//    [_smsBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    [_smsBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
////    [_smsBtn setBackgroundColor:[UIColor blueColor]];
//    [_smsBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [_smsBtn setImage:[UIImage imageNamed:@"list_photo_on"] forState:UIControlStateNormal];
//    [_smsBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    [_smsBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
//    [_smsBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
//    //    [_smsBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
//    [_smsBtn addTarget:self action:@selector(onSmsBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self addSubview:_smsBtn];
//    xStart += 125;
}

#pragma mark - UI Control Events

- (void)onBtnTag:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSLog(@"button tag : %i", btn.tag);
    
    NSInteger toolTag = btn.tag - 300;
    
    if ([_delegate respondsToSelector:@selector(didSelectedToolTag:)]) {
        [_delegate didSelectedToolTag:[NSNumber numberWithInt:toolTag]];
    }
}

- (void)onSmsBtnClicked:(id)sender
{
    if ([_delegate respondsToSelector:@selector(onTouchedSmsBtn:)]) {
        [_delegate onTouchedSmsBtn:sender];
    }
}
@end
