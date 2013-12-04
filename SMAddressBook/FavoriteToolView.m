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
//        self.backgroundColor = UIColorFromRGB(0xFCFCFA);
        self.backgroundColor = [UIColor colorWithRed:173.0f/255.0f green:181.0f/255.0f blue:202.0f/255.0f alpha:0.9f];
        
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
    CGFloat yOffset = 10.0f;
    CGFloat xOffset = 10.0f;
    
    // 라인
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewSize.width, 1.0f)];
    line.backgroundColor = UIColorFromRGB(0x8f95a4);
    
    [self addSubview:line];
    
    
    // 즐겨찾기 설정
    UIImage *btnImage = [UIImage imageNamed:@"btn_darkgray"];
    _favoriteSettBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _favoriteSettBtn.frame = CGRectMake(xOffset, yOffset, btnImage.size.width, btnImage.size.height);
    [_favoriteSettBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"Favorite Settings", @"즐겨찾기 설정")] forState:UIControlStateNormal];
    [_favoriteSettBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [_favoriteSettBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
//    [_favoriteSettBtn setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
    [_favoriteSettBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_favoriteSettBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
    [_favoriteSettBtn addTarget:self action:@selector(onFavoriteSetBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_favoriteSettBtn];
//    _favoriteSettBtn.enabled = NO;
    
    
    // 전체보기
    _totalStudentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _totalStudentBtn.frame = CGRectMake(xOffset + btnImage.size.width + 3.0f, yOffset, btnImage.size.width, btnImage.size.height);
    [_totalStudentBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"Member List", @"전체 주소록")] forState:UIControlStateNormal];
    [_totalStudentBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [_totalStudentBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
    [_totalStudentBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_totalStudentBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
//    [_totalStudentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    [_totalStudentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
//    [_totalStudentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
//    [_totalStudentBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
    [_totalStudentBtn addTarget:self action:@selector(onTotalStudentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_totalStudentBtn];

    
    // 도움말
    _helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _helpBtn.frame = CGRectMake(xOffset + (btnImage.size.width + 3.0f) * 2, yOffset, btnImage.size.width, btnImage.size.height);
    [_helpBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"Help", @"도움말")] forState:UIControlStateNormal];
    [_helpBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [_helpBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
    [_helpBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_helpBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
    [_helpBtn addTarget:self action:@selector(onHelpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_helpBtn];

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
