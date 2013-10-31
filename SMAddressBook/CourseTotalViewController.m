//
//  CourseTotalViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "CourseTotalViewController.h"
#import "CourseClassCell.h"
#import "StudentAddressViewController.h"
//#import <HMSegmentedControl.h>
#import <PPiFlatSegmentedControl.h>
#import "Course.h"

@interface CourseTotalViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *totalTableView;
@property (strong, nonatomic) NSMutableArray *courses;          //< 과정 목록
//@property (strong, nonatomic) NSMutableArray *courseClasses;      // 
@property (strong, nonatomic) NSMutableArray *totalStudents;
@property (assign) NSInteger tabIndex;

@end

@implementation CourseTotalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = LocalizedString(@"total_view_text", "전체보기");
        
        _courses = [[NSMutableArray alloc] init];
        _tabIndex = 0;
//        _courseClasses = [[NSMutableArray alloc] init];
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
    
    // 전체 과정 목록을 db에서 가져온다. (group by)
//    [_courses setArray:[self loadDBCourses]];
    NSArray *tabs = [self loadDBCourses];
    NSLog(@"과정 개수 : %d", [tabs count]);
    
    for (NSMutableDictionary *courseInfo in tabs)
    {
        NSLog(@"Before 과정 정보 : %@", courseInfo);
    
        // 각 과정 그룹별 기수 목록 가져와서 트리 구성.
        NSArray *filterd = [self loadDBCourseClasses:courseInfo[@"course"]];

        if ([filterd count] > 0) {
//            NSDictionary *subItems = [NSDictionary dictionaryWithObject:filterd forKey:@"courseclass"];// @{@"courseclass":filterd};
//            [courseInfo addEntriesFromDictionary:subItems];//@{@"subItem":filterd}];
//            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:courseInfo];
//            [dict setObject:filterd forKey:@"courseclass"];
            
            [_courses addObject:filterd];
        }
    
        NSLog(@"After 과정 정보 : %@", _courses);
        // 0(EMBA), 1(GMBA), 2(SMBA)
//        [_totalStudents setArray:[self loadDBCourseClasses:[segmentIdx integerValue]]];
    }

    
    // 전체보기 화면 구성
    [self setupTotalCourseUI:tabs];
    
    // 과정별 기수 목록 DB에서 가져오기
    [self onSegmentChangedValue:0]; // 0(EMBA), 1(GMBA), 2(SMBA)
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTotalCourseUI:(NSArray *)tabs
{
    CGRect rect = self.view.frame;
    CGFloat yOffset = 0.0f;
    CGFloat yBottom = 0.0f;
    
    if (!IS_LESS_THEN_IOS7) {
        yOffset += 64.0f;
    }
    
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

    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in tabs)
    {
        NSDictionary *item = @{@"text":dict[@"course"]};
        [items addObject:item];
    }
    
    if ([items count] == 0) {
        return;
    }
    
    PPiFlatSegmentedControl *courseSegment = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, yOffset, rect.size.width, 30.0f)
                                                                                      items:items   //@[@{@"text":@"EMBA"},@{@"text":@"GMBA"},@{@"text":@"SNUMBA"}]
                                                                               iconPosition:IconPositionRight
                                                                          andSelectionBlock:^(NSUInteger segmentIndex) {
                                                                              NSLog(@"선택된 셀 : %d", segmentIndex);
                                                                              [self performSelector:@selector(onSegmentChangedValue:) withObject:[NSNumber numberWithInteger:segmentIndex]];
//                                                                              [self onSegmentChangedValue:segmentIndex];
                                                                          }];
    
    courseSegment.color = [UIColor colorWithRed:88.0f/255.0 green:88.0f/255.0 blue:88.0f/255.0 alpha:0.6];
//    courseSegment.color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    courseSegment.borderWidth = 0.5;
    courseSegment.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
    courseSegment.selectedColor = [UIColor colorWithRed:200.0f/255.0 green:200.0f/255.0 blue:200.0f/255.0 alpha:1];
    courseSegment.textAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13],
                               NSForegroundColorAttributeName:[UIColor grayColor]};
    courseSegment.selectedTextAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:13],
                                       NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.view addSubview:courseSegment];
    yOffset += 30.0f;
    
    if (IS_LESS_THEN_IOS7) {
        yBottom = 44.0f;
    }
    
    // 라인 (imsi)
//    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, rect.size.width, 1.0f)];
//    lineV.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4f];
//
//    [self.view addSubview:lineV];
    
    // 테이블 뷰
    _totalTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, yOffset, rect.size.width, rect.size.height - yOffset - yBottom) style:UITableViewStylePlain];
    _totalTableView.dataSource = self;
    _totalTableView.delegate = self;
//    _totalTableView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    _totalTableView.backgroundColor = [UIColor clearColor];
    if (!IS_LESS_THEN_IOS7) {
        UIEdgeInsets edges;
        edges.left = 0;
        _totalTableView.separatorInset = edges;
    }
    [self.view addSubview:_totalTableView];
    
}

#pragma mark - UI Control Callbacks
- (void)onSegmentChangedValue:(id)sender
{
    NSNumber *segmentIdx = (NSNumber *)sender;
    NSLog(@"선택된 셀 : %d", [segmentIdx integerValue]);
    
    // 세그먼트 탭에 따라 테이블 내용 업데이트.
    _tabIndex = [segmentIdx integerValue];
    
    NSLog(@"어떤 셀이지: %@", _courses[_tabIndex]);
    
    [_totalTableView reloadData];
}

#pragma mark - DB methods

// 전체 과정 목록 가져오기 (group by)
- (NSArray *)loadDBCourses
{
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // select
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // * (column)
    NSAttributeDescription *type = [entity.attributesByName objectForKey:@"course"];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:type, nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:type]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    // where
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(courseclass != '')"];
    [fetchRequest setPredicate:predicate];
    
    // order by (ZCOURSECLASS)
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    for (NSDictionary *info in fetchedObjects) {
        NSLog(@"title : %@", info);
    }
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
        return fetchedObjects;
    }
    return nil;
}

/// 과정별 기수 목록
- (NSArray *)loadDBCourseClasses:(NSString *)courseName//:(NSInteger)tabIndex
{
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
//    NSAttributeDescription *type = [entity.attributesByName objectForKey:@"course"];
//    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:type, nil]];
//    [fetchRequest setResultType:NSDictionaryResultType];
    
    // where
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(course == %@)", courseName];
    [fetchRequest setPredicate:predicate];
    
    // order by (ZCOURSECLASS)
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
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
    NSArray *courseClasses = _courses[_tabIndex];
    
    if (courseClasses) {
        return ([courseClasses count] > 0)? [courseClasses count] : 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = _courses[_tabIndex];
    if (list == nil) {
        return nil;
    }
    
    if ([list count] == 0)
    {
        static NSString *identifier = @"NoTotalStudentCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"TotalStudentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([list count] > 0)
    {
        // 주소록 셀 정보
        Course *course = [list objectAtIndex:indexPath.row];
        NSLog(@"즐겨찾기 셀(%d) : %@", indexPath.row, course.title);
        
        if ([[UserContext shared].language isEqualToString:kLMKorean]) {
            cell.textLabel.text = course.title;
        } else {
            cell.textLabel.text = course.title_en;
        }
//        cell.cellInfo = cellInfo;
    }
        
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = _courses[_tabIndex];
    if (list == nil) {
        return;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"선택한 셀 => (%i / %i)", indexPath.row, indexPath.section);
    
    Course *courseClass = list[indexPath.row];
    
    if (courseClass)
    {
        NSLog(@"선택된 셀 정보 : %@", courseClass);

        NSArray *keys = [[[courseClass entity] attributesByName] allKeys];
        NSDictionary *dict = [courseClass dictionaryWithValuesForKeys:keys];
        NSLog(@"셀 (기수) 정보 : %@", dict);
        
        StudentAddressViewController *studentAddressVC = [[StudentAddressViewController alloc] initWithInfo:dict];
    
        [self.navigationController pushViewController:studentAddressVC animated:YES];

    }
}

@end
