//
//  CourseTotalViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "CourseTotalViewController.h"
#import "CourseClassCell.h"
#import "AppDelegate.h"
//#import <HMSegmentedControl.h>
#import <PPiFlatSegmentedControl.h>
#import "Course.h"

@interface CourseTotalViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *totalTableView;
@property (strong, nonatomic) NSMutableArray *totalStudents;

@end

@implementation CourseTotalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _totalStudents = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // CoreData 컨텍스트 지정
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (self.managedObjectContext == nil)
    {
        self.managedObjectContext = [appDelegate managedObjectContext];
        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
    }

    // 전체보기 화면 구성
    [self setupTotalCourseUI];
    
    // 과정별 기수 목록 DB에서 가져오기
    [self onSegmentChangedValue:0]; // 0(EMBA), 1(GMBA), 2(SMBA)
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTotalCourseUI
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    
    // 과정 탭 컨트롤
//    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"EMBA", @"GMBA", @"SMBA"]];
//    [segmentedControl setFrame:CGRectMake(0.0f, 4.0f, 320.0f, 40)];
//    [segmentedControl addTarget:self action:@selector(onSegmentChangedValue:) forControlEvents:UIControlEventValueChanged];
//    [segmentedControl setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5f]];
//    [segmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleBox];
//    [segmentedControl setSelectionLocation:HMSegmentedControlSelectionLocationDown];
//    [segmentedControl setSelectionIndicatorColor:[UIColor lightGrayColor]];
//
//    [self.view addSubview:segmentedControl];
    PPiFlatSegmentedControl *courseSegment = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 320, 30)
                                                                                      items:@[@{@"text":@"EMBA"},
                                                                                              @{@"text":@"GMBA"},
                                                                                              @{@"text":@"SNUMBA"}]
                                                                               iconPosition:IconPositionRight
                                                                          andSelectionBlock:^(NSUInteger segmentIndex) {
                                                                              NSLog(@"선택된 셀 : %d", segmentIndex);
                                                                              [self performSelector:@selector(onSegmentChangedValue:) withObject:[NSNumber numberWithInteger:segmentIndex]];
//                                                                              [self onSegmentChangedValue:segmentIndex];
                                                                          }];
    
//    courseSegment.color = [UIColor colorWithRed:88.0f/255.0 green:88.0f/255.0 blue:88.0f/255.0 alpha:1];
    courseSegment.color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    courseSegment.borderWidth = 0.5;
    courseSegment.borderColor = [UIColor lightGrayColor];
    courseSegment.selectedColor = [UIColor lightGrayColor];//[UIColor colorWithRed:0.0f/255.0 green:141.0f/255.0 blue:147.0f/255.0 alpha:1];
    courseSegment.textAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13],
                               NSForegroundColorAttributeName:[UIColor grayColor]};
    courseSegment.selectedTextAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:13],
                                       NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.view addSubview:courseSegment];
    
    
    // 라인 (imsi)
//    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, rect.size.width, 1.0f)];
//    lineV.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4f];
//
//    [self.view addSubview:lineV];
    
    // 테이블 뷰
    _totalTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 30.0f, rect.size.width, rect.size.height - 44.0f - 30.0f) style:UITableViewStylePlain];
    _totalTableView.dataSource = self;
    _totalTableView.delegate = self;
    _totalTableView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    
    [self.view addSubview:_totalTableView];
    
}

#pragma mark - UI Control Callbacks
- (void)onSegmentChangedValue:(id)sender
{
    NSNumber *segmentIdx = (NSNumber *)sender;
    NSLog(@"선택된 셀 : %d", [segmentIdx integerValue]);
    
    // 세그먼트 탭에 따라 테이블 내용 업데이트.
    // 0(EMBA), 1(GMBA), 2(SMBA)
    [_totalStudents setArray:[self loadDBCourseClasses:[segmentIdx integerValue]]];
    
    [_totalTableView reloadData];
}

#pragma mark - DB methods
/// 과정별 기수 목록
- (NSArray *)loadDBCourseClasses:(NSInteger)tabIndex
{
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // select
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // where
    NSPredicate *predicate = nil;
    switch (tabIndex)
    {
        case 0: // EMBA
            predicate = [NSPredicate predicateWithFormat:@"(course == 'EMBA')"];
            break;
            
        case 1: // GMBA
            predicate = [NSPredicate predicateWithFormat:@"(course == 'GMBA')"];
            break;
            
        case 2: // SMBA
            predicate = [NSPredicate predicateWithFormat:@"(course == 'SNUMBA')"];
            break;
            
        default:
            predicate = [NSPredicate predicateWithFormat:@"(course == 'EMBA')"];
            break;
    }
    [fetchRequest setPredicate:predicate];
    
    // order by (ZCOURSECLASS)
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    for (Course *class in fetchedObjects) {
        NSLog(@"title : %@", class.title);
    }
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
        return fetchedObjects;
    }
    return nil;
}

#pragma mark - UITableView DataSources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([_totalStudents count] > 0)? [_totalStudents count] : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_totalStudents count] == 0)
    {
        static NSString *identifier = @"NoTotalStudentCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"TotalStudentCell";
    UITableViewCell *cell = [self.totalTableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([_totalStudents count] > 0)
    {
        // 주소록 셀 정보
        Course *course = [_totalStudents objectAtIndex:indexPath.row];
        NSLog(@"즐겨찾기 셀(%d) : %@", indexPath.row, course.title);
        
        cell.textLabel.text = course.title;
//        cell.cellInfo = cellInfo;
    }
        
    return cell;
}

@end
