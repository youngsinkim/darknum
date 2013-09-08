//
//  FavoriteSettingViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FavoriteSettingViewController.h"
#import "Course.h"

@interface FavoriteSettingViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *fvSettTableView;
@property (strong, nonatomic) NSMutableArray *courses;
@property (strong, nonatomic) NSMutableArray *courseClasses;

@end


@implementation FavoriteSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"즐겨찾기 설정";
        
        _courses = [[NSMutableArray alloc] initWithCapacity:4];
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
    
    // DB 과정 목록
//    _courses = [@[@{@"course":@"교수진/교직원"}] mutableCopy];
//    NSArray *items = @[@{@"course":@"교수진/교직원"}, @{@"courseclass":@""}];
//    [_courses addObject:items];
//    [_courses addObjectsFromArray:[self loadDBCourses]];
    NSArray *tmpCourses = [self loadDBCourses];
    NSLog(@"과정 수: %@", tmpCourses);
    
    
    // 과정(섹션) 기수 목록 (교수/교직원 먼저 가져오고 나머지 과정별로 가져온다)
//    [_courseClasses addObject:[self loadDBStaticCourseClasses]];

    NSArray *tmpList = [self loadDBStaticCourseClasses];
    NSLog(@"고정 기수 목록 : %d", [tmpList count]);

    NSMutableArray *tmpClasses = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in tmpCourses)
    {
        NSLog(@"Before 과정 정보 : %@", dict);
        
        // 각 과정 그룹별 기수 목록 가져와서 트리 구성.
        NSArray *filterd = [self loadDBCourseClasses:dict[@"course"]];
        
        if ([filterd count] > 0) {
            //            NSDictionary *subItems = [NSDictionary dictionaryWithObject:filterd forKey:@"courseclass"];// @{@"courseclass":filterd};
            //            [courseInfo addEntriesFromDictionary:subItems];//@{@"subItem":filterd}];
            //            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:courseInfo];
            //            [dict setObject:filterd forKey:@"courseclass"];
            
            [tmpClasses addObject:filterd];
        }
        
        NSLog(@"After 과정 정보 : %@", _courseClasses);
    }
    
    _courses = [@[@{@"course":@"교수진/교직원"}] mutableCopy];
    [_courses addObjectsFromArray:tmpCourses];
    
    [_courseClasses setArray:@[tmpList]];
    [_courseClasses addObjectsFromArray:[tmpClasses mutableCopy]];


    NSLog(@"전체 기수 목록 : %d - %d", [_courses count], [_courseClasses count]);
    
    [_fvSettTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupFavoriteSettingUI
{
    // 과정 기수 목록 구성
    CGRect rect = self.view.bounds;
    rect.size.height -= 44.0f;
    
    _fvSettTableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    _fvSettTableView.dataSource = self;
    _fvSettTableView.delegate = self;
    
    [self.view addSubview:_fvSettTableView];

}


#pragma mark - FavoriteSettCell delegate

- (void)onFavoriteCheckTouched:(id)sender
{
    NSLog(@"즐겨찾기 체크 이벤트");
    if ([sender isKindOfClass:[FavoriteSettCell class]])
    {
        FavoriteSettCell *cell =  (FavoriteSettCell *)sender;
        NSIndexPath *indexPath = [_fvSettTableView indexPathForCell:cell];
    
        NSArray *list = _courseClasses[indexPath.section];
    
        NSLog(@"section(%d), row(%d) :\n%@", indexPath.section, indexPath.row, list);
        // 주소록 셀 정보
        Course *course = [list objectAtIndex:indexPath.row];
    
        // ( NSDictionary <- NSManagedObject )
        NSArray *keys = [[[course entity] attributesByName] allKeys];
        NSDictionary *info = [course dictionaryWithValuesForKeys:keys];

        NSLog(@"selected Data : %@", info);
    
//        NSString *tag = [NSString stringWithFormat:@"tag%d", [type intValue]];
//        NSString *postId = [threadData objectForKey:kDataPostId];
    }
}


#pragma mark - DB methods

/// 과정 DB 목록
- (NSArray *)loadDBCourses
{
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSAttributeDescription *course = [entity.attributesByName objectForKey:@"course"];
//    NSAttributeDescription *courseclass = [entity.attributesByName objectForKey:@"courseclass"];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:course, nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:course]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(courseclass != '')"];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    for (NSDictionary *info in fetchedObjects) {
        NSLog(@"fetchedObject : %@", info);
    }
    
    return fetchedObjects;
}

/// 과정별 기수 목록 (by type)
- (NSArray *)loadDBStaticCourseClasses
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(courseclass == '')"];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    for (Course *class in fetchedObjects) {
        NSLog(@"과정 정보 : %@", class.title);
    }
    
    return fetchedObjects;
}


/// 과정별 기수 목록 (by course)
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


/// 과정별 기수 목록 트리 구조로 구성
- (NSMutableArray *)loadDBCourseClasses1
{
    // 교수/교직원 - 교수, 교직원
    // EMBA     - 1기, 2기, 3기, ...
    // GMBA     - 1기, 2기, 3기, ...
    // SMBA     - 1기, 2기, 3기, ...

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
    
    NSError *error = nil;
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
    return ([_courses count] > 0)? [_courses count] : 1;   // 교수,교직 / EMBA / GMBA / SMBA;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = _courses[section][@"course"];
    NSLog(@"섹션 이름 : %@", sectionName);
    
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *courseClasses = _courseClasses[section];
//    NSLog(@"section : %@", courseClasses);
    
    if (courseClasses) {
        return ([courseClasses count] > 0)? [courseClasses count] : 1;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([_courses count] > 0)? FavoriteSettCellH : self.view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = _courseClasses[indexPath.section];
    if (list == nil) {
        return nil;
    }
    
    if ([list count] == 0)
    {
        static NSString *identifier = @"NoFvSettingCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"FvSettingCell";
    FavoriteSettCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[FavoriteSettCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.delegate = self;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([list count] > 0)
    {
        // 주소록 셀 정보
        Course *course = [list objectAtIndex:indexPath.row];
        
        // ( NSDictionary <- NSManagedObject )
        NSArray *keys = [[[course entity] attributesByName] allKeys];
        NSDictionary *info = [course dictionaryWithValuesForKeys:keys];
        NSLog(@"즐겨찾기 셀(%d) : %@", indexPath.row, info[@"favyn"]);
        
//        cell.textLabel.text = course.title;
        cell.classLabel.text = course.title;
        cell.cellInfo = info;
        
        if ([course.favyn isEqualToString:@"y"] || [course.type integerValue] > 1) {
            [cell setHidden:YES];
        } else {
            [cell setHidden:NO];
        }
    }
    
    return cell;
}

@end
