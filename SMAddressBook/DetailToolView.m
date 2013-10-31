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
        self.backgroundColor = UIColorFromRGB(0xFBFAF3);
        
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
    

//    CGFloat width =  300.0f / [buttonList count];
    CGFloat width =  300.0f / 4;
    CGPoint point = CGPointMake(10.0f, 10.0f);
    
    if (_memType != MemberTypeStudent) {
        width = 300.0f / 3;
        point = CGPointMake(10.0f, 10.0f);
    }
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
    _telBtn.frame = CGRectMake(point.x, point.y, 50.0f, 50.0f);
    
    [_telBtn setTitle:LocalizedString(@"Phone Call", @"전화") forState:UIControlStateNormal];
    [_telBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_telBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_telBtn setImage:[UIImage imageNamed:@"icon_send_"] forState:UIControlStateNormal];
    [_telBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    [_telBtn addTarget:self action:@selector(onBtnTag:) forControlEvents:UIControlEventTouchUpInside];
    [_telBtn centerImageAndTitle:1.0f];
    
    [self addSubview:_telBtn];
    point.x += width;
    
    
    // 문자 버튼
    if (_memType == MemberTypeStudent) {
        _smsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _smsBtn.tag = tag++;
        _smsBtn.frame = CGRectMake(point.x, point.y, 50.0f, 50.0f);
        
        [_smsBtn setTitle:LocalizedString(@"sms", @"문자") forState:UIControlStateNormal];
        [_smsBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_smsBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_smsBtn setImage:[UIImage imageNamed:@"icon_suggest"] forState:UIControlStateNormal];
        [_smsBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        
        [_smsBtn addTarget:self action:@selector(onBtnTag:) forControlEvents:UIControlEventTouchUpInside];
        [_smsBtn centerImageAndTitle:1.0f];
        
        [self addSubview:_smsBtn];
        point.x += width;
    }
    
    // 이메일 버튼
    _emailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _emailBtn.tag = tag++;
    _emailBtn.frame = CGRectMake(point.x, point.y, 50.0f, 50.0f);
    
    [_emailBtn setTitle:LocalizedString(@"email", @"이메일") forState:UIControlStateNormal];
    [_emailBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_emailBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_emailBtn setImage:[UIImage imageNamed:@"tag_@_icon"] forState:UIControlStateNormal];
    [_emailBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    [_emailBtn addTarget:self action:@selector(onBtnTag:) forControlEvents:UIControlEventTouchUpInside];
    [_emailBtn centerImageAndTitle:1.0f];
    
    [self addSubview:_emailBtn];
    point.x += width;
    
    
    // 저장 버튼
    _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveBtn.tag = tag++;
    _saveBtn.frame = CGRectMake(point.x, point.y, 50.0f, 50.0f);
    
    [_saveBtn setTitle:LocalizedString(@"save", @"저장") forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_saveBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_saveBtn setImage:[UIImage imageNamed:@"friend_search_contact_on"] forState:UIControlStateNormal];
    [_saveBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    [_saveBtn addTarget:self action:@selector(onBtnTag:) forControlEvents:UIControlEventTouchUpInside];
    [_saveBtn centerImageAndTitle:1.0f];
    
    [self addSubview:_saveBtn];
    point.x += width;
    
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
