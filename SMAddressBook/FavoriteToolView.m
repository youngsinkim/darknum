//
//  FavoriteToolView.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FavoriteToolView.h"
#import <QuartzCore/QuartzCore.h>

@interface FavoriteToolView ()

@property (strong, nonatomic) UIButton *favoriteSettBtn;
@property (strong, nonatomic) UIButton *totalStudentBtn;
@property (strong, nonatomic) UIButton *helpBtn;

@end

@implementation FavoriteToolView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColorFromRGB(0xFCFCFA);
        
        [self setupFavoriteToolbarUI];
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


- (void)setupFavoriteToolbarUI
{
    CGSize viewSize = self.frame.size;
    //    NSLog(@"size (%f, %f)", viewSize.width, viewSize.height);
    
    // 배경 라인 박스
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, 320.0f, viewSize.height)];
//    [bgView.layer setCornerRadius:2.0f];
    [bgView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3f].CGColor];
    [bgView.layer setBorderWidth:1.0f];

    [self addSubview:bgView];
    
    /// 툴바 버튼 설정
    //    NSArray *btnArray =  @[@[], @[@"friset_btn_block",@"전체보기"], @[@"friset_btn_block",@"도움말"]];
    //    CGPoint point = CGPointMake(20.0f, 0.0f);
    //    NSInteger sizeCX = 70.0f;
    //    NSInteger idx = 0;
    
    CGFloat xStart = 5.0f;
    CGFloat yOffset = 10.0f;
    
    // 즐겨찾기 설정
    _favoriteSettBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _favoriteSettBtn.frame = CGRectMake(xStart, yOffset, 100.0f, 30.0f);
    [_favoriteSettBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"Favorite Settings", @"즐겨찾기 설정")] forState:UIControlStateNormal];
    [_favoriteSettBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_favoriteSettBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [_favoriteSettBtn setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
    [_favoriteSettBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [_favoriteSettBtn setImage:[UIImage imageNamed:@"list_photo_on"] forState:UIControlStateNormal];
////    [_favoriteSettBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateDisabled];
//    [_favoriteSettBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    [_favoriteSettBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 2)];
//    [_favoriteSettBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    //    [_favoriteSettBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
    [_favoriteSettBtn addTarget:self action:@selector(onFavoriteSetBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [bgView addSubview:_favoriteSettBtn];
//    _favoriteSettBtn.enabled = NO;
    xStart += 105;
    
    
    // 전체보기
    _totalStudentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _totalStudentBtn.frame = CGRectMake(xStart, yOffset, 100.0f, 30.0f);
    [_totalStudentBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"Member List", @"전체 주소록")] forState:UIControlStateNormal];
    [_totalStudentBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_totalStudentBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [_totalStudentBtn setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
    [_totalStudentBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [_totalStudentBtn setImage:[UIImage imageNamed:@"list_photo_on"] forState:UIControlStateNormal];
//    [_totalStudentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    [_totalStudentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
//    [_totalStudentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
//    [_totalStudentBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
    [_totalStudentBtn addTarget:self action:@selector(onTotalStudentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [bgView addSubview:_totalStudentBtn];
    xStart += 105;

    
    // 도움말
    _helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _helpBtn.frame = CGRectMake(xStart, yOffset, 100.0f, 30.0f);
    [_helpBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"Help", @"도움말")] forState:UIControlStateNormal];
    [_helpBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_helpBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [_helpBtn setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
    [_helpBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [_helpBtn setImage:[UIImage imageNamed:@"list_photo_on"] forState:UIControlStateNormal];
//    [_helpBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    [_helpBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
//    [_helpBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    //    [_helpBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
    [_helpBtn addTarget:self action:@selector(onHelpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [bgView addSubview:_helpBtn];

}

#pragma mark - UI Control Events

/// 즐겨찾기 설정 버튼
- (void)onFavoriteSetBtnClicked:(id)sender
{
    if ([_delegate respondsToSelector:@selector(onFavoriteSettBtnTouched:)]) {
        [_delegate onFavoriteSettBtnTouched:sender];
    }
}

/// 전체보기 버튼
- (void)onTotalStudentBtnClicked:(id)sender
{
    if ([_delegate respondsToSelector:@selector(onTotalStudentBtnTouched:)]) {
        [_delegate onTotalStudentBtnTouched:sender];
    }
}

/// 도움말 버튼
- (void)onHelpBtnClicked:(id)sender
{
    if ([_delegate respondsToSelector:@selector(onHelpBtnTouched:)]) {
        [_delegate onHelpBtnTouched:sender];
    }
}

@end
