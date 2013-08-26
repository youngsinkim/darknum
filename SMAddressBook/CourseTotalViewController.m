//
//  CourseTotalViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "CourseTotalViewController.h"
#import "CourseClassCell.h"
#import <HMSegmentedControl.h>

@interface CourseTotalViewController ()

@property (strong, nonatomic) UITableView *courseTableView;

@end

@implementation CourseTotalViewController

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

    // 전체보기 화면 구성
    [self setupTotalCourseUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTotalCourseUI
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    
    // courese 탭
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"EMBA", @"GMBA", @"SMBA"]];
    [segmentedControl setFrame:CGRectMake(0.0f, 4.0f, 320.0f, 40)];
    [segmentedControl addTarget:self action:@selector(onSegmentChangedValue:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5f]];
    [segmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleBox];
    [segmentedControl setSelectionLocation:HMSegmentedControlSelectionLocationUp];
    [segmentedControl setSelectionIndicatorColor:[UIColor grayColor]];

    [self.view addSubview:segmentedControl];
    
    
    // 라인 (imsi)
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, rect.size.width, 1.0f)];
    lineV.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4f];

    [self.view addSubview:lineV];
    
    // 테이블 뷰
    _courseTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 45.0f, rect.size.width, rect.size.height - 44.0f - 44.0f) style:UITableViewStylePlain];
    _courseTableView.dataSource = self;
    _courseTableView.delegate = self;
    _courseTableView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    
    [self.view addSubview:_courseTableView];
    
}

#pragma mark - UI Control Callbacks
- (void)onSegmentChangedValue:(id)sender
{
    [self.courseTableView reloadData];
}

#pragma mark - UITableView DataSources
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CourseClassCell";
    CourseClassCell *cell = [self.courseTableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[CourseClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
//    if ([_contacts count] > 0)
    {
        // 주소록 셀 정보
//        NSDictionary *cellInfo = [_contacts objectAtIndex:indexPath.row];
//        NSLog(@"즐겨찾기 셀(%d) : %@", indexPath.row, [cellInfo description]);
        
//        cell.textLabel.text = cellInfo[@"emba 1기"];
//        cell.cellInfo = cellInfo;
        
        cell.textLabel.text = [NSString stringWithFormat:@"%d", arc4random()];
    }
    
    return cell;
}

@end
