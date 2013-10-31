//
//  DetailInfoViewController.m
//  SMAddressBook
//
//  Created by sochae on 13. 9. 14..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "DetailInfoViewController.h"

@interface DetailInfoViewController ()

@property (assign) MemberType memType;

@end

@implementation DetailInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// 상세정보 생성 타입별 구분
- (id)initWithType:(MemberType)type
{
    self = [super init];
    if (self) {
        // Custom initialization
        if (!IS_LESS_THEN_IOS7) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        self.view.backgroundColor = [UIColor whiteColor];
        
        _memType = type;
        _contacts = [[NSMutableArray alloc] init];
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
