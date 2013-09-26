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
        self.title = @"도움말";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    self.view.backgroundColor = [UIColor yellowColor];
    CGRect viewFrame = self.view.bounds;
//    viewFrame.origin.y += 64.0f;
    
    _helpWebView = [[UIWebView alloc] initWithFrame:viewFrame];
//    _webView2.scrollView.contentInset = UIEdgeInsetsMake(-yOffset, 0, 0, 0);
    _helpWebView.backgroundColor = [UIColor clearColor];
    
    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://biz.snu.ac.kr/fb/html/user-guide"]];
    [_helpWebView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
    
    [self.view addSubview:_helpWebView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
