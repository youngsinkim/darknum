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
        self.navigationItem.title = LocalizedString(@"terms_text", @"이용약관동의");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];

    NSLog(@"%@", self.navigationController.viewControllers);
    if (self.navigationController.viewControllers[0] != self) {
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
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
//    if ([[UIScreen mainScreen] bounds].size.height == 568)
    
    // 배경 스크롤 뷰
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 300.0f, rect.size.height - 44.0f - 20.0f)];
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
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

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

                         MenuTableViewController *menuVC = (MenuTableViewController *)appDelegate.container.leftMenuViewController;
                         [menuVC showMyInfoViewController];
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
@end
