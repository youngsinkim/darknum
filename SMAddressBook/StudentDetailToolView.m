//
//  StudentDetailToolView.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "StudentDetailToolView.h"

@interface StudentDetailToolView ()

@property (strong, nonatomic) UIButton *callBtn;
@property (strong, nonatomic) UIButton *smsBtn;
@property (strong, nonatomic) UIButton *emailBtn;
@property (strong, nonatomic) UIButton *saveBtn;
@property (strong, nonatomic) UIButton *kakaoBtn;

@end

@implementation StudentDetailToolView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setupStudentToolbarUI];
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


/// 툴바 UI
- (void)setupStudentToolbarUI
{
    CGSize viewSize = self.frame.size;
//    NSLog(@"size (%f, %f)", viewSize.width, viewSize.height);
    
    // 배경 라인 박스
//    UIView *bgView = [[UIView alloc] initWithFrame:self.frame];
    //    [bgView.layer setCornerRadius:2.0f];
//    [bgView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5f].CGColor];
//    [bgView.layer setBorderWidth:1.0f];
//
//    [self addSubview:bgView];
    
    /// 툴바 버튼 설정
    //    NSArray *btnArray =  @[@[], @[@"friset_btn_block",@"전체보기"], @[@"friset_btn_block",@"도움말"]];
    //    CGPoint point = CGPointMake(20.0f, 0.0f);
    //    NSInteger sizeCX = 70.0f;
    //    NSInteger idx = 0;
    
    CGFloat xStart = 5.0f;
    CGFloat yOffset = 10.0f;
    
    // 전화
    _callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _callBtn.frame = CGRectMake(xStart, yOffset, 110.0f, 30.0f);
    [_callBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"favorite_setting", @"즐겨찾기 설정")] forState:UIControlStateNormal];
    [_callBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_callBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
//    [_favoriteSettBtn setBackgroundColor:[UIColor blueColor]];
    [_callBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_callBtn setImage:[UIImage imageNamed:@"list_photo_on"] forState:UIControlStateNormal];
    [_callBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    [_favoriteSettBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
//    [_favoriteSettBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [_callBtn addTarget:self action:@selector(onFavoriteSetBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_callBtn];
    xStart += 125;
    
    
}

@end
