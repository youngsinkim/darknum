//
//  FavoriteToolViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 23..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FavoriteToolViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface FavoriteToolViewController ()

@property (strong, nonatomic) UIButton *favoriteSettBtn;
@property (strong, nonatomic) UIButton *totalStudentBtn;
@property (strong, nonatomic) UIButton *helpBtn;

@end


@implementation FavoriteToolViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setupFavoriteToolbarUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)didMoveToParentViewController:(UIViewController *)parent
{
    NSLog(@"SecondViewController did move to parent view controller");
    self.view.frame = CGRectMake(0, self.view.frame.size.height - 90, 320, 90);
//    self.view.backgroundColor = [UIColor grayColor];
}


- (void)setupFavoriteToolbarUI
{
    CGSize viewSize = self.view.frame.size;
//    NSLog(@"size (%f, %f)", viewSize.width, viewSize.height);
    
    // 배경 라인 박스
//    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(1.0f, 1.0f, 320.0f, viewSize.height)];
//    [bgView.layer setCornerRadius:2.0f];
//    [bgView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5f].CGColor];
//    [bgView.layer setBorderWidth:1.0f];
//    
//    [self.view addSubview:bgView];

    /// 툴바 버튼 설정
//    NSArray *btnArray =  @[@[], @[@"friset_btn_block",@"전체보기"], @[@"friset_btn_block",@"도움말"]];
//    CGPoint point = CGPointMake(20.0f, 0.0f);
//    NSInteger sizeCX = 70.0f;
//    NSInteger idx = 0;
    
    CGFloat xStart = 10.0f;
    CGFloat yOffset = 10.0f;

    _favoriteSettBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _favoriteSettBtn.frame = CGRectMake(xStart, yOffset, xStart+120.0f, 30.0f);
    [_favoriteSettBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"favorite_setting", @"즐겨찾기 설정")] forState:UIControlStateNormal];
    [_favoriteSettBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_favoriteSettBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
//    [_favoriteSettBtn setBackgroundColor:[UIColor blueColor]];
    [_favoriteSettBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_favoriteSettBtn setImage:[UIImage imageNamed:@"list_photo_on"] forState:UIControlStateNormal];
    [_favoriteSettBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_favoriteSettBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    [_favoriteSettBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
//    [_favoriteSettBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
    [_favoriteSettBtn addTarget:self action:@selector(onFavoriteSetBtnClicked:) forControlEvents:UIControlEventTouchDragInside];

    [self.view addSubview:_favoriteSettBtn];

//    _favoriteSettBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _favoriteSettBtn.frame = CGRectMake(5, 5, 100, 30);
////    [_favoriteSettBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:14] forState:UIControlStateNormal];
//    [_favoriteSettBtn setTitle:LocalizedString(@"favorite_setting", @"즐겨찾기 설정") forState:UIControlStateNormal];
//    [_favoriteSettBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    [_favoriteSettBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
//    _favoriteSettBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
//    _favoriteSettBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [_favoriteSettBtn addTarget:self action:@selector(onFavoriteSetBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
////    _favoriteSettBtn.userInteractionEnabled = YES;
//    
//    [self.view addSubview:_favoriteSettBtn];

}

#pragma mark - UI Control Events

/// 즐겨찾기 설정 버튼
- (void)onFavoriteSetBtnClicked:(id)sender
{
    
}
@end
