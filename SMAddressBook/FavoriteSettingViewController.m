//
//  FavoriteSettingViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FavoriteSettingViewController.h"

@interface FavoriteSettingViewController ()

@property (strong, nonatomic) UITableView *classTableView;
@property (strong, nonatomic) NSMutableArray *courseClasses;

@end


@implementation FavoriteSettingViewController

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 과정 기수 목록 구성
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    
    _classTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height - 44.0f) style:UITableViewStyleGrouped];
    _classTableView.dataSource = self;
    _classTableView.delegate = self;
    
    [self.view addSubview:_classTableView];
    
    //
    _courseClasses = [@[] mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSources
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;   // 교수,교직 / EMBA / GMBA / SMBA;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CourseClassCell";
    UITableViewCell *cell = [self.classTableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        UIView *myBackgroundView = [[UIView alloc] init];
        myBackgroundView.frame = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);// cell.frame;
        myBackgroundView.backgroundColor = [UIColor greenColor];
        
        [cell.backgroundView addSubview:myBackgroundView];
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    
//    if ([_contacts count] > 0)
    {
        // 주소록 셀 정보
//        NSDictionary *cellInfo = [_contacts objectAtIndex:indexPath.row];
//        NSLog(@"즐겨찾기 셀(%d) : %@", indexPath.row, [cellInfo description]);

//        cell.textLabel.text = cellInfo[@"emba 1기"];
//        cell.cellInfo = cellInfo;
        
        cell.textLabel.text = [NSString stringWithFormat:@"%d기", arc4random()%10];
    }
    
    return cell;

}

@end
