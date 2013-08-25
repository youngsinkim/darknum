//
//  TermsViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 24..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "AppDelegate.h"
#import "TermsViewController.h"

@interface TermsViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIButton *acceptBtn;
@end

@implementation TermsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = NSLocalizedString(@"terms_text", @"이용약관동의");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self setupTermsViewUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTermsViewUI
{
    // 배경 스크롤 뷰
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 300.0f, 396.0f)];
    _scrollView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    _scrollView.contentSize = CGSizeMake(300.0f, 396.0f+200.0f);
    
    [self.view addSubview:_scrollView];
    
    
    // 약관 웹 뷰
    
    // 약관동의 버튼
    _acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _acceptBtn.frame = CGRectMake(0.0f, _scrollView.frame.size.height - 30.0f, 70.0f, 30.0f);
    _acceptBtn.center = CGPointMake(300.0f / 2, 566.0f);
    [_acceptBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:14] forState:UIControlStateNormal];
    [_acceptBtn setTitle:LocalizedString(@"accept_btn_text", @"동의함") forState:UIControlStateNormal];
    [_acceptBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _acceptBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _acceptBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_acceptBtn addTarget:self action:@selector(onAcceptBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [_scrollView addSubview:_acceptBtn];
    
}

#pragma mark - UI Control Callbacks

// 약과 동의 버튼
- (void)onAcceptBtnClicked
{
    if ([[UserContext shared] isExistProfile])
    {
        // 로그인 성공하면 즐겨찾기 화면으로 이동
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate showMainViewController:self animated:YES];
    }
    else
    {
        // 약관 동의 후, 최초 실행 시(프로필 설정한 적이 없으면) 프로필 설정 화면으로 이동
        
    }
}
@end
