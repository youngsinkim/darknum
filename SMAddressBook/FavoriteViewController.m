//
//  FavoriteViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 23..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FavoriteViewController.h"
#import "MenuTableViewController.h"
#import "NSString+MD5.h"
#import "Course.h"
#import "Staff.h"
#import "Faculty.h"
#import "Student.h"
#import "Major.h"
#import "LoginViewController.h"
#import "FavoriteCell.h"
#import "LoadingView.h"
#import "UIViewController+LoadingProgress.h"
#import "FacultyMajorViewController.h"
#import "StaffAddressViewController.h"
#import "StudentAddressViewController.h"
#import "NSDate+Helper.h"

#import "FavoriteSettingViewController.h"
#import "CourseTotalViewController.h"
#import "HelpViewController.h"
#import "NSString+UrlEncoding.h"
#import "LoadingProgressView.h"
#import "NSDictionary+UTF8.h"

@interface FavoriteViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) FavoriteToolView *favoriteToolbar;
@property (strong, nonatomic) UITableView *favoriteTableView;   // 즐겨찾기 테이블 뷰
@property (strong, nonatomic) NSMutableArray *favorites;        // 즐겨찾기 목록

@property (strong, nonatomic) NSMutableArray *courses;
@property (strong, nonatomic) NSMutableArray *majors;
@property (strong, nonatomic) NSMutableDictionary *updateInfo;

@property (strong, nonatomic) LoadingView *loadingIndicatorView;
@property (strong, nonatomic) LoadingProgressView *progressView;
@end


@implementation FavoriteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = LocalizedString(@"favorite_title", @"즐겨찾기");
        
        self.favorites = [[NSMutableArray alloc] initWithCapacity:3];
        
        // 즐겨찾기 임시 저장 목록
        _courses = [[NSMutableArray alloc] init];
        _majors = [[NSMutableArray alloc] init];
        _updateInfo = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    // CoreData 컨텍스트 지정
    if (self.managedObjectContext == nil)
    {
        self.managedObjectContext = [appDelegate managedObjectContext];
        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
    }

    
    // 즐겨찾기 화면 구성
    [self setupFavoriteUI];

    // 프로그래스바 구성
    [self initUpdateProgress];
    
//    [_favoriteTableView reloadData];
    NSLog(@"MainThread - 5");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"즐겨찾기 화면 진입");
    
    // 로그인 전이면 화면 구성 중단.
    NSLog(@"로그인 후 즐겨찾기로 왔습니까? : %d", [UserContext shared].isLogined);
    if ([[UserContext shared] isLogined] != YES)
    {
        NSLog(@"로그인 전입니다.");
        return;
        //        if (!loginInfo[@"certno"]) {
        //        // MARK: 로그인 되지 않은 상태이면 로그인 화면 노출.
        //        UIViewController *loginViewController = [appDelegate loginViewController];
        //
        //        [self.navigationController presentViewController:loginViewController animated:NO completion:nil];
        //    }
        //    else if (![[UserContext shared] isAcceptTerms]) {
        //        // MARK: 약관 동의를 하지 않았으면 약관동의 화면 노출.
        //        UIViewController *termsViewController = [appDelegate termsViewController];
        //
        //        [self.navigationController presentViewController:termsViewController animated:NO completion:nil];
        //    }
        //    else if (![[UserContext shared] isExistProfile]) {
        //        }
    }
    
    if ([[UserContext shared] isAcceptTerms] != YES) {
        NSLog(@"약관 동의 전입니다.");
        return;
    }
    
    if ([[UserContext shared] isExistProfile] != YES) {
        NSLog(@"프로필 설정 전입니다.");
        return;
    }
    
    // DB에서 저장된 즐겨찾기(CourseClass) 목록 불러오기
    [_favorites setArray:[self loadDBFavoriteCourse]];
    
    if ([_favorites count] > 0)
    {
        // 즐겨찾기 목록 테이블 뷰 적용
        [self.favoriteTableView reloadData];
        
        // 즐겨찾기 목록 메뉴 적용
        MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
        [menu setAddrMenuList:self.favorites];
    }
    
    
    // (updateCount > 0) 즐겨찾기 업데이트
    NSInteger updateCount = [[UserContext shared].updateCount integerValue];
    NSLog(@"Login Update Count : %d", updateCount);
    
    if ((updateCount > 0) || ([self.favorites count] == 0))
    {
        // 로딩 프로그래스 시작...
        [self performSelectorOnMainThread:@selector(showUpdateProgress) withObject:nil waitUntilDone:YES];
//        [self showUpdateProgress];
//        [self performSelectorOnMainThread:@selector(startDimLoading) withObject:nil waitUntilDone:NO];
        
        // 즐겨찾기 목록이 DB에 없는 경우, 서버로 과정 기수 목록 요청하기  (과정 기수 목록에 즐겨찾기 포함되어 있음)
        NSLog(@"... 과정 목록 요청");
        //< Request data. (과정별 기수 목록)
//        [NSThread detachNewThreadSelector:@selector(requestAPIClasses) toTarget:self withObject:nil];
//        [self performSelector:@selector(requestAPIClasses) withObject:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self requestAPIClasses];
        });
        
        NSLog(@"... 전공 목록 요청");
        //< Request data. (교수 전공 목록)
//        [NSThread detachNewThreadSelector:@selector(requestAPIMajors) toTarget:self withObject:nil];
//            [self performSelector:@selector(requestAPIMajors) withObject:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self requestAPIMajors];
        });
        
        NSLog(@"... 즐겨찾기 목록 요청");
        //< Request data. (즐겨찾기 업데이트 목록, updatecount > 0)
//        [NSThread detachNewThreadSelector:@selector(requestAPIFavorites) toTarget:self withObject:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self requestAPIFavorites];
        });
        
        NSLog(@"... viewWillAppear 완료");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateTable
{
    NSLog(@"update - 4");
    [self.favoriteTableView reloadData];
    
    // 왼쪽 메뉴(즐겨찾기 목록) 업데이트
    MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
    [menu setAddrMenuList:_favorites];
    NSLog(@"update - 5");

}

- (void)initUpdateProgress
{
    // loading progress bar
    //    _loadingIndicatorView = [[LoadingView alloc] initWithFrame:CGRectMake(0.0f, 100.0f, 320.0f, 416.0f)];
    //    _loadingIndicatorView.showProgress = YES;
    //    _loadingIndicatorView.notificationString = NSLocalizedString(@"업데이트 중입니다. ", nil);
    //
    //    [self.view addSubview:_loadingIndicatorView];
    //        [_loadingIndicatorView show];

    _progressView = [[LoadingProgressView alloc] initWithFrame:self.view.bounds];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:_progressView];

}

- (void)showUpdateProgress
{
    [_progressView start];
}

- (void)hideUpdateProgress
{
    [_progressView stop];
}

#pragma mark - View mothods
// 즐겨찾기 화면 구성 
- (void)setupFavoriteUI
{
    CGRect rect = self.view.frame;
    CGFloat sizeY = kFvToolH;
    
    if (IS_LESS_THEN_IOS7) {
        sizeY += 44.0f;
    }
    
    // 즐겨찾기 테이블 뷰
    _favoriteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, rect.size.height - sizeY) style:UITableViewStylePlain];
    _favoriteTableView.dataSource = self;
    _favoriteTableView.delegate = self;
    
    [self.view addSubview:_favoriteTableView];
    
    if (!IS_LESS_THEN_IOS7) {
        UIEdgeInsets edges;
        edges.left = 0;
        _favoriteTableView.separatorInset = edges;
    }
    
    // 하단 버튼 툴바
    _favoriteToolbar = [[FavoriteToolView alloc] initWithFrame:CGRectMake(0.0f, rect.size.height - sizeY, 320, kFvToolH)];
    _favoriteToolbar.delegate = self;

    [self.view addSubview:_favoriteToolbar];
}


#pragma mark - FavoriteToolView Delegate
/// 즐겨찾기 설정 버튼
- (void)onFavoriteSettBtnTouched:(id)sender
{
    FavoriteSettingViewController *viewController = [[FavoriteSettingViewController alloc] init];
    
    MenuTableViewController *leftMenu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
    
    self.menuContainerViewController.centerViewController = [leftMenu navigationController:viewController];
}

/// 전체보기 버튼
- (void)onTotalStudentBtnTouched:(id)sender
{
    CourseTotalViewController *viewController = [[CourseTotalViewController alloc] init];
    
    MenuTableViewController *leftMenu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
    
    self.menuContainerViewController.centerViewController = [leftMenu navigationController:viewController];
}

/// 도움말
- (void)onHelpBtnTouched:(id)sender
{
    HelpViewController *viewController = [[HelpViewController alloc] init];
    
    MenuTableViewController *leftMenu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
    
    self.menuContainerViewController.centerViewController = [leftMenu navigationController:viewController];
}


#pragma mark - Network API

/// 각 과정별 기수 목록 서버로 요청
- (void)requestAPIClasses
{
    NSLog(@"testMethod1 in, runloop : %x", [NSRunLoop currentRunLoop]);
//    NSDictionary *param = @{@"scode"=5684825a51beb9d2fa05e4675d91253c&userid=ztest01&certno=m9kebjkakte1tvrqfg90i9fh84};
    
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};
    NSLog(@"(/fb/courseclass) Request Parameter : %@", param);
    NSLog(@"Thread1 - 1");

    // 과정별 기수 목록
    [[SMNetworkClient sharedClient] postClasses:param
                                          block:^(NSArray *result, NSError *error) {
                                              NSLog(@"Thread1 - 3");
                                              
                                              if (error)
                                              {
                                                  [[SMNetworkClient sharedClient] showNetworkError:error];
                                              }
                                              else
                                              {
                                                  // 과정 기수 목록
//                                                  NSArray *courseClassArray = [result valueForKeyPath:@"data"];
//                                                  [_courses setArray:classes];
                                                  [_courses setArray:result];
                                                  NSLog(@"과정 기수 목록 (%d) : %@", [_courses count], _courses);
                                                  
//                                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                  
                                                  // DB 저장 (과정 기수 목록)
                                                  [self onUpdateDBCourse:_courses];
                                              
                                                  [self performSelector:@selector(updateDBFavorites) withObject:nil];
//                                                      dispatch_async(dispatch_get_main_queue(), ^{
//                                                          [self.favoriteTableView reloadData];
//                                                            [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
//                                                      });
//                                                  });
                                                  
                                              }
                                          }];
    NSLog(@"Thread1 - 2");
}


/// 교수 전공 목록 서버로 요청
- (void)requestAPIMajors
{
    NSLog(@"testMethod2 in, runloop : %x", [NSRunLoop currentRunLoop]);
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }

    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};
    NSLog(@"(/fb/majors) Request Parameter : %@", param);
    NSLog(@"Thread2 - 1");

    // 과정별 기수 목록
    [[SMNetworkClient sharedClient] postMajors:param
                                         block:^(NSArray *result, NSError *error) {
                                             NSLog(@"Thread2 - 3");
                                             
                                             if (error)
                                             {
                                                 [[SMNetworkClient sharedClient] showNetworkError:error];
                                             }
                                             else
                                             {
//                                                 NSArray *majorList = [result mutableCopy];
//                                                 [_majors setArray:majorList];
                                                 [_majors setArray:result];
                                                 NSLog(@"전공 목록 (%d) : %@", [_majors count], _majors);
                                                 
                                                 // 전공목록 DB 저장.
                                                 [self onUpdateDBMajors:_majors];
                                                 
                                                 NSLog(@"Thread2 - 4");
                                                 [self performSelector:@selector(updateDBFavorites) withObject:nil];

//                                                 dispatch_async(dispatch_get_main_queue(), ^{
//                                                     NSLog(@"Thread2 - 5");
                                                     //                                                      [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
//                                                     [self.majorTableView reloadData];
//                                                     NSLog(@"Thread2 - 6");
//                                                 });
                                                 
                                             }
                                             
                                         }];
    
    NSLog(@"Thread2 - 2");
}


/// 업데이트된 즐겨찾기 목록 (updatecount > 0)
- (void)requestAPIFavorites
{
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    NSString *lastUpdate = [UserContext shared].lastUpdateDate;
    
    if (!mobileNo || !userId | !certNo || !lastUpdate) {
        return;
    }

    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo, @"updatedate":lastUpdate};
    NSLog(@"(/fb/updated) Request Parameter : %@", param);
    NSLog(@"... 즐겨찾기 목록 서버 요청");
//    [self performSelectorOnMainThread:@selector(startDimLoading) withObject:nil waitUntilDone:NO];

    // 즐겨찾기 업데이트 목록
    [[SMNetworkClient sharedClient] postFavorites:param
                                            block:^(NSDictionary *result, NSError *error) {
//                                              [self performSelectorOnMainThread:@selector(stopDimLoading) withObject:nil waitUntilDone:NO];
                                                
                                                if (error) {
                                                    [[SMNetworkClient sharedClient] showNetworkError:error];
                                                }
                                                else
                                                {
                                                    NSLog(@"... 즐겨찾기 목록 수신 완료");
                                                    // 즐겨찾기 업데이트 수신 후, 현재 시간을 마지막 업데이트 시간으로 저장
                                                    {
                                                        NSDate *date = [NSDate date];
                                                        NSString *displayString = [date string];
                                                        NSLog(@"즐겨찾기 업데이트 시간? %@", displayString);
                                                    
                                                        [UserContext shared].lastUpdateDate = displayString;
                                                        [[NSUserDefaults standardUserDefaults] setValue:displayString forKey:kLastUpdate];
                                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                                    }
                                                
                                                    // 과정 기수 목록을 DB에 저장하고 tableView 업데이트
//                                                    NSDictionary *favoriteInfo = [result valueForKeyPath:@"data"];
                                                    
    //                                                [self onUpdateDBFavorites:favoriteInfo];
    //                                                 NSLog(@"Thread3 - 5");
//                                                    [_updateInfo setDictionary:favoriteInfo];
                                                    [_updateInfo setDictionary:result];
                                                    NSLog(@"즐겨찾기 업데이트 목록 (%d) : %@", [_updateInfo count], _updateInfo);
                                                    
                                                    [self performSelector:@selector(updateDBFavorites) withObject:nil];
                                                    
                                                }
                                            }];
    NSLog(@"... 즐겨찾기 업데이트 목록 처리 완료");
}


#pragma mark - Callback methods
- (void)myProgressTask:(id)sender
{
    MBProgressHUD *hud = (MBProgressHUD *)[self.navigationController.view viewWithTag:77777];
    if (hud != nil)
    {
        float progress = 0.0f;
        while (progress < 1.0f) {
            progress += 0.01f;
            hud.progress = progress;
//            NSLog(@"progress : %f", hud.progress);
            usleep(4000);
        }
    }
}

- (void)updateDBFavorites
{
    if ([_courses count] > 0 && [_majors count] > 0 && [_updateInfo count] > 0)
    {
        NSLog(@"(%d), (%d) 즐겨찾기 목록을 저장하자........", [_courses count], [_majors count]);
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread detachNewThreadSelector:@selector(onUpdateDBFavorites:) toTarget:self withObject:_updateInfo];
//            [self onUpdateDBFavorites:_updateInfo];
//        });
    }
    
}

#pragma mark - CoreData methods

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

/// course classes DB 추가 및 업데이트
- (void)onUpdateDBCourse:(NSArray *)courseClasses
{
    BOOL isSaved = NO;

    for (NSDictionary *info in courseClasses)
    {
        Course *course = nil;
        NSDictionary *decodeInfo = [info dictionaryByUTF8Decode];
        NSLog(@"과정 기수 정보 : %@", decodeInfo);
        
        NSArray *fetched = [self filteredCourses:decodeInfo];
        NSLog(@"기수 찾았나? %d", [fetched count]);
        
        if ([fetched count] > 0)
        {
            // db에 있으면 업데이트
            course = fetched[0];
            
            // ( NSManagedObject -> NSDictionary )
//            NSArray *keys = [[[courseClass entity] attributesByName] allKeys];
//            NSDictionary *dict = [courseClass dictionaryWithValuesForKeys:keys];
//            NSLog(@"학생 셀 정보 : %@", dict);

            // ( NSManagedObject <- NSDictionary )
            [course setValuesForKeysWithDictionary:decodeInfo];
//            NSLog(@"UPDATE 기수 : course(%@), courseclass(%@), title(%@), title_en(%@), favyn(%@), count (%@), students(%d) ",
//                  course.course, course.courseclass, course.title, course.title_en, course.favyn, course.count, [course.students count]);
//            favorite.course = dict[@"course"];
//            favorite.courseclass = dict[@"courseclass"];
//            favorite.title = dict[@"title"];
//            favorite.title_en = dict[@"title_en"];
//            favorite.favyn = dict[@"favyn"];
//            favorite.count = dict[@"count"];
        }
        else
        {
            // 기존 목록에 없으면 추가 (INSERT)
           course = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
            
            // ( NSManagedObject <- NSDictionary )
            [course setValuesForKeysWithDictionary:decodeInfo];
//            NSLog(@"INSERT 기수 : course(%@), courseclass(%@), title(%@), title_en(%@), favyn(%@), count (%@), students(%d) ",
//                  course.course, course.courseclass, course.title, course.title_en, course.favyn, course.count, [course.students count]);
//            favorite.course = dict[@"course"];
//            favorite.courseclass = dict[@"courseclass"];
//            favorite.title = dict[@"title"];
//            favorite.title_en = dict[@"title_en"];
//            if ([dict objectForKey:@"favyn"]) {
//                favorite.favyn = dict[@"favyn"];
//            }
////            if ([dict objectForKey:@"count"]) {
//                favorite.count = dict[@"count"];
////            }
        }
        
        // 교수, 교직원, 학색 코드 부여
        if ([decodeInfo[@"course"] isEqualToString:@"FACULTY"]) {
            course.type = @"2";
        } else if ([decodeInfo[@"course"] isEqualToString:@"STAFF"]) {
            course.type = @"3";
        } else {
            course.type = @"1";
        }
        isSaved = YES;

    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"과정기수 목록 DB 저장 오류  : %@", [error localizedDescription]);
    }
    else
    {
        // DB 즐겨찾기 목록 가져오기
        NSLog(@"과정기수 목록 DB 저장 성공!");
        [_favorites setArray:[self loadDBFavoriteCourse]];
        
        if ([_favorites count] > 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
//            [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
                [self updateTable];
            });
            
        }
    }
}

                                             
/// major DB 추가 및 업데이트
- (void)onUpdateDBMajors:(NSArray *)majors
{
    for (NSDictionary *info in majors)
    {
        Major *major = nil;
        NSDictionary *decodeInfo = [info dictionaryByUTF8Decode];
        NSLog(@"전공 정보 : %@", decodeInfo);
        
        NSArray *fetched = [self fetchedMajors:decodeInfo];
        NSLog(@"찾은 전공 개수? %d", [fetched count]);

        if ([fetched count] > 0)
        {
            // db에서 찾은 경우 (UPDATE)
            major = fetched[0];

            // ( NSManagedObject -> NSDictionary )
            //            NSArray *keys = [[[courseClass entity] attributesByName] allKeys];
            //            NSDictionary *dict = [courseClass dictionaryWithValuesForKeys:keys];
            //            NSLog(@"학생 셀 정보 : %@", dict);

            // ( NSManagedObject <- NSDictionary )
            [major setValuesForKeysWithDictionary:decodeInfo];
//            NSLog(@"UPDATE 전공 : major(%@), title(%@), title_en(%@), facultys(%d) ",
//            major.major, major.title, major.title_en, [major.facultys count]);
        }
        else
        {
            // 기존 목록에 없으면 추가 (INSERT)
            major = (Major *)[NSEntityDescription insertNewObjectForEntityForName:@"Major" inManagedObjectContext:self.managedObjectContext];

            // ( NSManagedObject <- NSDictionary )
            [major setValuesForKeysWithDictionary:decodeInfo];
//            NSLog(@"UPDATE 전공 : major(%@), title(%@), title_en(%@), facultys(%d) ",
//                  major.major, major.title, major.title_en, [major.facultys count]);

        }
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"전공 목록 DB 저장 오류 : %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"전공 목록 DB 저장 성공!");

//        [self.favorites setArray:[self loadDBFavoriteCourse]];
//
//        if ([_favorites count] > 0)
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//            });
//        }
        
//        // 갱신된 즐겨찾기 목록 메뉴 업데이트.
//        MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
//        [menu setAddrMenuList:_favorites];
    }
}


/// course classes DB 추가 및 업데이트
- (void)onUpdateDBFavorites:(NSDictionary *)favoriteInfo
{
    if ([favoriteInfo[@"student"] isKindOfClass:[NSArray class]])
    {
        // 학생 목록이 있으면 학생 테이블 추가(업데이트)
        NSArray *students = favoriteInfo[@"student"];
        NSLog(@"즐겨찾기 업데이트 학생 수 [%d]", [students count]);
        
        for (NSDictionary *student in students)
        {
            // DB에 현재 학생의 기수가 존재하면 해당 기수에 학생을 추가하도록 함. (relationship 연결 처리)
//            NSLog(@"업데이트 학생 정보 : %@", student);
            NSDictionary *decodeInfo = [student dictionaryByUTF8Decode];
            NSLog(@"즐겨찾기 학생 : %@", decodeInfo);
            
            //- 학생의 기수 종류 먼저 검색
            Course *course = nil;
            NSArray *filteredCourses = [self filteredCourses:decodeInfo];
            
            if ([filteredCourses count] > 0) {
                // 로컬 DB에 존재하면 업데이트
                course = filteredCourses[0];
            }
            else {
                course = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
                course.course = decodeInfo[@"course"];
                course.courseclass = decodeInfo[@"courseclass"];
                course.title = decodeInfo[@"classtitle"];
                course.title_en = decodeInfo[@"classtitle_en"];
                course.favyn = @"n";
                course.type = @"1";
            }
            
            //- 학생 검색 하여 기수에 해당 학생 정보 삽입
            NSArray *filteredObjects = [self filteredObjects:decodeInfo[@"studcode"] memberType:MemberTypeStudent];
            Student *student = nil;
            
            if ([filteredObjects count] > 0)
            {
                // 로컬 DB에 존재하면 업데이트
                student = filteredObjects[0];
            }
            else
            {
                // 로컬 DB에 없으면 추가 (INSERT)
                student = (Student *)[NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.managedObjectContext];
                student.studcode = decodeInfo[@"studcode"];
            }

            // ( NSManagedObject <- NSDictionary )
            //[student setValuesForKeysWithDictionary:dict];
            student.name = decodeInfo[@"name"];
            student.name_en = decodeInfo[@"name_en"];
            student.mobile = decodeInfo[@"mobile"];
            student.email = decodeInfo[@"email"];
            student.company = decodeInfo[@"company"];
            student.company_en = decodeInfo[@"company_en"];
            student.department = decodeInfo[@"department"];
            student.department_en = decodeInfo[@"department_en"];
            student.status = decodeInfo[@"status"];
            student.status_en = decodeInfo[@"status_en"];
            student.title = decodeInfo[@"title"];
            student.title_en = decodeInfo[@"title_en"];
            student.share_company = decodeInfo[@"share_company"];
            student.share_email = decodeInfo[@"share_email"];
            student.share_mobile = decodeInfo[@"share_mobile"];
            student.photourl = decodeInfo[@"photourl"];

            [course addStudentsObject:student];
            
//            NSLog(@"UPDATE 즐겨찾기 학생 : course(%@ = %@), courseclass(%@ = %@), title(%@ = %@), title_en(%@), favyn(%@), count (%@), students(%d) ",
//                  course.course, dict[@"course"], course.courseclass, dict[@"courseclass"], course.title, dict[@"classtitle"], course.title_en, course.favyn, course.count, [course.students count]);

            
//            mo.class_info.course = student[@"course"];
//            mo.class_info.courseclass = student[@"courseclass"];
//            mo.class_info.title = student[@"classtitle"];
//            mo.class_info.title_en = student[@"classtitle_en"];
//            
        }
    }
    
    if ([favoriteInfo[@"faculty"] isKindOfClass:[NSArray class]])
    {
        // 교수 목록이 있으면 학생 테이블 추가(업데이트)
        NSArray *facultys = favoriteInfo[@"faculty"];
        NSLog(@"즐겨찾기 업데이트 교수 [%d]", [facultys count]);
        
        for (NSDictionary *faculty in facultys)
        {
            NSDictionary *dict = [faculty dictionaryByUTF8Decode];
            NSLog(@"업데이트 교수 정보 : %@", dict[@"name"]);
            
            //- 교수 전공 종류 먼저 검색
            Major *major = nil;
            NSArray *fetchedMajors = [self fetchedMajors:dict];
            
            if ([fetchedMajors count] > 0) {
                // 로컬 DB에 존재하면 업데이트
                major = fetchedMajors[0];
            }
            else {
                major = (Major *)[NSEntityDescription insertNewObjectForEntityForName:@"Major" inManagedObjectContext:self.managedObjectContext];
                major.major = dict[@"major"];
            }

            // 교수 검색하여 해당 전공에 교수 정보 삽입
            NSArray *filteredObjects = [self filteredObjects:dict[@"memberidx"] memberType:MemberTypeFaculty];
            Faculty *faculty = nil;
            
            if ([filteredObjects count] > 0) {
                // 로컬 DB에 존재하면 업데이트
                faculty = filteredObjects[0];
            }
            else
            {
                // 로컬 DB에 없으면 추가 (INSERT)
                faculty = (Faculty *)[NSEntityDescription insertNewObjectForEntityForName:@"Faculty" inManagedObjectContext:self.managedObjectContext];
                faculty.memberidx = dict[@"memberidx"];
            
                // 교수의 전공이 이미 전공 목록에 존재하는지 검사 후, 없으면 추가
//                NSLog(@"찾은 교수 전목 과목은 : %@", faculty[@"major"]);
//                NSArray *filtered = [self filteredMajorObjects:faculty[@"major"]];
//                if ([filtered count] > 0) {
//                    mo.major = filtered[0];
//                } else {
//                    mo.major = (Major *)[NSEntityDescription insertNewObjectForEntityForName:@"Major" inManagedObjectContext:self.managedObjectContext];
//                }
            }
            
            // ( NSManagedObject <- NSDictionary )
            //[faculty setValuesForKeysWithDictionary:dict];
            faculty.name = dict[@"name"];
            faculty.name_en = dict[@"name_en"];
            faculty.tel = dict[@"tel"];
            faculty.mobile = dict[@"mobile"];
            faculty.email = dict[@"email"];
            faculty.office = dict[@"office"];
            faculty.office_en = dict[@"office_en"];
            faculty.photourl = dict[@"photourl"];

            [major addFacultysObject:faculty];
            
//            NSLog(@"UPDATE 즐겨찾기 교수 : memberIdx(%@) major(%@ = %@), title(%@ = %@), title_en(%@), facultys(%d)",
//                  dict[@"memberIdx"], major.major, dict[@"major"], major.title, dict[@"title"], major.title_en, [major.facultys count]);
            
//            mo.major.major = faculty[@"major"];
        }
    }

    if ([favoriteInfo[@"staff"] isKindOfClass:[NSArray class]])
    {
        // 교직원 목록이 있으면 학생 테이블 추가(업데이트)
        NSArray *staffs = favoriteInfo[@"staff"];
        NSLog(@"즐겨찾기 업데이트 교직원[%d]", [staffs count]);
        
        for (NSDictionary *staff in staffs)
        {
            NSDictionary *dict = [staff dictionaryByUTF8Decode];
            NSLog(@"교직원 정보 : %@", dict[@"name"]);
            
            NSArray *filteredObjects = [self filteredObjects:dict[@"memberidx"] memberType:MemberTypeStaff];
            Staff *mo = nil;
            
            if ([filteredObjects count] > 0)
            {
                // 로컬 DB에 존재하면 업데이트
                mo = filteredObjects[0];
            }
            else
            {
                // 로컬 DB에 없으면 추가 (INSERT)
                mo = (Staff *)[NSEntityDescription insertNewObjectForEntityForName:@"Staff" inManagedObjectContext:self.managedObjectContext];
                mo.memberidx = dict[@"memberidx"];
            }
            
            // ( NSManagedObject <- NSDictionary )
//            [staff setValuesForKeysWithDictionary:dict];
            
            mo.name     = dict[@"name"];
            mo.name_en  = dict[@"name_en"];
            mo.tel      = dict[@"tel"];
            mo.mobile   = dict[@"mobile"];
            mo.email    = dict[@"email"];
            mo.office   = dict[@"office"];
            mo.office_en= dict[@"office_en"];
            mo.photourl = dict[@"photourl"];
            
            NSLog(@"UPDATE 즐겨찾기 교직원 : memberIdx(%@), name(%@), name_en(%@), tel(%@)", mo.memberidx, mo.name, mo.name_en, mo.tel);
        }
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"error : %@", [error localizedDescription]);
    }
    else {
        NSLog(@"즐겨찾기 업데이트 목록 저장 성공!");
//        [self performSelectorOnMainThread:@selector(stopDimLoading) withObject:nil waitUntilDone:NO];
        
//        [_loadingIndicatorView stop];

        // 즐겨찾기 목록 로컬 DB에서 갱신.
//        [self.favorites setArray:[self loadDBFavoriteCourse]];
        
//        [self performSelectorOnMainThread:@selector(hideUpdateProgress) withObject:nil waitUntilDone:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideUpdateProgress];
        });

/*
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // select Table
        NSEntityDescription *entity = nil;
        NSPredicate *predicate = nil;
        
            // 학생 table
            entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:self.managedObjectContext];
            // 교수 table
//            entity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:self.managedObjectContext];
            // 교직원 table
//            entity = [NSEntityDescription entityForName:@"Staff" inManagedObjectContext:self.managedObjectContext];
        
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *filtered = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        NSLog(@"Filtered DB count : %d", [filtered count]);
 */
    }

}


/// courseclass DB 찾기
- (NSArray *)fetchedCourses:(NSDictionary *)info
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // select Table
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // where
    NSLog(@"기수 찾기 조건 ? (course == %@) AND (courseclass == %@)", info[@"course"], info[@"courseclass"]);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(course == %@) AND (courseclass == %@)", info[@"course"], info[@"courseclass"]];
    [fetchRequest setPredicate:predicate];
    
    // order by
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
    
    NSError *error = nil;
    NSArray *filtered = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"filtered DB count : %d", [filtered count]);

    return filtered;
}

                                             
/// major DB 찾기
- (NSArray *)fetchedMajors:(NSDictionary *)info
{
    NSLog(@"찾는 전공 %@(%@)", info[@"name"], info[@"major"]);
    if ([info[@"major"] length] == 0) {
        return nil;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Major" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(major == %@)", info[@"major"]];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);

    return fetchedObjects;
}


/// 조건에 맞는 기수 검색
- (NSArray *)filteredCourses:(NSDictionary *)info
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // select Table
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course == %@ AND courseclass == %@", info[@"course"], info[@"courseclass"]];
    [fetchRequest setPredicate:predicate];
    
    NSLog(@"찾을 기수 : course = %@, courseclass = %@", info[@"course"], info[@"courseclass"]);
    
    // order by
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
    
    NSError *error = nil;
    NSArray *filtered = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Filtered DB count : %d", [filtered count]);
    
    return filtered;
}


/// 기존 DB에 해당 멤버(studcode or memberidx)가 이미 존재하는지 확인
- (NSArray *)filteredObjects:(NSString *)code memberType:(MemberType)memType
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // select Table
    NSEntityDescription *entity = nil;
    NSPredicate *predicate = nil;
//    NSLog(@"code = %@", code);
    
    if (memType == MemberTypeStudent) {
        // 학생 table
        entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:self.managedObjectContext];
        
        predicate = [NSPredicate predicateWithFormat:@"(studcode == %@)", code];
    }
    else if (memType == MemberTypeFaculty)
    {
        // 교수 table
        entity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:self.managedObjectContext];
        
        predicate = [NSPredicate predicateWithFormat:@"(memberidx == %@)", code];
    }
    else if (memType == MemberTypeStaff)
    {
        // 교직원 table
        entity = [NSEntityDescription entityForName:@"Staff" inManagedObjectContext:self.managedObjectContext];
        
        predicate = [NSPredicate predicateWithFormat:@"(memberidx == %@)", code];
    }

    if (entity == nil || predicate == nil) {
        return nil;
    }

    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    // order by
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *filtered = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSLog(@"Filtered DB count : %d", [filtered count]);
    
    return filtered;
}


//- (BOOL)isFetchCourse:(NSString *)course
//{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//
//    // select Table
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    // where
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course==%@", course];
//    [fetchRequest setPredicate:predicate];
//    
//    // order by
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//
//    NSError *error = nil;
//    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSLog(@"DB data count : %d", [fetchedObjects count]);
//    
//    if (fetchedObjects && [fetchedObjects count] > 0)
//    {
//        return YES;
//    }
//    
//    return NO;
////    return fetchedObjects; //fetchedObjects will always exist although it may be empty
//}
//
//- (BOOL)isFetchClass:(NSString *)class
//{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    // select Table
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    // where
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"courseclass==%@", class];
//    [fetchRequest setPredicate:predicate];
//    
//    // order by
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//    
//    NSError *error = nil;
//    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSLog(@"DB data count : %d", [fetchedObjects count]);
//    
//    if (fetchedObjects && [fetchedObjects count] > 0)
//    {
//        return YES;
//    }
//    
//    return NO;
//    //    return fetchedObjects; //fetchedObjects will always exist although it may be empty
//}


#pragma mark - UITableView DataSources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([_favorites count] > 0)? [_favorites count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([_favorites count] > 0)? kFavoriteCellH : self.view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_favorites count] == 0)
    {
        static NSString *identifier = @"NoFavoriteCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"FavoriteCell";
    FavoriteCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[FavoriteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        //        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    if ([_favorites count] > 0) {
        Course *course = _favorites[indexPath.row];
        NSLog(@"즐겨찾기 항목 제목 : %@", course.title);
        cell.title = course.title;
//        cell.titleLabel.text = course.title;
        [cell setMemType:[course.type integerValue] WidhCount:[course.count integerValue]];
        //        cell.textLabel.text = course.title;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"선택한 셀 => (%i / %i)", indexPath.row, indexPath.section);
    
    Course *courseClass = _favorites[indexPath.row];
    
    if (courseClass)
    {
        NSLog(@"선택된 셀 정보 : %@", courseClass);
        switch ([courseClass.type integerValue])
        {
            case MemberTypeFaculty: // 교수진
                {
                    FacultyMajorViewController *facultyMajorVC = [[FacultyMajorViewController alloc] init];
                    facultyMajorVC.navigationItem.title = courseClass.title;
                    [self.navigationController pushViewController:facultyMajorVC animated:YES];
                }
                break;
                
            case MemberTypeStaff:   // 교직원
                {
                    StaffAddressViewController *staffAddressVc = [[StaffAddressViewController alloc] init];
                    staffAddressVc.navigationItem.title = courseClass.title;
                    [self.navigationController pushViewController:staffAddressVc animated:YES];
                }
                break;
                
            case MemberTypeStudent: // 학생
                {
                    NSArray *keys = [[[courseClass entity] attributesByName] allKeys];
                    NSDictionary *dict = [courseClass dictionaryWithValuesForKeys:keys];
                    NSLog(@"학생 셀 정보 : %@", dict);
                    
                    StudentAddressViewController *studentAddressVC = [[StudentAddressViewController alloc] initWithInfo:dict];
                    
                    [self.navigationController pushViewController:studentAddressVC animated:YES];
                }
                break;
                
            default:
                NSLog(@"CourseClass Type unknown.");
                break;
        }
    }
}


@end
