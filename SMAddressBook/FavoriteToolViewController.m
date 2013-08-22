//
//  FavoriteToolViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 23..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FavoriteToolViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface FavoriteToolViewController ()

@end

@implementation FavoriteToolViewController

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
    
    [self setupFavoriteToolbarUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupFavoriteToolbarUI
{
//    CGSize viewSize = self.view.frame.size;
//    NSLog(@"size (%f, %f)", viewSize.width, viewSize.height);
    
    // 배경 라인 박스
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(1.0f, 1.0f, 320.0f, 80 - 2.0f)];
    [bgView.layer setCornerRadius:2.0f];
    [bgView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5f].CGColor];
    [bgView.layer setBorderWidth:1.0f];
    
    [self.view addSubview:bgView];

}
@end
