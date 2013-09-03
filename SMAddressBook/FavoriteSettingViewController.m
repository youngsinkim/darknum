//
//  FavoriteSettingViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FavoriteSettingViewController.h"
#import "AppDelegate.h"
#import "Course.h"

@interface FavoriteSettingViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *classTableView;
@property (strong, nonatomic) NSMutableArray *courseClasses;

@end


@implementation FavoriteSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _courseClasses = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    self.view.backgroundColor = [UIColor whiteColor];
    
    // CoreData 컨텍스트 지정
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (self.managedObjectContext == nil)
    {
        self.managedObjectContext = [appDelegate managedObjectContext];
        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
    }
    
    // 즐겨찾기 화면 구성
    [self setupFavoriteSettingUI];
    
    // 과정별 기수 목록 DB에서 가져오기
    _courseClasses = [self loadDBCourseClasses];
    
    [self.classTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupFavoriteSettingUI
{
    // 과정 기수 목록 구성
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    
    _classTableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _classTableView.dataSource = self;
    _classTableView.delegate = self;
    
    [self.view addSubview:_classTableView];

}


#pragma mark - DB methods
/// 과정별 기수 목록 트리 구조로 구성

- (NSMutableArray *)loadDBCourseClasses
{
    // 0(EMBA), 1(GMBA), 2(SMBA)
    // 교수/교직원 - 교수, 교직원
    // EMBA     - 1기, 2기, 3기, ...
    // GMBA     - 1기, 2기, 3기, ...
    // SMBA     - 1기, 2기, 3기, ...

    NSError *error = nil;
    
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];

#if (0)
    NSPredicate *predicate = nil;
    switch (type)
    {
        case MemberTypeFaculty: // 교수는 해당 전공(major) 목록 가져오기
        {
            NSLog(@"info 정보 : %@", _info);
            NSString *majorValue = _info[@"major"];
            NSLog(@"교수 검색 전공 : %@", majorValue);
            entity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:self.managedObjectContext];
            predicate = [NSPredicate predicateWithFormat:@"(major.major == %@)", majorValue];
        }
            break;
            
        case MemberTypeStaff:   // 교직원은 전체 목록 가져오기
            //            predicate = [NSPredicate predicateWithFormat:@"(course == 'GMBA')"];
            break;
            
        case MemberTypeStudent: // 학생은 해당 기수(courseclasse) 목록 가져오기
        {
            NSString *class = _info[@"courseclass"];
            NSLog(@"학생 검색 기수 : %@", class);
            predicate = [NSPredicate predicateWithFormat:@"(courseclass == %@)", class];
        }
            break;
            
        default:
            break;
    }
    
    if (entity == nil) {
        return nil;
    }
    
    [fetchRequest setPredicate:predicate];
#endif
    [fetchRequest setEntity:entity];

    //    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    //    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
#if (0)
        // 즐겨찾기 목록 트리 구조로 변경
        NSMutableArray *courseArray = [[NSMutableArray alloc] initWithCapacity:4];
        
//        NSArray *beginMatch = [filteredArray filteredArrayUsingPredicate:
//                               [NSPredicate predicateWithFormat:
//                                @"self BEGINSWITH[cd] %@", searchText]];
        
        NSArray *Groups = [fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"courseclass != '' group by title"]];;
        NSLog(@" 기수 그룹 목록 : %d", [Groups count]);
        
        int n = 0;
        NSArray *filtered = [fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"courseclass == ''"]];;
        courseArray[n++] = @[filtered];
        NSLog(@" 교수 교직원 목록 : %d", [filtered count]);

        for (Course *course in Groups)
        {
            NSLog(@"검색할 그룹명 : %@", course.course);
            NSArray *filteredCourse = [fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"course == %@", course.course]];;
            courseArray[n++] = @[filteredCourse];
            NSLog(@" 교수 교직원 목록 : %d", [filteredCourse count]);
        }

        if ([courseArray count] > 0) {
            return courseArray;
        }
        return nil;
#endif
        return fetchedObjects;
    }
    return nil;

}


#pragma mark - UITableView DataSources
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ([_courseClasses count] > 0)? [_courseClasses count] : 1;   // 교수,교직 / EMBA / GMBA / SMBA;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if ([_courseClasses count] > 0)
//    {
//        return _courseClasses[section].count;
//    }
//    return 1;
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

    NSLog(@"%d / %d", indexPath.row / [_courseClasses count]);
    if ([_courseClasses count] > 0)
    {
//        Course *course = _courseClasses[indexPath.section][indexPath.row];
//        NSLog(@"셀 정보 : %@", course.title);
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
