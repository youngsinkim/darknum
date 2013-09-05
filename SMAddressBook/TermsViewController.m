//
//  TermsViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 24..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "AppDelegate.h"
#import "TermsViewController.h"
#import "MenuTableViewController.h"
#import "MyInfoViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TermsViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIWebView *webView1;
@property (strong, nonatomic) UIWebView *webView2;
@property (strong, nonatomic) UIButton *acceptBtn1;
@property (strong, nonatomic) UIButton *acceptBtn2;
@property (strong, nonatomic) UIButton *nextBtn;
@end

@implementation TermsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = LocalizedString(@"terms_text", @"이용약관동의");
//        self.isHideAcceptBtn = NO;
        self.isByMenu = NO; 
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];

    NSLog(@"%@", self.navigationController.viewControllers);
    NSLog(@"modal : %d",     self.navigationController.modalInPopover);
    
//    if (self.navigationController.viewControllers[0] != self)
    if (self.isByMenu == NO)
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;      // 기본 네비게이션 back 버튼 노출되지 않도록 처리 
        self.navigationItem.rightBarButtonItem = nil;
    }

    [self setupTermsViewUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTermsViewUI
{
//    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    CGRect rect = self.view.bounds;
//    if ([[UIScreen mainScreen] bounds].size.height == 568)
    
    // 배경 스크롤 뷰
//    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height - 44.0f)];
//    _scrollView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
//    _scrollView.contentSize = CGSizeMake(300.0f, 396.0f+200.0f);
//    
//    [self.view addSubview:_scrollView];
    
    CGFloat sizeHeight = (rect.size.height - 44.0f - 160) / 2;
    CGFloat yOffset = 10.0f;
    
    // 서비스 약관
    _webView1 = [[UIWebView alloc] initWithFrame:CGRectMake(10.0f, yOffset, 300.0f, sizeHeight)];
    [[_webView1 layer] setCornerRadius:10];
    [_webView1 setClipsToBounds:YES];
    
    [[_webView1 layer]setBorderColor:[[UIColor colorWithRed:0.52 green:0.09 blue:0.07 alpha:1] CGColor]];
    [[_webView1 layer] setBorderWidth:2.75];
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"serviceTerms" ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfFile:htmlFile];
    [_webView1 loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
    
    [self.view addSubview:_webView1];
    yOffset += (sizeHeight + 5);
    
    
    // 서비스 약관동의 버튼
    _acceptBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    _acceptBtn1.frame = CGRectMake(10.0f, yOffset, 70.0f, 30.0f);
//    _acceptBtn1.center = CGPointMake(300.0f / 2, 566.0f);
    [_acceptBtn1 setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:14] forState:UIControlStateNormal];
    [_acceptBtn1 setTitle:LocalizedString(@"accept_btn_text", @"동의함") forState:UIControlStateNormal];
    [_acceptBtn1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _acceptBtn1.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _acceptBtn1.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_acceptBtn1 addTarget:self action:@selector(onAcceptBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_acceptBtn1];
    yOffset += (30.0f + 10);


    // 개인보호
    _webView2 = [[UIWebView alloc] initWithFrame:CGRectMake(10.0f, yOffset, 300.0f, sizeHeight)];
    [[_webView2 layer] setCornerRadius:10];
    [_webView2 setClipsToBounds:YES];
    
    [[_webView2 layer]setBorderColor:[[UIColor colorWithRed:0.52 green:0.09 blue:0.07 alpha:1] CGColor]];
    [[_webView2 layer] setBorderWidth:2.75];
    
    NSString *htmlFile2 = [[NSBundle mainBundle] pathForResource:@"personTerms" ofType:@"html"];
    NSData *htmlData2 = [NSData dataWithContentsOfFile:htmlFile2];
    [_webView2 loadData:htmlData2 MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
    
    [self.view addSubview:_webView2];
    yOffset += (sizeHeight + 5);
    
    
    // 개인보호 정책동의 버튼
    _acceptBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    _acceptBtn2.frame = CGRectMake(10.0f, yOffset, 70.0f, 30.0f);
//    _acceptBtn2.center = CGPointMake(300.0f / 2, 566.0f);
    [_acceptBtn2 setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:14] forState:UIControlStateNormal];
    [_acceptBtn2 setTitle:LocalizedString(@"accept_btn_text", @"동의함") forState:UIControlStateNormal];
    [_acceptBtn2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _acceptBtn2.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _acceptBtn2.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_acceptBtn2 addTarget:self action:@selector(onAcceptBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_acceptBtn2];
    yOffset += (30.0f + 10.0f);

    
    // 약관동의 버튼
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn.frame = CGRectMake((320 - 70) / 2, yOffset, 70.0f, 30.0f);
//    _nextBtn.center = CGPointMake(300.0f / 2, 566.0f);
    [_nextBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:14] forState:UIControlStateNormal];
    [_nextBtn setTitle:LocalizedString(@"accept_btn_text", @"동의함") forState:UIControlStateNormal];
    [_nextBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _nextBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _nextBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_nextBtn addTarget:self action:@selector(onAcceptBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_nextBtn];
    
}

#pragma mark - UI Control Callbacks

// 약관 동의 버튼
- (void)onAcceptBtnClicked
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // 약관 동의 설정값 저장
    [UserContext shared].isAcceptTerms = YES;
    
    // 약관 동의 화면 (fade out)감추기
    [UIView animateWithDuration:0.5f
                     animations:^{

                         self.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
//                         if (viewControllder) {
//                             [self.view removeFromSuperview];
//                         }
//                         self.window.rootViewController = [self sideMenuConrainer];
                         
                         [self dismissViewControllerAnimated:NO completion:nil];

                         if ([[UserContext shared] isExistProfile] == NO)
                         {
                             // 로그인 이후, 최초 프로필 설정이 안되어 있으면 프로필 화면으로 이동
                             MenuTableViewController *leftMenuViewController = (MenuTableViewController *)appDelegate.container.leftMenuViewController;
                             
                             [leftMenuViewController menuNavigationController:MenuViewTypeSettMyInfo];
                         }
                         
                     }];

    
    // sochae - 메뉴 구성 먼저 하고 로그인 화면 모달로 띄움, 약관 동의 후에 뷰 fade out 처리
    
//    if ([[UserContext shared] isExistProfile])
//    {
//        // 로그인 성공하면 즐겨찾기 화면으로 이동
//        [appDelegate showMainViewController:self animated:YES];
//    }
//    else
//    {
//        // 약관 동의 후, 최초 실행 시(프로필 설정한 적이 없으면) 프로필 설정 화면으로 이동
//        [appDelegate showMainViewController:self animated:NO];
//        
//    }
}

#pragma mark - ViewControllers

/// 메뉴를 통해 진입하는지에 따라 화면 네비게이션 또는 동의함 버튼 컨트롤 화면 표시 조절
- (void)setIsByMenu:(BOOL)isByMenu
{
    _isByMenu = isByMenu;
    [_nextBtn setHidden:YES];
}

- (void)hideAcceptBtn
{
    // 동의함 버튼 숨김은 메뉴에서 진입 시에 해당함.
    _nextBtn.hidden = YES;
    
    //
    // TODO: WebView 사이즈 조정
    
    [self.view setNeedsLayout];
}

@end
