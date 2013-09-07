//
//  SearchViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 7..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"검색";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setupSearchUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSearchUI
{
    CGRect rect = self.view.bounds;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 300.0f, 200.0f)];
    bgView.backgroundColor = UIColorFromRGB(0xFFEBD8);
    
    [self.view addSubview:bgView];
    
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setFrame:CGRectMake((rect.size.width - 100.0f) / 2.0f, 220.0f, 100.0f, 30.0f)];
    [searchBtn setBackgroundImage:[[UIImage imageNamed:@"btn_white"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f] forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [searchBtn setTitle:@"검색" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(onSearchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:searchBtn];
}

#pragma mark - UI Control Events

// 검색 버튼
- (void)onSearchBtnClicked:(id)sender
{
    SearchResultViewController *viewController = [[SearchResultViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
