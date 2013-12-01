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
    
    self.backgroundColor = [UIColor colorWithRed:59.0f/255.0f green:76.0f/255.0f blue:122.0f/255.0f alpha:0.9f];
    
    
    // 툴 버튼
    NSInteger tag = 300;
    NSArray *buttonList = [NSArray arrayWithObjects:
                           [NSArray arrayWithObjects:@"ic_fn_sms", @"ic_fn_sms_press", @"ic_fn_sms_disable", LocalizedString(@"sms", @"문자"), nil],
                           [NSArray arrayWithObjects:@"ic_fn_mail", @"ic_fn_mail_press", @"ic_fn_mail_disable", LocalizedString(@"email", @"메일"), nil],
//                           [NSArray arrayWithObjects:@"recommend_icon_adress", @"recommend_icon_adress", nil],
                           nil];
    
    CGFloat xOffset = (viewSize.width - (64.0f * [buttonList count])) / 2;
    
    for (NSArray *buttons in buttonList)
    {
        UIButton *toolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        toolBtn.tag = tag++;
        toolBtn.frame = CGRectMake(xOffset, 3.0f, 64.0f, kStudentToolH);
        
        NSString *normalImage = [NSString stringWithFormat:@"%@", [buttons objectAtIndex:0]];
        NSString *pressedImage = [NSString stringWithFormat:@"%@", [buttons objectAtIndex:1]];
        NSString *selectedImage = [NSString stringWithFormat:@"%@", [buttons objectAtIndex:2]];
        
        //taggingButton.center = CGPointMake(point.x, point.y);
        [toolBtn setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
        [toolBtn setImage:[UIImage imageNamed:pressedImage] forState:UIControlStateHighlighted];
        [toolBtn setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateDisabled];
        
        [toolBtn setTitle:buttons[3] forState:UIControlStateNormal];
        [toolBtn setTitleColor:UIColorFromRGB(0xeeeeee) forState:UIControlStateNormal];
        [toolBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
        [toolBtn setTitleColor:UIColorFromRGB(0xaaaaaa) forState:UIControlStateDisabled];
        [toolBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [toolBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];

        [toolBtn addTarget:self action:@selector(onBtnTag:) forControlEvents:UIControlEventTouchUpInside];
        [toolBtn centerImageAndTitle:2.0f];
        
        [self addSubview:toolBtn];
        
        xOffset += 64.0f;
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
