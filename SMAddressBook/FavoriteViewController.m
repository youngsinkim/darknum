//
//  FavoriteViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 23..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FavoriteViewController.h"
#import "FavoriteToolViewController.h"

@interface FavoriteViewController ()

@end

@implementation FavoriteViewController

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
    
    // 즐겨찾기 화면 구성
    [self setupFavoriteUI];
    
    // 과정 기수 목록 가져오기
    [self requestAPIClasses];
    
    // 기수 목록 중 즐겨찾기 목록 구성
    
    // 업데이트 목록 구성
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View mothods
- (void)setupFavoriteUI
{
    // 하단 버튼 툴바
    FavoriteToolViewController *footerToolbar = [[FavoriteToolViewController alloc] init];
    footerToolbar.view.frame = CGRectMake(0.0f, 416.0f - 80.0f, 320.0f, 80.0f);
    
    [self addChildViewController:footerToolbar];
    [self.view addSubview:footerToolbar.view];
    [footerToolbar didMoveToParentViewController:self];
}

#pragma mark - Network API
- (void)requestAPIClasses
{
    NSDictionary *param = @{@"scode":@"5684825a51beb9d2fa05e4675d91253c", @"phone":@"01023873856", @"updatedate":@"0000-00-00 00:00:00", @"userid":@"ztest01", @"passwd":@"1111#"};
    
    // 과정별 기수 목록
    [[SMNetworkClient sharedClient] postClasses:param
                                          block:^(NSMutableDictionary *result, NSError *error){
                                              if (error) {
                                                  [[SMNetworkClient sharedClient] showNetworkError:error];
                                              } else {
                                                  // 과정 기수 목록을 DB에 저장하고 tableView 업데이트
                                              }
                                          }];
}
@end
