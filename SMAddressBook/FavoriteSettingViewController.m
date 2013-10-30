//
//  FavoriteSettingViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FavoriteSettingViewController.h"
#import "Course.h"
#import "NSString+MD5.h"
#import "MenuTableViewController.h"
#import "LoadingProgressView.h"
#import "Student.h"

@interface FavoriteSettingViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *fvSettTableView;
@property (strong, nonatomic) NSMutableArray *courses;
@property (strong, nonatomic) NSMutableArray *courseClasses;
@property (strong, nonatomic) NSMutableArray *favoriteList; // courseClasses와 동일한 즐겨찾기 리스트

@property (strong, nonatomic) LoadingProgressView *progressView;
@property (assign) NSInteger tot;       // 전체 목록
@property (assign) NSInteger cur;       // DB 저장 count

@property (assign) BOOL isStudentSaveDone;    // 학생 업데이트 목록 DB 저장 여부
@property (strong, nonatomic) NSTimer *progressTimer;

@end


@implementation FavoriteSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = LocalizedString(@"favorite setting", @"즐겨찾기 설정");
        
        _courses = [[NSMutableArray alloc] initWithCapacity:4];
        _courseClasses = [[NSMutableArray alloc] initWithCapacity:4];
        _favoriteList = [[NSMutableArray alloc] initWithCapacity:4];
        
        _tot = 0;
        _cur = 0;
        _isStudentSaveDone = NO;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // CoreData 컨텍스트 지정
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (self.managedObjectContext == nil)
    {
        self.managedObjectContext = [appDelegate managedObjectContext];
        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
    }
    
    // 즐겨찾기 화면 구성
    [self setupFavoriteSettingUI];
    
    // 프로그래스바 구성
    [self initUpdateProgress];

    
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
    
    _courses = [@[@{@"course":LocalizedString(@"Favorite Static Course", @"교수진/교직원")}] mutableCopy];
    [_courses addObjectsFromArray:tmpCourses];
    
    [_courseClasses setArray:@[tmpList]];
    [_courseClasses addObjectsFromArray:[tmpClasses mutableCopy]];

    [_favoriteList setArray:_courseClasses];

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
    CGRect rect = self.view.frame;
    if (IS_LESS_THEN_IOS7) {
        rect.size.height -= 44.0f;
    }
    
    _fvSettTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height) style:UITableViewStyleGrouped];
    _fvSettTableView.dataSource = self;
    _fvSettTableView.delegate = self;
    
    [self.view addSubview:_fvSettTableView];

}

- (void)initUpdateProgress
{
    if (!_progressView)
    {
        _progressView = [[LoadingProgressView alloc] initWithFrame:self.view.bounds];
        _progressView.delegate = self;
        [[[UIApplication sharedApplication] keyWindow] addSubview:_progressView];
        //        [self.view addSubview:_progressView];
    }
}


#pragma mark 즐겨찾기 설정 메뉴 업데이트
- (void)updateFavoriteData
{
    // DB에서 저장된 즐겨찾기(CourseClass) 목록 불러오기
    NSArray *favorites = [self loadDBFavoriteCourse];
    
    if ([favorites count] > 0)
    {
        // 즐겨찾기 목록 메뉴 적용
        MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
        [menu setAddrMenuList:(NSMutableArray *)favorites];
    }
}

#pragma mark - FavoriteSettCell delegate

- (void)onFavoriteCheckTouched:(id)sender
{
    NSLog(@"즐겨찾기 체크 이벤트");

    if ([sender isKindOfClass:[FavoriteSettCell class]])
    {
        FavoriteSettCell *cell =  (FavoriteSettCell *)sender;
//        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [_fvSettTableView indexPathForCell:cell];
    
        NSArray *list = _favoriteList[indexPath.section];
    
        NSLog(@"section(%d), row(%d)", indexPath.section, indexPath.row);
        // 주소록 셀 정보
        Course *course = [list objectAtIndex:indexPath.row];
    
        // ( NSDictionary <- NSManagedObject )
        NSArray *keys = [[[course entity] attributesByName] allKeys];
        NSDictionary *info = [course dictionaryWithValuesForKeys:keys];

        NSLog(@"selected Data : %@", info);
        NSString *mode = @"";
        if ([course.favyn isEqualToString:@"y"]) {
            course.favyn = [NSString stringWithFormat:@"n"];
            mode = @"del";
        } else {
            course.favyn = [NSString stringWithFormat:@"y"];
            mode = @"add";
            
            // 1. 프로그래스 일단 노출
            NSLog(@".......... progressbar onStart ..........");
            [self.progressView onStart:[course.count integerValue] withType:ProgressTypeFavoriteSetting];

        }
        
        // 서버로 즐겨찾기 설정 저장
        NSString *mobileNo = [Util phoneNumber];
        NSString *userId = [UserContext shared].userId;
        NSString *certNo = [UserContext shared].certNo;
        NSString *lastUpdate = [UserContext shared].lastUpdateDate;
//        NSString *lang = [UserContext shared].language;
        
        if (!mobileNo || !userId | !certNo || !lastUpdate) {
            return;
        }
        NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo, @"mode":mode, @"courseclass":course.courseclass};

        [self requestAPIFavoritesUpdate:param updateMode:mode];
        
    
//        NSString *tag = [NSString stringWithFormat:@"tag%d", [type intValue]];
//        NSString *postId = [threadData objectForKey:kDataPostId];
    }
    [_fvSettTableView reloadData];
}


#pragma mark - Network API
// 즐겨찾기 추가 / 삭제
- (void)requestAPIFavoritesUpdate:(NSDictionary *)param updateMode:(NSString *)mode
{
    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
    
    // 즐겨찾기 업데이트 목록
    [[SMNetworkClient sharedClient] updateFavorites:param
                                              block:^(NSDictionary *result, NSError *error) {
                                                  NSLog(@"즐겨찾기 설정 결과 ? %@", result);
                                                
                                                  [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                                                
                                                  if (error)
                                                  {
                                                      // 서버 오류가 있는 경우 프로그래스바 종료.
                                                      [self stopRepeatingTimer];

                                                      [[SMNetworkClient sharedClient] showNetworkError:error];
                                                  }
                                                  else
                                                  {
                                                      // 즐겨찾기 추가인 경우, 성공하면 해당 기수의 목록 서버로 요청
                                                      NSString *updateMode = param[@"mode"];
                                                      NSString *courseClass = param[@"courseclass"];
                                                      NSLog(@"업데이트 성공 결과 (mode : %@), course : %@", updateMode, courseClass);
                                                      
                                                      if ([updateMode isEqualToString:@"add"]) {
                                                          [self requestAPIStudents:param];
//                                                          [self performSelector:@selector(requestAPIStudents:) withObject:param];
                                                      }
                                                      
                                                      // DB에서 저장된 즐겨찾기(CourseClass) 목록 불러오기
//                                                      [self performSelector:@selector(updateFavoriteData) withObject:nil];
                                                      
                                                      
//                                                      NSArray *favorites = [self loadDBFavoriteCourse];
//                                                      if ([favorites count] > 0)
//                                                      {
//                                                          // 즐겨찾기 목록 메뉴 적용
//                                                          MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
//                                                          [menu setAddrMenuList:favorites];
//                                                      }

                                                    
                                                    // 즐겨찾기 업데이트 수신 후, 현재 시간을 마지막 업데이트 시간으로 저장
//                                                    {
//                                                        NSDate *date = [NSDate date];
//                                                        NSString *displayString = [date string];
//                                                        NSLog(@"즐겨찾기 업데이트 시간? %@", displayString);
//                                                        
//                                                        [UserContext shared].lastUpdateDate = displayString;
//                                                        [[NSUserDefaults standardUserDefaults] setValue:displayString forKey:kLastUpdate];
//                                                        [[NSUserDefaults standardUserDefaults] synchronize];
//                                                    }
//                                                    
//                                                    // 과정 기수 목록을 DB에 저장하고 tableView 업데이트
//                                                    NSDictionary *favoriteInfo = [result valueForKeyPath:@"data"];
//                                                    //                                                    NSLog(@"즐겨찾기 업데이트 목록 : %@", favoriteInfo);
//                                                    [_updateInfo setDictionary:favoriteInfo];
//                                                    [self performSelector:@selector(updateDBFavorites) withObject:nil];
//
                                                  }
                                                
                                              }];

}

/// 해당 기수의 학생 목록 요청
- (void)requestAPIStudents:(NSDictionary *)info
{
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    NSString *lang = [UserContext shared].language;
//    NSString *courseClass = info[@"courseclass"];
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo, @"lang":lang, @"courseclass":info[@"courseclass"]};
    NSLog(@"(/fb/students) Request Parameter : %@", param);
    
//    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
    
    // 과정별 기수 목록
    [[SMNetworkClient sharedClient] postStudents:param
                                           block:^(NSMutableArray *result, NSError *error) {
                                               
//                                               [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                                               
                                               if (error)
                                               {
                                                   // 서버 오류가 있는 경우 프로그래스바 종료.
                                                   [self hideProgressView];

                                                   [[SMNetworkClient sharedClient] showNetworkError:error];
                                               }
                                               else
                                               {
                                                   _tot = [result count];
                                                   NSLog(@"즐겨찾기 추가 수신 학생 목록 (%d) : %@", _tot, result);
                                                   [self saveDBFavoriteStudent:result];
//                                                   [self performSelector:@selector(saveDBFavoriteStudent:) withObject:result];
                                                   
//                                                   // 기수 학생 목록
//                                                   [_students setArray:[result mutableCopy]];
//                                                   NSLog(@"(%@)기수 학생 수 : %d", _info[@"courseclass"], [_students count]);
//                                                   
//                                                   dispatch_async(dispatch_get_main_queue(), ^{
//                                                       //                                                      [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
//                                                       [_studentTableView reloadData];
//                                                   });
                                                   
                                               }
                                               
                                           }];
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
        return (NSMutableArray *)fetchedObjects;
    }
    return nil;

}


/// 즐겨찾기 DB 목록 불러오기
- (NSArray *)loadDBFavoriteCourse
{
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // where ((ZCOURSE="FACULTY" OR ZCOURSE="STAFF") OR ZFAVYN="y")
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(course == 'FACULTY') OR (course == 'STAFF') OR (favyn == 'y')"];
    [fetchRequest setPredicate:predicate];
    
    // order by (ZCOURSECLASS, ZCOURSE)
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"fetched Course DB count : %d", [fetchedObjects count]);
    
    //    for (Course *class in fetchedObjects) {
    //        NSLog(@"title : %@", class.title);
    //    }
    
    return fetchedObjects;
}



#pragma mark 업데이트 (학생) 목록 저장
- (void)saveDBFavoriteStudent:(NSArray *)students
{
    NSLog(@"----- 학생목록 저장 시작 -----");
    NSDictionary *userInfo = @{@"end":@"1"};
//    NSLog(@".......... 학생 프로그래스 시작 정보 : %@", userInfo);
//    self.savedTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(setUpdateProgress:) userInfo:userInfo repeats:YES];
    [self startRepeatingTimer:userInfo];
    
//    if (![updateInfo[@"student"] isKindOfClass:[NSArray class]])
//    {
//        NSLog(@"학생 목록 없으므로 학생은 pass!");
//        
//        _isStudentSaveDone = YES;
//        return;
//    }
//    
//    NSArray *students = [updateInfo[@"student"] mutableCopy];
    NSLog(@".......... 학생 저장 [%d] ..........", [students count]);
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [parentContext setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    //    [mainMoc setParentContext:writeMoc];
    
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:parentContext];
    
    NSManagedObjectContext *findContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [findContext setParentContext:parentContext];
    
    //    NSEntityDescription *courseEntity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:parentContext];
    //    NSLog(@"parent: %@,   child : %@,    find: %@,  main : %@", parentContext, childContext, findContext, appDelegate.managedObjectContext);
    __block BOOL done = NO;
    
    [childContext performBlock:^{
        
        for (NSDictionary *dict in students)
        {
            NSLog(@"학생(%@) 저장", dict[@"name"]);
            
            Course *course = nil;
            //            Student *student = nil;
            __block NSArray *findCourses = nil;
            __block NSDictionary *info = [NSDictionary dictionaryWithDictionary:dict];
            
            
            [childContext performBlockAndWait:^{
                NSFetchRequest *courseFr = [[NSFetchRequest alloc] init];
                NSLog(@"(%@)학생의 과정(%@) 조회", info[@"name"], info[@"courseclass"]);
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:parentContext];
                [courseFr setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course == %@ AND courseclass == %@", info[@"course"], info[@"courseclass"]];
                [courseFr setPredicate:predicate];
                
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
                NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
                [courseFr setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
                
                findCourses = [childContext executeFetchRequest:courseFr error:nil];
                NSLog(@"(%@)학생의 과정 찾았나? %d", info[@"name"], [findCourses count]);
            }];
            
            
            if ([findCourses count] > 0)
            {
                course = findCourses[0];
                
                NSArray *courseStudents = [course.students allObjects];
                NSLog(@"(%@ : %@)학생의 (%@)과정이 이미 존재함 : %d", info[@"name"], info[@"studcode"], course.courseclass, [courseStudents count]);
                
                //                for (Student *item in courseStudents) {
                //                    NSLog(@"(%@)과정의 학생 이름:%@, 아이디:%@", course.courseclass, item.name, item.studcode);
                //                }
                
                // 해당 과정에 이미 존재하는 학생인지 조사
                NSArray *existArray = [courseStudents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"studcode == %@", info[@"studcode"]]];
                NSLog(@"이미 해당 과정에 학생이 존재하나? %d", [existArray count]);
                
                if ([existArray count] > 0)
                {
                    Student *student = existArray[0];
                    
                    if ([info[@"remove"] isEqualToString:@"y"])
                    {
                        NSLog(@"(%@)학생 삭제", student.name);
                        [course removeStudentsObject:student];
                        [childContext deleteObject:student];
                    }
                    else
                    {
                        // 등록된 사용자이므로 정보만 업데이트
                        NSLog(@"업데이트 학생(%@) : %@", student.name, student.studcode);
                        
                        // ( NSManagedObject <- NSDictionary )
                        student.classtitle = info[@"classtitle"];
                        student.classtitle_en = info[@"classtitle_en"];
                        student.company = info[@"company"];
                        student.company_en = info[@"company_en"];
                        student.department = info[@"department"];
                        student.department_en = info[@"department_en"];
                        student.email = info[@"email"];
                        student.mobile = info[@"mobile"];
                        student.name = info[@"name"];
                        student.name_en = info[@"name_en"];
                        student.photourl = info[@"photourl"];
                        student.share_company = info[@"share_company"];
                        student.share_email = info[@"share_email"];
                        student.share_mobile = info[@"share_mobile"];
                        student.status = info[@"status"];
                        student.status_en = info[@"status_en"];
                        student.studcode = info[@"studcode"];
                        student.title = info[@"title"];
                        student.title_en = info[@"title_en"];
                        student.viewphotourl = info[@"viewphotourl"];
                        //                        student.course;
                    }
                }
                else
                {
                    __block NSMutableArray *anotherArray = nil;
                    //                    NSLog(@"학생의 과정이 변경되었거나, 추가된 경우");
                    
                    [childContext performBlockAndWait:^{
                        NSLog(@"학생의 과정이 변경되었는지 조회");
                        NSFetchRequest *fetchedRequest = [[NSFetchRequest alloc] init];
                        
                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:parentContext];
                        [fetchedRequest setEntity:entity];
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"studcode == %@", info[@"studcode"]];
                        [fetchedRequest setPredicate:predicate];
                        
                        NSArray *array = [childContext executeFetchRequest:fetchedRequest error:nil];
                        anotherArray = [array mutableCopy];
                        NSLog(@"다른 과정에 학생이 존재하나? %d", [anotherArray count]);
                    }];
                    
                    if ([anotherArray count] > 0)
                    {
                        Student *std = anotherArray[0];
                        
                        NSLog(@"학생(%@)의 과정이 달라져서 이전 과정 삭제. (%@ -> %@)", std.name, std.course.courseclass, info[@"courseclass"]);
                        [std.course removeStudentsObject:std];
                    }
                    
                    NSLog(@"해당 (%@)과정에 (%@)학생 추가", course.courseclass, info[@"name"]);
                    NSManagedObjectContext *context = [course managedObjectContext];
                    Student *newStudent = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:context];
                    
                    newStudent.studcode = info[@"studcode"];
                    NSLog(@"추가 Student : %@", newStudent.studcode);
                    
                    // ( NSManagedObject <- NSDictionary )
                    newStudent.classtitle = info[@"classtitle"];
                    newStudent.classtitle_en = info[@"classtitle_en"];
                    newStudent.company = info[@"company"];
                    newStudent.company_en = info[@"company_en"];
                    newStudent.department = info[@"department"];
                    newStudent.department_en = info[@"department_en"];
                    newStudent.email = info[@"email"];
                    newStudent.mobile = info[@"mobile"];
                    newStudent.name = info[@"name"];
                    newStudent.name_en = info[@"name_en"];
                    newStudent.photourl = info[@"photourl"];
                    newStudent.share_company = info[@"share_company"];
                    newStudent.share_email = info[@"share_email"];
                    newStudent.share_mobile = info[@"share_mobile"];
                    newStudent.status = info[@"status"];
                    newStudent.status_en = info[@"status_en"];
                    newStudent.studcode = info[@"studcode"];
                    newStudent.title = info[@"title"];
                    newStudent.title_en = info[@"title_en"];
                    newStudent.viewphotourl = info[@"viewphotourl"];
                    
                    newStudent.course = course;
                    //                        [newStudent setCourse:course];
                    
                    NSLog(@"과정의 컨텍스트로 (%@)학생 저장 (%@ === %@)", newStudent.name, context, childContext);
                    [context save:nil];
                    
                }
                
            }
            else {
                NSLog(@"해당 과정이 없으면 오류!!!!!!!!!!!!!");
            }
            
            ++_cur;
            NSLog(@"..... 학생 저장 중! (%d)", _cur);
            [childContext save:nil];
            
        } // for
        
        done = YES;
        _isStudentSaveDone = YES;
        NSLog(@"..... student done .....");
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"Saving parent");
            [parentContext save:nil];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
            NSLog(@"Done(학생): %d objects written", [[parentContext executeFetchRequest:request error:nil] count]);
           
            NSLog(@".......... ProgressBar Stop ..........");
            [self stopRepeatingTimer];
            
            // 업데이트 항목이 바뀌면 왼쪽 메뉴도 갱신한다.
            MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
            [menu updateHeaderInfo];

        });
        
    }]; // childContext
    
    // execute a read request after 0.5 second
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
        [parentContext performBlockAndWait:^{
            
            NSArray *objects = [parentContext executeFetchRequest:request error:nil];
            NSLog(@"In between read: (학생) %d objects", [objects count]);
            //            NSLog(@"object : %@", object);
            
        }];
    });
    
    
    NSLog(@"----- 학생목록 저장 종료 -----");
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.delegate = self;
    }
    
    if ([list count] > 0)
    {
        // 주소록 셀 정보
        Course *course = [list objectAtIndex:indexPath.row];
        
        // ( NSDictionary <- NSManagedObject )
        NSArray *keys = [[[course entity] attributesByName] allKeys];
        NSDictionary *info = [course dictionaryWithValuesForKeys:keys];
        NSLog(@"즐겨찾기 셀(%d) : %@", indexPath.row, info[@"favyn"]);

        if ([[UserContext shared].language isEqualToString:kLMKorean]) {
            cell.classLabel.text = course.title;
        } else {
            cell.classLabel.text = course.title_en;
        }
        cell.cellInfo = info;

//        if ([course.favyn isEqualToString:@"y"] || [course.type integerValue] > 1) {
//            [cell setHidden:YES];
//        } else {
//            [cell setHidden:NO];
//        }
        
//        list = _courseClasses[indexPath.section]
        Course *courseCheck = _favoriteList[indexPath.section][indexPath.row];
        NSString *myClass = [UserContext shared].myClass;
        NSLog(@"체크 정보 : %@, %@, %@ (my %@ == %@)", courseCheck.title, courseCheck.type, courseCheck.favyn, myClass, courseCheck.courseclass);
        if ([courseCheck.type integerValue] > 1 || [myClass isEqualToString:courseCheck.courseclass])
        {
            cell.favyn = YES;
            cell.favEnabled = NO;
        }
        else
        {
            cell.favEnabled = YES;
            if ([courseCheck.favyn isEqualToString:@"y"]) {
                cell.favyn = YES;
            } else {
                cell.favyn = NO;
            }
        }
        
//        if ( [courseCheck.type integerValue] == 1 && [courseCheck.favyn isEqualToString:@"n"]) {
//            cell.favyn = YES;
//        } else {
//            cell.favyn = NO;
////            if ([courseCheck.type integerValue] == ) {
////                <#statements#>
////            }
//        }
    }
    
    return cell;
}
//
//- (void)checkButtonTapped:(id)sender event:(id)event
//{
//	NSSet *touches = [event allTouches];
//	UITouch *touch = [touches anyObject];
//	CGPoint currentTouchPosition = [touch locationInView:_fvSettTableView];
//    
//	NSIndexPath *indexPath = [_fvSettTableView indexPathForRowAtPoint: currentTouchPosition];
//	if (indexPath != nil)
//	{
//		[self tableView:_fvSettTableView accessoryButtonTappedForRowWithIndexPath: indexPath];
//	}
//}
//
//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//	NSMutableDictionary *item = [_courseClasses objectAtIndex:indexPath.row];
//	
//    Course *course = _courseClasses[indexPath.section][indexPath.row]; // objectAtIndex:indexPath.row];
//    
//	BOOL checked = [course.favyn boolValue];//[[item objectForKey:@"favyn"] boolValue];
////	[item setObject:[NSNumber numberWithBool:!checked] forKey:@"checked"];
//    course.favyn = [NSString stringWithFormat:@"%d", !checked];
//    
//	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath]; // [item objectForKey:@"cell"];
//	UIButton *button = (UIButton *)cell.accessoryView;
//	
////    button.selected = !button.selected;
//	UIImage *newImage = (checked) ? [UIImage imageNamed:@"join_agreebox"] : [UIImage imageNamed:@"join_agreebox_ch"];
//	[button setBackgroundImage:newImage forState:UIControlStateNormal];
//}

#pragma mark - Timer
- (void)startRepeatingTimer:(NSDictionary *)info {
    NSLog(@".......... startRepeatingTimer (info : %@)", info);
    
//    _tot = [[UserContext shared].updateCount floatValue];
    _cur = 0;
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                      target:self
                                                    selector:@selector(timerFired:)
                                                    userInfo:info
                                                     repeats:YES];
    
    self.progressTimer = timer;
}

- (void)timerFired:(NSTimer *)timer
{
//    NSDictionary *info = [timer userInfo];

    NSLog(@".......... timerFired ( %d / %d ) ..........", _cur, _tot);
    [self.progressView onProgress:_cur total:_tot];
}

- (void)stopRepeatingTimer
{
    NSLog(@".......... stopRepeatingTimer");
    
    [self.progressView onProgress:_cur total:_tot];
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         
                         [self.progressView onProgress:_tot total:_tot];
                     }
                     completion:^(BOOL finished) {
                         [self.progressTimer invalidate];
                         self.progressTimer = nil;
                         
                         [self performSelector:@selector(hideProgressView) withObject:nil afterDelay:0.3];
                     }];
}

- (void)hideProgressView
{
    [self.progressView onStop];
    self.progressView.progress = 0.0f;
}

@end
