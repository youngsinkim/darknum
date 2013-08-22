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
    
    [self setupFavoriteUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)setupFavoriteUI
{
    // 하단 버튼 툴바
    FavoriteToolViewController *footerToolbar = [[FavoriteToolViewController alloc] init];
    footerToolbar.view.frame = CGRectMake(0.0f, 416.0f - 80.0f, 320.0f, 80.0f);
    
    [self addChildViewController:footerToolbar];
    [self.view addSubview:footerToolbar.view];
    [footerToolbar didMoveToParentViewController:self];
}

@end
