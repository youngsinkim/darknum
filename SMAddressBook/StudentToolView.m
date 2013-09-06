//
//  StudentToolView.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "StudentToolView.h"

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
    CGFloat xStart = 5.0f;
    CGFloat yOffset = 10.0f;
    
    // 문자 버튼
    _smsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _smsBtn.frame = CGRectMake(xStart, yOffset, 110.0f, 30.0f);
    [_smsBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"favorite_setting", @"즐겨찾기 설정")] forState:UIControlStateNormal];
    [_smsBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_smsBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
//    [_smsBtn setBackgroundColor:[UIColor blueColor]];
    [_smsBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_smsBtn setImage:[UIImage imageNamed:@"list_photo_on"] forState:UIControlStateNormal];
    [_smsBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_smsBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [_smsBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    //    [_smsBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
    [_smsBtn addTarget:self action:@selector(onSmsBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_smsBtn];
    xStart += 125;
}

#pragma mark - UI Control Events
- (void)onSmsBtnClicked:(id)sender
{
    if ([_delegate respondsToSelector:@selector(onTouchedSmsBtn:)]) {
        [_delegate onTouchedSmsBtn:sender];
    }
}
@end
