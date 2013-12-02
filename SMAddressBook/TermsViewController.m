//
//  TermsViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 24..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "TermsViewController.h"
#import "MenuTableViewController.h"
#import "MyInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSURLRequest+SSL.h"

#define kTermsUrl   @"https://biz.snu.ac.kr/fb/html/terms-of-use"
#define kPolicyUrl  @"https://biz.snu.ac.kr/fb/html/privacy-policy"

@interface TermsViewController ()

@property (strong, nonatomic) UIView *scrollView;
@property (strong, nonatomic) UILabel *termsTitleLabel;
@property (strong, nonatomic) UILabel *personalTitleLabel;
@property (strong, nonatomic) UIWebView *webView1;
@property (strong, nonatomic) UIWebView *webView2;
@property (strong, nonatomic) UIButton *acceptBtn1;
@property (strong, nonatomic) UIButton *acceptBtn2;
@property (strong, nonatomic) UIButton *nextBtn;
@property (assign) BOOL isFinished;
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
        self.isFinished = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSLog(@"%@", self.navigationController.viewControllers);
    NSLog(@"modal : %d", self.navigationController.modalInPopover);
//    if (!IS_LESS_THEN_IOS7) {
//        self.edgesForExtendedLayout = UIRectEdgeBottom;
//        self.navigationController.navigationBar.translucent = NO;
//    }

    [self setupTermsViewUI];
    
    [self performSelector:@selector(loadTermsWebView) withObject:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isByMenu)
    {
        _acceptBtn1.hidden = YES;
        _acceptBtn2.hidden = YES;
        _nextBtn.hidden = YES;
    }
    else
    {
        _acceptBtn1.hidden = NO;
        _acceptBtn2.hidden = NO;
        _nextBtn.hidden = NO;
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;      // 기본 네비게이션 back 버튼 노출되지 않도록 처리
        self.navigationItem.rightBarButtonItem = nil;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTermsViewUI
{
    CGRect rect = self.view.frame;
    
    // 배경 스크롤 뷰
//    _scrollView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, viewOffset, rect.size.width, rect.size.height - 44.0f)];
//    _scrollView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
//    _scrollView.backgroundColor = [UIColor yellowColor];
//    _scrollView.contentSize = CGSizeMake(rect.size.width, rect.size.height - 60.0f);

//    [self.view addSubview:_scrollView];
    
    CGFloat sizeHeight = 100.0f;
    CGFloat yOffset = 20.0f;
    CGFloat xOffset = 10.0f;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if (screenHeight > 480.0f) {
        sizeHeight = 142.0f;
    }
    
    // 이용약관 text
    _termsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, rect.size.width - (xOffset * 2.0f), 16.0f)];
    [_termsTitleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    _termsTitleLabel.textColor = UIColorFromRGB(0x142c6d);
    _termsTitleLabel.backgroundColor = [UIColor clearColor];
    _termsTitleLabel.text = LocalizedString(@"terms policy", @"이용 약과");

    [self.view addSubview:_termsTitleLabel];
    yOffset += (_termsTitleLabel.frame.size.height + 5.0f);

    // 서비스 약관
    _webView1 = [[UIWebView alloc] init];
    _webView1.frame = CGRectMake(xOffset, yOffset, rect.size.width - (xOffset * 2), sizeHeight);
    _webView1.delegate = self;
    [[_webView1 layer] setBorderColor:UIColorFromRGB(0xa7b5da).CGColor];
    [[_webView1 layer] setBorderWidth:1.0f];
//    _webView1.scrollView.contentInset = UIEdgeInsetsMake(-yOffset, 0, 0, 0);
//    _webView1.backgroundColor = [UIColor clearColor];
//    [[_webView1 layer] setCornerRadius:10];
//    [_webView1 setClipsToBounds:YES];

//    NSURLRequest *termsUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:kTermsUrl]];
//    [_webView1 loadRequest:termsUrl];
    
    [self.view addSubview:_webView1];
    yOffset += (sizeHeight + 5.0f);
    
    
    // 서비스 약관동의 버튼
    _acceptBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    _acceptBtn1.frame = CGRectMake(xOffset - 5.0f, yOffset, rect.size.width - (xOffset * 2), 20.0f);
    [_acceptBtn1 setTitle:LocalizedString(@"agree terms", @"약관 동의함") forState:UIControlStateNormal];
    [_acceptBtn1 setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
//    [_acceptBtn1 setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//    [_acceptBtn1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    [_acceptBtn1.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_acceptBtn1 setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    [_acceptBtn1 setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateSelected];
    [_acceptBtn1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_acceptBtn1 setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_acceptBtn1 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [_acceptBtn1 setTitleEdgeInsets:UIEdgeInsetsMake(2, 5, 0, 0)];
    [_acceptBtn1 setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [_acceptBtn1 addTarget:self action:@selector(onAcceptClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_acceptBtn1];
    yOffset += (_acceptBtn1.frame.size.height + 20.0f);


    // 개인정보보호방침 text
    _personalTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, rect.size.width - (xOffset * 2), 16.0f)];
    [_personalTitleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    _personalTitleLabel.textColor = UIColorFromRGB(0x142c6d);
    _personalTitleLabel.backgroundColor = [UIColor clearColor];
    _personalTitleLabel.text = LocalizedString(@"personal policy", @"개인정보보호방침");
    
    [self.view addSubview:_personalTitleLabel];
    yOffset += (_personalTitleLabel.frame.size.height + 5.0f);

    // 개인보호
    _webView2 = [[UIWebView alloc] init];
    _webView2.frame = CGRectMake(xOffset, yOffset, rect.size.width - (xOffset * 2), sizeHeight);
    _webView2.delegate = self;
    [[_webView2 layer] setBorderColor:UIColorFromRGB(0xa7b5da).CGColor];
    [[_webView2 layer] setBorderWidth:1.0f];
//    _webView2.scrollView.contentInset = UIEdgeInsetsMake(-yOffset, 0, 0, 0);
//    _webView2.backgroundColor = [UIColor clearColor];
//    [[_webView2 layer] setCornerRadius:10];
//    [_webView2 setClipsToBounds:YES];
    
//    NSURLRequest *policyUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:kPolicyUrl]];
//    [_webView2 loadRequest:policyUrl];

    [self.view addSubview:_webView2];
    yOffset += (sizeHeight + 5.0f);
    
    
    // 개인보호 정책동의 버튼
    _acceptBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    _acceptBtn2.frame = CGRectMake(xOffset - 5.0f, yOffset, rect.size.width - (xOffset * 2), 20.0f);
    [_acceptBtn2 setTitle:LocalizedString(@"agree personal", @"개인정책 동의함") forState:UIControlStateNormal];
    [_acceptBtn2 setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
//    [_acceptBtn2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
//    [_acceptBtn2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    [_acceptBtn2.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_acceptBtn2 setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    [_acceptBtn2 setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateSelected];
    [_acceptBtn2 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_acceptBtn2 setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_acceptBtn2 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [_acceptBtn2 setTitleEdgeInsets:UIEdgeInsetsMake(2, 5, 0, 0)];
    [_acceptBtn2 setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [_acceptBtn2 addTarget:self action:@selector(onAcceptClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_acceptBtn2];
    yOffset += (_acceptBtn2.frame.size.height + 20.0f);

    
    // 라인
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, rect.size.width - (xOffset * 2), 1.0f)];
    line.backgroundColor = UIColorFromRGB(0xbbbbbb);
    
    [self.view addSubview:line];
    yOffset += (line.frame.size.height + 20.0f);

    
    // 약관동의 버튼
    UIImage *btnImage = [UIImage imageNamed:@"btn_gray"];
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn.frame = CGRectMake(xOffset, yOffset, btnImage.size.width, btnImage.size.height);
    _nextBtn.center = CGPointMake(320.0f / 2, yOffset + btnImage.size.height / 2);
    [_nextBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
    [_nextBtn setTitle:LocalizedString(@"Agree", @"동의함") forState:UIControlStateNormal];
    [_nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_nextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    _nextBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    _nextBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_nextBtn addTarget:self action:@selector(onAcceptBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    _nextBtn.enabled = NO;
    
    [self.view addSubview:_nextBtn];
    
}

#pragma mark - UI Control Callbacks

- (void)onAcceptClicked:(id)sender
{
    [(UIButton *)sender setSelected:![(UIButton *)sender isSelected]];
    
    if (_acceptBtn1.selected && _acceptBtn2.selected) {
        _nextBtn.enabled = YES;
    } else {
        _nextBtn.enabled = NO;
    }
}

// 약관 동의 버튼
- (void)onAcceptBtnClicked
{
    if (_acceptBtn1.selected == NO || _acceptBtn2.selected == NO) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"모두 동의해 주셔야 서비스를 이용하실 수 있습니다."
                                                           delegate:self cancelButtonTitle:LocalizedString(@"Cancel", @"Cancel")
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // 약관 동의 설정값 저장
    [UserContext shared].isAcceptTerms = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAcceptTerms];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
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
                             
                             [leftMenuViewController menuNavigationController:MenuViewTypeSettMyInfo withMenuInfo:nil];
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

- (void)loadTermsWebView
{
    NSString *Url = @"https://biz.snu.ac.kr/fb/terms-of-use?lang=";
    if (![[UserContext shared].language isEqualToString:kLMKorean]) {
        Url = [Url stringByAppendingString:kLMEnglish];
    } else {
        Url = [Url stringByAppendingString:kLMKorean];
    }
    NSURLRequest *termsUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:Url]];
    [_webView1 loadRequest:termsUrl];
}

- (void)loadPolicyWebView
{
    NSString *Url = @"https://biz.snu.ac.kr/fb/privacy-policy?lang=";
    if (![[UserContext shared].language isEqualToString:kLMKorean]) {
        Url = [Url stringByAppendingString:kLMEnglish];
    } else {
        Url = [Url stringByAppendingString:kLMKorean];
    }
    NSURLRequest *policyUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:Url]];
    [_webView2 loadRequest:policyUrl];
}


- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Important to call super since we are subclassing UIWebView
    // Important so javascript scroll events fire
    // Even iOS 6 respondsToSelector, but crashes
    // if ([super respondsToSelector:@selector(scrollViewDidScroll:)]) {}
//    @try {
//        [super scrollViewDidScroll:scrollView];
//    }
//    @catch (NSException *exception) {
//        
//    }

}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestStr = [[request URL] absoluteString];
    NSLog(@"webView:shouldStartLoadWithRequest\nRequest : %@", requestStr);
    
//    if ([requestStr isEqualToString:@"https://biz.snu.ac.kr/fb/html/privacy-policy"]) {
    NSRange range = [requestStr rangeOfString:@"privacy-policy"];
    if (range.location != NSNotFound) {
        _isFinished = YES;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    if (!_isFinished) {
        [self performSelector:@selector(loadPolicyWebView) withObject:nil];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webView:didFailLoadWithError");
}

@end
