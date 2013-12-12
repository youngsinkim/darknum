//
//  DetailGuideViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 2013. 10. 30..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "DetailGuideViewController.h"

@interface DetailGuideViewController ()

@property (strong, nonatomic) UIImageView *guideImageView;

@end

@implementation DetailGuideViewController

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
    
    _guideImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];

    if ([[UserContext shared].language isEqualToString:kLMKorean]) {
        _guideImageView.image = [UIImage imageNamed:@"img-ko-guide"];
    } else {
        _guideImageView.image = [UIImage imageNamed:@"img-en-guide"];
    }
//    if ([[UIScreen mainScreen] bounds].size.height < 568) {
//        _guideImageView.image = [UIImage imageNamed:@"Default"];
//    } else {
//        _guideImageView.image = [UIImage imageNamed:@"Default-568h"];
//    }

    [self.view addSubview:_guideImageView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kDetailGuide];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
