//
//  HelpViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@property (strong, nonatomic) UIWebView *helpWebView;

@end

@implementation HelpViewController

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
    self.navigationItem.title = LocalizedString(@"help", "도움말");
    
//    self.view.backgroundColor = [UIColor yellowColor];
    CGRect viewRect = self.view.bounds;
    
    if (IS_LESS_THEN_IOS7) {
        viewRect.size.height -= 44.0f;
    }

    _helpWebView = [[UIWebView alloc] initWithFrame:viewRect];
//    _webView2.scrollView.contentInset = UIEdgeInsetsMake(-yOffset, 0, 0, 0);
    _helpWebView.backgroundColor = [UIColor clearColor];
    
    NSString *Url = @"https://biz.snu.ac.kr/fb/user-guide?lang=";
    if (![[UserContext shared].language isEqualToString:kLMKorean]) {
        Url = [Url stringByAppendingString:kLMEnglish];
    } else {
        Url = [Url stringByAppendingString:kLMKorean];
    }
    NSLog(@"도움말 : %@", Url);

    NSURLRequest *helpUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:Url]];
    [_helpWebView loadRequest:helpUrl];

//    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:Url]];
//    [_helpWebView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
    
    [self.view addSubview:_helpWebView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
