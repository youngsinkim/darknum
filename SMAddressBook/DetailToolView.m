//
//  DetailToolView.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 13..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "DetailToolView.h"
#import "HorImageButton.h"
#import "UIButton+UIButtonExt.h"

@interface DetailToolView ()

//@property (strong, nonatomic) UIButton *telBtn;
//@property (strong, nonatomic) UIButton *smsBtn;
//@property (strong, nonatomic) UIButton *emailBtn;
//@property (strong, nonatomic) UIButton *saveBtn;
//@property (strong, nonatomic) UIButton *kakaoBtn;
@property (assign) MemberType memType;

@end


@implementation DetailToolView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _memType = MemberTypeUnknown;
        
        [self setupToolbarUI];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame type:(MemberType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _memType = type;

        self.backgroundColor = [UIColor colorWithRed:59.0f/255.0f green:76.0f/255.0f blue:122.0f/255.0f alpha:0.9f];

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
    
    MemberType myType = (MemberType)[[[UserContext shared] memberType] integerValue];
    
    NSInteger btnCount = 4;
    if (myType == MemberTypeStudent && _memType != MemberTypeStudent) {
        btnCount = 3;
    }

    CGFloat btnWidth = 64.0f;
    CGFloat yOffset = 3.0f;
    CGFloat xOffset = (viewSize.width - (btnWidth * btnCount)) / 2;
    
    // 툴 버튼
    NSInteger tag = 500;
//    NSArray *buttonList = nil;
//    if (_memType == MemberTypeStudent) {
//        buttonList = [NSArray arrayWithObjects:
//                           [NSArray arrayWithObjects:@"icon_send_", @"icon_send_", @"전화", nil],
//                           [NSArray arrayWithObjects:@"icon_suggest", @"icon_suggest", @"문자", nil],
//                           [NSArray arrayWithObjects:@"tag_@_icon", @"tag_@_icon", @"이메일", nil],
//                           [NSArray arrayWithObjects:@"friend_search_contact_on", @"friend_search_contact_on", @"저장", nil],
//                           [NSArray arrayWithObjects:@"btn_kakaotalk_logo_iphone", @"btn_kakaotalk_logo_iphone", @"카톡", nil],
//                           nil];
//    } else {
//        buttonList = [NSArray arrayWithObjects:
//                      [NSArray arrayWithObjects:@"icon_send_", @"icon_send_", @"전화", nil],
//                      [NSArray arrayWithObjects:@"tag_@_icon", @"tag_@_icon", @"이메일", nil],
//                      [NSArray arrayWithObjects:@"friend_search_contact_on", @"friend_search_contact_on", @"저장", nil],
//                      nil];
//    }
//    
//    for (NSArray *buttons in buttonList)
//    {
//        UIButton *toolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        toolBtn.tag = tag++;
//        toolBtn.frame = CGRectMake(point.x, point.y, 50.0f, 50.0f);
//        
//        NSString *normalImage = [NSString stringWithFormat:@"%@", [buttons objectAtIndex:0]];
//        UIImage *image = [UIImage imageNamed:normalImage];
////        NSString *pressedImage = [NSString stringWithFormat:@"%@", [postfix objectAtIndex:2]];
////        NSString *selectedImage = [NSString stringWithFormat:@"%@", [postfix objectAtIndex:3]];
//        
//        [toolBtn setImage:image forState:UIControlStateNormal];
//        [toolBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
////        [toolBtn setImageEdgeInsets:UIEdgeInsetsMake(0, image.size.width, image.size.height + 5, 0)];
////        [toolBtn setTitleEdgeInsets:UIEdgeInsetsMake(image.size.height, 0, 0, 0)];
//
//        [toolBtn setTitle:[buttons objectAtIndex:2] forState:UIControlStateNormal];
//        [toolBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [toolBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//        [toolBtn addTarget:self action:@selector(onBtnTag:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [self addSubview:toolBtn];
//        [toolBtn centerImageAndTitle:1.0f];
//
//        
//        point.x += width;
//    }
    
    // 전화 버튼
    _telBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _telBtn.tag = tag++;
    _telBtn.frame = CGRectMake(xOffset, yOffset, btnWidth, kDetailViewH);
    
    [_telBtn setTitle:LocalizedString(@"Phone Call", @"전화") forState:UIControlStateNormal];
    [_telBtn setTitleColor:UIColorFromRGB(0xeeeeee) forState:UIControlStateNormal];
    [_telBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
    [_telBtn setTitleColor:UIColorFromRGB(0xaaaaaa) forState:UIControlStateDisabled];
    [_telBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
    [_telBtn setImage:[UIImage imageNamed:@"ic_fn_phone"] forState:UIControlStateNormal];
    [_telBtn setImage:[UIImage imageNamed:@"ic_fn_phone_press"] forState:UIControlStateHighlighted];
    [_telBtn setImage:[UIImage imageNamed:@"ic_fn_phone_disable"] forState:UIControlStateDisabled];
    [_telBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    [_telBtn addTarget:self action:@selector(onBtnTag:) forControlEvents:UIControlEventTouchUpInside];
    [_telBtn centerImageAndTitle:1.0f];
    
    [self addSubview:_telBtn];
    xOffset += btnWidth;
    
    
    // 문자 버튼
//    if (_memType == MemberTypeStudent)
    if (!(myType == MemberTypeStudent && _memType != MemberTypeStudent))
    {
        _smsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _smsBtn.tag = tag++;
        _smsBtn.frame = CGRectMake(xOffset, yOffset, btnWidth, kDetailViewH);
        
        [_smsBtn setTitle:LocalizedString(@"sms", @"문자") forState:UIControlStateNormal];
        [_smsBtn setTitleColor:UIColorFromRGB(0xeeeeee) forState:UIControlStateNormal];
        [_smsBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
        [_smsBtn setTitleColor:UIColorFromRGB(0xaaaaaa) forState:UIControlStateDisabled];
        [_smsBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
        [_smsBtn setImage:[UIImage imageNamed:@"ic_fn_sms"] forState:UIControlStateNormal];
        [_smsBtn setImage:[UIImage imageNamed:@"ic_fn_sms_press"] forState:UIControlStateHighlighted];
        [_smsBtn setImage:[UIImage imageNamed:@"ic_fn_sms_disable"] forState:UIControlStateDisabled];
        [_smsBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        
        [_smsBtn addTarget:self action:@selector(onBtnTag:) forControlEvents:UIControlEventTouchUpInside];
        [_smsBtn centerImageAndTitle:1.0f];
        
        [self addSubview:_smsBtn];
        xOffset += btnWidth;
    }
    
    // 이메일 버튼
    _emailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _emailBtn.tag = tag++;
    _emailBtn.frame = CGRectMake(xOffset, yOffset, btnWidth, kDetailViewH);
    
    [_emailBtn setTitle:LocalizedString(@"email", @"이메일") forState:UIControlStateNormal];
    [_emailBtn setTitleColor:UIColorFromRGB(0xeeeeee) forState:UIControlStateNormal];
    [_emailBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
    [_emailBtn setTitleColor:UIColorFromRGB(0xaaaaaa) forState:UIControlStateDisabled];
    [_emailBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
    [_emailBtn setImage:[UIImage imageNamed:@"ic_fn_mail"] forState:UIControlStateNormal];
    [_emailBtn setImage:[UIImage imageNamed:@"ic_fn_mail_press"] forState:UIControlStateHighlighted];
    [_emailBtn setImage:[UIImage imageNamed:@"ic_fn_mail_disable"] forState:UIControlStateDisabled];
    [_emailBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    [_emailBtn addTarget:self action:@selector(onBtnTag:) forControlEvents:UIControlEventTouchUpInside];
    [_emailBtn centerImageAndTitle:1.0f];
    
    [self addSubview:_emailBtn];
    xOffset += btnWidth;
    
    
    // 저장 버튼
    _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveBtn.tag = tag++;
    _saveBtn.frame = CGRectMake(xOffset, yOffset, btnWidth, kDetailViewH);
    
    [_saveBtn setTitle:LocalizedString(@"save", @"저장") forState:UIControlStateNormal];
    [_saveBtn setTitleColor:UIColorFromRGB(0xeeeeee) forState:UIControlStateNormal];
    [_saveBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
    [_saveBtn setTitleColor:UIColorFromRGB(0xaaaaaa) forState:UIControlStateDisabled];
    [_saveBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
    [_saveBtn setImage:[UIImage imageNamed:@"ic_fn_save"] forState:UIControlStateNormal];
    [_saveBtn setImage:[UIImage imageNamed:@"ic_fn_save_press"] forState:UIControlStateHighlighted];
    [_saveBtn setImage:[UIImage imageNamed:@"ic_fn_save_disable"] forState:UIControlStateDisabled];
    [_saveBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    [_saveBtn addTarget:self action:@selector(onBtnTag:) forControlEvents:UIControlEventTouchUpInside];
    [_saveBtn centerImageAndTitle:1.0f];
    
    [self addSubview:_saveBtn];

    
// 기능 삭제
//    if (_memType == MemberTypeStudent) {
//        // 카톡 버튼
//        _kakaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _kakaoBtn.tag = tag++;
//        _kakaoBtn.frame = CGRectMake(point.x, point.y, 50.0f, 50.0f);
//        
//        [_kakaoBtn setTitle:LocalizedString(@"ka talk", @"카톡") forState:UIControlStateNormal];
//        [_kakaoBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [_kakaoBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//        [_kakaoBtn setImage:[UIImage imageNamed:@"btn_kakaotalk_logo_iphone"] forState:UIControlStateNormal];
//        [_kakaoBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
//        
//        [_kakaoBtn addTarget:self action:@selector(onBtnTag:) forControlEvents:UIControlEventTouchUpInside];
//        [_kakaoBtn centerImageAndTitle:1.0f];
//        
//        [self addSubview:_kakaoBtn];
//        point.x += width;
//    }
    
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
