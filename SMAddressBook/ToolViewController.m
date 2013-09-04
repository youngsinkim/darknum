//
//  ToolViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "ToolViewController.h"

@interface ToolViewController ()

@property (strong, nonatomic) UITableView *personTableView;
@property (strong, nonatomic) NSMutableArray *personList;

@end

@implementation ToolViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _personList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setupToolUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupToolUI
{
    CGRect rect = self.view.bounds; // CGRectMake(0.0f, 40.0f, 320.0f, self.view.bounds.size);
    
    _personTableView = [[UITableView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y + 36.0f, rect.size.width, rect.size.height - 44.0f - 36.0f - 40.0f)];
    _personTableView.dataSource = self;
    _personTableView.delegate = self;
    
    [self.view addSubview:_personTableView];
}

@end
