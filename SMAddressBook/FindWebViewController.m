//
//  FindWebViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 10. 8..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FindWebViewController.h"
#import "NSURLRequest+SSL.h"

@interface FindWebViewController ()

@property (strong, nonatomic) NSString *webPage;
@property (strong, nonatomic) UIWebView *webView;

@end

@implementation FindWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUrl:(NSString *)url title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.navigationItem.title = title;
        self.webPage = [NSString stringWithFormat:@"%@", url];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // 보내기 버튼
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0f, 0.0f, 49.0f, 30.0f);
    [button setTitle:LocalizedString(@"Done", @"닫기") forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x0080FF) forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [button addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButtonItem;

    
    // 웹 페이지 설정
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webView.delegate = self;
    _webView.backgroundColor = [UIColor clearColor];

    NSURLRequest *webUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:self.webPage]];
    [_webView loadRequest:webUrl];

    [self.view addSubview:_webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
