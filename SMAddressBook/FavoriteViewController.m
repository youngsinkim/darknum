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
#import "ModelUtil.h"

@interface FavoriteViewController ()

@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSManagedObjectContext *mainMoc;
@property (strong, nonatomic) NSManagedObjectContext *backMoc;

@property (strong, nonatomic) FavoriteToolView *favoriteToolbar;
@property (strong, nonatomic) UITableView *favoriteTableView;   // 즐겨찾기 테이블 뷰
@property (strong, nonatomic) NSMutableArray *favorites;        // 즐겨찾기 목록

@property (strong, nonatomic) NSMutableArray *courses;
@property (strong, nonatomic) NSMutableArray *majors;
@property (strong, nonatomic) NSMutableDictionary *updateInfo;

@property (strong, nonatomic) LoadingView *loadingIndicatorView;
@property (strong, nonatomic) LoadingProgressView *progressView;
@property (assign) NSInteger tot;
@property (assign) NSInteger cur;

@property (assign) BOOL studentSaveDone;
@property (assign) BOOL facultySaveDone;
@property (assign) BOOL staffSaveDone;
@property (strong, nonatomic) NSTimer *savedTimer;
@end


@implementation FavoriteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = LocalizedString(@"favorite_title", @"즐겨찾기");
        
        _moc = nil;
        self.favorites = [[NSMutableArray alloc] initWithCapacity:3];
        
        // 즐겨찾기 임시 저장 목록
        _courses = [[NSMutableArray alloc] init];
        _majors = [[NSMutableArray alloc] init];
        _updateInfo = [[NSMutableDictionary alloc] initWithCapacity:3];
        
        _tot = [[UserContext shared].updateCount floatValue];
        _cur = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"---------- START ----------");
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (_moc == nil) {
        _moc = [appDelegate managedObjectContext];
        NSLog(@"After managedObjectContext: %@", _moc);
    }

    // 즐겨찾기 화면구성
    [self setupFavoriteUI];

    // 프로그래스바 구성
    [self initUpdateProgress];
    
//    [_favoriteTableView reloadData];
    NSLog(@"---------- END ----------");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"---------- START ----------");
    
    // 로그인 여부 확인
    NSLog(@"로그인 했나? ( %d )", [UserContext shared].isLogined);
    
    if ([[UserContext shared] isLogined])
    {
        if (![[UserContext shared] isAcceptTerms]) {
            NSLog(@"약관 동의 전입니다.");
            return;
        }
        
        if (![[UserContext shared] isExistProfile]) {
            NSLog(@"프로필 설정 전입니다.");
            return;
        }
        
#if (0)
        NSLog(@".......... GET DB Majors .........");
        [self getLocalMajors:@"1"];
        NSLog(@".......... GET DB Courses ..........");
        [self getLocalFavoriteClasses:@"1"];
        //    NSLog(@"즐겨찾기 업데이트 개수 : (%d)", [_favorites count]);
#else
        
        // 즐겨찾기 목록 구성
        NSLog(@".......... GET DB Favorite Courses ..........");
        [_favorites setArray:[self loadDBFavoriteCourses]];
        
        if ([_favorites count] > 0)
        {
            [self.favoriteTableView reloadData];
            
            MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
            [menu setAddrMenuList:self.favorites];
        }
#endif

        NSLog(@".......... REQUEST Majors .........");
        [self requestAPIMajors];
        
        NSLog(@".......... REQUEST CourseClass .........");
        [self requestAPIClasses];
        
        // (updateCount > 0) 서버 업데이트 존재함
        NSInteger updateCount = [[UserContext shared].updateCount integerValue];
        NSLog(@".......... updateCount (%d)", updateCount);
        
        if (updateCount > 0)
        {
//            [_progressView setHidden:NO];   // test
//    [self performSelector:@selector( showUpdateProgress) withObject:nil];

            NSLog(@".......... REQUEST Update Favorites .........");
            [self requestAPIFavorites];
            
//            NSLog(@"과정별 기수 목록 요청");
//            NSLog(@".......... requestAPIFavorites ..........");
//            [self performSelector:@selector(requestAPIFavorites) withObject:nil];

#if (0)
//            [self requestFirst];
    //        [NSThread detachNewThreadSelector:@selector(requestAPIClasses) toTarget:self withObject:nil];
    //        [self performSelector:@selector(requestAPIClasses) withObject:nil];

            //< Request data. (교수 전공 목록)
    //        [NSThread detachNewThreadSelector:@selector(requestAPIMajors) toTarget:self withObject:nil];
    //            [self performSelector:@selector(requestAPIMajors) withObject:nil];

            //< Request data. (즐겨찾기 업데이트 목록, updatecount > 0)
    //        [NSThread detachNewThreadSelector:@selector(requestAPIFavorites) toTarget:self withObject:nil];
#endif
            NSLog(@"--");
        }
    }
    NSLog(@"---------- viewWill END ----------");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
    [menu updateHeaderInfo];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // IMSI
//    [UserContext shared].lastUpdateDate = @"0000-00-00 00:00:00";
//    [UserContext shared].updateCount = @"1";
//    return;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshFavoriteTable
{
    NSLog(@"---------- START ----------");
    [self.favoriteTableView reloadData];
    
    MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
    [menu setAddrMenuList:_favorites];
    NSLog(@"---------- END ----------");
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

    if (!_progressView) {
        _progressView = [[LoadingProgressView alloc] initWithFrame:self.view.bounds];
        _progressView.delegate = self;
        [[[UIApplication sharedApplication] keyWindow] addSubview:_progressView];
//        [self.view addSubview:_progressView];
    }
}

- (void)setUpdateProgress:(NSInteger)progress
{
    NSLog("Progress is now: %d", _cur);
    [_progressView setPos:_cur];
    
//    _progressView.curValue = _cur;
//    _progressView.percentLabel.text = [NSString stringWithFormat:@"Download (%d / %d)", _cur, _tot];
}


- (void)showUpdateProgress
{
    _tot = [[UserContext shared].updateCount floatValue];
    _cur = 0;
    
//    if (_tot > 0) {
//        _progressView.hidden = NO;
//    }
    [_progressView start:_cur total:_tot];

}

- (void)hideUpdateProgress
{
    if (_studentSaveDone && _facultySaveDone && _staffSaveDone) {
        NSLog(@"\n........................\n..... progress done .....\n.........................");
        [self.savedTimer invalidate];
        self.savedTimer = nil;

//    [_progressView setHidden:YES];   // sun
        [_progressView stop];
        
        // 즐겨찾기 업데이트 목록 저장이 끝나면, 업데이트 카운트 리셋
        [UserContext shared].updateCount = @"0";
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:kUpdateCount];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
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

- (void)requestFirst
{
    NSMutableArray *mutableRequests = [NSMutableArray array];
    
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    
    NSDictionary *classParam = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};
    NSDictionary *majorParam = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};


    NSMutableURLRequest *requestClass = [[SMNetworkClient sharedClient] requestWithMethod:@"POST" path:apiClassesKey parameters:classParam];
    NSMutableURLRequest *requestMajor = [[SMNetworkClient sharedClient] requestWithMethod:@"POST" path:apiMajorKey parameters:majorParam];
    
    
//    for (NSString *URLString in [NSArray arrayWithObjects:apiClassesKey, apiMajorKey, nil]) {
//        [mutableRequests addObject:[[SMNetworkClient sharedClient] requestWithMethod:@"POST" path:URLString parameters:classParam]];
//    }
    [mutableRequests setArray:@[requestClass, requestMajor]];
    NSLog(@"reqeust server multiple API !");
    
    __block NSDictionary *parsedObject1, *parsedObject2;
    [[SMNetworkClient sharedClient]
     enqueueBatchOfHTTPRequestOperationsWithRequests:mutableRequests
     progressBlock:^(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations) {
         NSLog(@"%lu of %lu Completed", (unsigned long)numberOfCompletedOperations, (unsigned long)totalNumberOfOperations);
     }
     completionBlock:^(NSArray *operations) {
         NSError *thisError;
        
         // 기수 목록
         parsedObject1 = [NSJSONSerialization JSONObjectWithData:[[operations objectAtIndex:0] responseData] options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&thisError];
//         NSLog(@"Completion: %@", parsedObject1);
         
         [_courses setArray:parsedObject1[@"data"]];
         NSLog(@"과정 기수 목록 (%d) : %@", [_courses count], _courses);
         
         // DB 저장 (과정 기수 목록)
         [self setLocalCourseClasses:_courses];
//         [self onUpdateDBCourse:_courses];
         
         
         // 교수 전공 목록
         parsedObject2 = [NSJSONSerialization JSONObjectWithData:[[operations objectAtIndex:1] responseData] options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&thisError];
//         NSLog(@"Completion2: %@", parsedObject2 );
         
         [_majors setArray:parsedObject2[@"data"]];
         NSLog(@"전공 목록 (%d) : %@", [_majors count], _majors);
         
         // 전공목록 DB 저장.
         [self setLocalMajors:_majors];
//         [self saveDBMajors:_majors];

    }];
}

/// 각 과정별 기수 목록 서버로 요청
- (void)requestAPIClasses
{
    NSLog(@"---------- start ----------");
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};

    // 과정별 기수 목록
    [[SMNetworkClient sharedClient] postClasses:param
                                          block:^(NSArray *result, NSError *error) {
                                              NSLog(@"수신 기수 목록 개수 (%d)", [result count]);
                                              
                                              if (error) {
                                                  [[SMNetworkClient sharedClient] showNetworkError:error];
                                              }
                                              else
                                              {
                                                  // 과정 기수 목록
                                                  [_courses setArray:result];
                                                  NSLog(@".......... SAVE DB CourseClasses .........");
#if (0)
                                                  [self performSelector:@selector(setLocalCourseClasses:) withObject:result];
//                                                  [self setLocalCourseClasses];
#else
                                                  // DB 저장 (과정 기수 목록)
                                                  [self saveDBCourseClasses:result];
                                                  NSLog(@".......... updateDBFavorites .........");
                                                  [self performSelector:@selector(saveDBFavoriteUpdates) withObject:nil];
#endif
                                              }
                                          }];
    NSLog(@"---------- end ----------");
}


#pragma mark (교수)전공목록 서버로 요청
- (void)requestAPIMajors
{
    NSLog(@"---------- start ----------");
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};

    // 전공 전공 목록
    [[SMNetworkClient sharedClient] postMajors:param
                                         block:^(NSArray *result, NSError *error) {
                                             NSLog(@"수신 전공 목록(%d) : %@", [result count], result);

                                             if (error) {
                                                 [[SMNetworkClient sharedClient] showNetworkError:error];
                                             }
                                             else
                                             {
                                                 [_majors setArray:result];
                                                 NSLog(@".......... SAVE DB MAJORS .........");
#if (0)
                                                 [self performSelector:@selector(setLocalMajors:) withObject:result];
//                                                 [self setLocalMajors:result];
#else
                                                 // 전공목록 DB 저장.
                                                 [self saveDBMajors:result];
                                                 
//                                                 NSLog(@".......... SET DB MAJORS .........");
//                                                 [self performSelector:@selector(updateDBFavorites) withObject:nil];
#endif
                                             }
                                             
                                         }];
    
    NSLog(@"---------- end ----------");
}

#pragma mark 서버로 즐겨찾기 목록 요청
/// 업데이트된 즐겨찾기 목록 (updatecount > 0)
- (void)requestAPIFavorites
{
    NSLog(@"---------- start ----------");
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    NSString *lastUpdate = [UserContext shared].lastUpdateDate;
    
    if (!mobileNo || !userId | !certNo || !lastUpdate) {
        return;
    }
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo, @"updatedate":lastUpdate};

    _studentSaveDone = NO;
    _facultySaveDone = NO;
    _staffSaveDone = NO;
    _cur = 0;
    
    // 업데이트가 있을때만, 로딩 프로그래스 시작...
    NSLog(@"---------- Progress Show ----------");
    [self showUpdateProgress];
    
    // 즐겨찾기 업데이트 목록
    [[SMNetworkClient sharedClient] postFavorites:param
                                            block:^(NSDictionary *result, NSError *error) {
                                                NSLog(@"수신된 업데이트 목록(%d)", [result count]);

                                                if (error) {
                                                    [[SMNetworkClient sharedClient] showNetworkError:error];
                                                }
                                                else
                                                {
                                                    // 즐겨찾기 업데이트 수신 후, 현재 시간을 마지막 업데이트 시간으로 저장
                                                    {
                                                        NSDate *date = [NSDate date];
                                                        NSString *displayString = [date string];
                                                        NSLog(@"즐겨찾기 업데이트 시간? %@", displayString);
                                                    
                                                        [UserContext shared].lastUpdateDate = displayString;
                                                        [[NSUserDefaults standardUserDefaults] setValue:displayString forKey:kLastUpdate];
                                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                                    }
                                                    NSLog(@"... 즐겨찾기 목록 수신 후 업데이트 시간 저장 : %@", [UserContext shared].lastUpdateDate);
                                                    
                                                    [_updateInfo setDictionary:result];
                                                    NSLog(".......... onUpdateDBFavorites (업데이트 저장 하자.) ..........");
#if (1)
//                                                    [self onUpdateDBFavorites:_updateInfo];
                                                    [self performSelector:@selector(saveDBFavoriteUpdates) withObject:nil];
#else
                                                    // 과정 기수 목록을 DB에 저장하고 tableView 업데이트
//                                                    NSDictionary *favoriteInfo = [result valueForKeyPath:@"data"];
                                                    
    //                                                [self onUpdateDBFavorites:favoriteInfo];
    //                                                 NSLog(@"Thread3 - 5");
//                                                    [_updateInfo setDictionary:favoriteInfo];
                                                    [_updateInfo setDictionary:result];
                                                    NSLog(@"즐겨찾기 업데이트 목록 (%d) : %@", [_updateInfo count], _updateInfo);
                                                    
                                                    [self performSelector:@selector(saveDBFavoriteUpdates) withObject:nil];
#endif
                                                }
                                            }];
    NSLog(@"---------- end ----------");
}


#pragma mark - Callback methods
- (void)myProgressTask:(id)sender
{
    NSLog(@"----- progress callback (stop) -----");

    [self hideUpdateProgress];
    
    
//    if ([sender isKindOfClass:[UIProgressView class]]) {
//        UIProgressView *progressBar = (UIProgressView *)sender;
//        
//        float progress = 0.0f;
//        while (progress < 1.0f) {
//            progress += 0.01f;
//            progressBar.progress = progress;
//            NSLog(@"progress : %f", progressBar.progress);
//            usleep(1000);
//        }
//    }
//    MBProgressHUD *hud = (MBProgressHUD *)[self.navigationController.view viewWithTag:77777];
//    if (hud != nil)
//    {
//        float progress = 0.0f;
//        while (progress < 1.0f) {
//            progress += 0.01f;
//            hud.progress = progress;
////            NSLog(@"progress : %f", hud.progress);
//            usleep(4000);
//        }
//    }
}

- (void)saveDBFavoriteUpdates
{
    NSLog(@"---------- START ----------");
    NSLog(@"교수전공 (%d), 기수 (%d), 즐겨찾기 업데이트 (%d)", [_majors count], [_courses count], [_updateInfo count]);
    if ([_courses count] > 0 && [_updateInfo count] > 0)
    {
        [self saveDBFavorite:_updateInfo];
    }
    NSLog(@"---------- END ----------");
}

#pragma mark - CoreData methods
/// load DB
//- (void)executeFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *objects, NSError *error))completion {
//}

/// 로컬 기수 목록 읽어오기
- (void)getLocalFavoriteClasses:(NSString *)info
{
#if (1)
    NSLog(@"---------- start ----------");
//    dispatch_async(dispatch_get_main_queue(), ^{
    
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
        
        [_moc performBlock:^{
            NSLog(@"_moc performBlock");
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(course == 'FACULTY') OR (course == 'STAFF') OR (favyn == 'y')"];
            [fetchRequest setPredicate:predicate];
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
            NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];

            NSError *error;
            NSArray *objects = [_moc executeFetchRequest:fetchRequest error:&error];
//            [_moc executeFetchRequest:fetchRequest
//                           completion:^(NSArray *objects, NSError *error) {
           NSLog(@"executeFetchRequest completion object ( %d )", [objects count]);
           
           if (info) {
               if ([info intValue] > 0) {
                   NSLog(@"서버로 요청 : %@", info);
                   [self performSelector:@selector(requestAPIClasses) withObject:nil];
               }
           }
           
           if ([objects count] > 0)
           {
               NSLog(@"update GUI");
               [_favorites setArray:objects];
               
//                                   dispatch_async(dispatch_get_main_queue(), ^{
                   NSLog(@"TableView reloadData");
                   // 즐겨찾기 목록 테이블 뷰 적용
                   [_favoriteTableView reloadData];
                   
                   // 즐겨찾기 목록 메뉴 적용
                   MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
                   [menu setAddrMenuList:self.favorites];
                   
//                                   });
           }
           else
           {
               NSLog(@".......... requestAPIClasses ..........");
               [self performSelector:@selector(requestAPIClasses) withObject:nil];
           }
           NSLog(@"end.....");
//                           }]; // exet
            
            // save document
        }];
        
//    }); // dispatch
    //    dispatch_release(majorQueue);
    NSLog(@"---------- end ----------");

#else
    NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundMOC setParentContext:_mainMoc];

    [backgroundMOC performBlock:^{
        NSLog(@"backgroundMOC performBlock:");
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:backgroundMOC];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(course == 'FACULTY') OR (course == 'STAFF') OR (favyn == 'y')"];
        [fetchRequest setPredicate:predicate];
        
        // order by (ZCOURSECLASS, ZCOURSE)
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
        
        NSError *error = nil;
        NSLog(@"backgroundMOC executeFetchRequest.");
        NSArray *fetchedObjects = [backgroundMOC executeFetchRequest:fetchRequest error:&error];
        NSLog(@"DB result cnt : %d", [fetchedObjects count]);
        
        for (Course *class in fetchedObjects) {
            NSLog(@"Background DB title : %@", class.title);
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"main queue");

            [_mainMoc performBlock:^{
                NSLog(@"mainMoc performBlock:");

                if (fetchedObjects)
                {
                    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
                    
                    for (NSManagedObject *mo in fetchedObjects)
                    {
                        NSManagedObjectID *moid = [mo objectID];
                        NSManagedObject *mainMO = [_mainMoc objectWithID:moid];
                        
                        [objects addObject:mainMO];
                    }

//                    for (Course *class in objects) {
//                        NSLog(@"copy MO title : %@", class.title);
//                    }
                    
                    [_favorites setArray:objects];
                    
//                    for (Course *class in _favorites) {
//                        NSLog(@"maib DB title : %@", class.title);
//                    }
                    NSLog(@"즐겨찾기 테이블 업데이트 (%d) ...", [_favorites count]);

                    if ([_favorites count] > 0)
                    {
                        // 즐겨찾기 목록 테이블 뷰 적용
                        [self.favoriteTableView reloadData];

                        // 즐겨찾기 목록 메뉴 적용
                        MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
                        [menu setAddrMenuList:self.favorites];
                    }
                    else
                    {
                        NSLog(@"기수 목록 없으면 서버로 요청");
                        [self requestAPIClasses];
                    }
                }
                
            }];
            
        });
        
    }];
    NSLog(@"-");
#endif
}

/// 전공 목록 읽어오기
- (void)getLocalMajors:(NSString *)info
{
    NSLog(@"---------- start ----------");
//    dispatch_async(dispatch_get_main_queue(), ^{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Major"];
        
        [_moc performBlock:^{
            NSLog(@"_moc performBlock");

            [_moc executeFetchRequest:fetchRequest
                              completion:^(NSArray *objects, NSError *error) {
                                  NSLog(@"전공 목록 object ( %d )", [objects count]);

                                  if (info && [info intValue] > 0)
//                                  if ([objects count] == 0)
                                  {
                                      NSLog(@".......... requestAPIMajors ..........");
                                      [self performSelector:@selector(requestAPIMajors) withObject:nil];
//                                          [self requestAPIMajors];
                                          NSLog(@"end.....");
                                  }
            }];

            // save document
        }];
    
//    }); // dispatch
//    dispatch_release(majorQueue);
    NSLog(@"---------- end ----------");
}


/// 기수 목록 저장하기
- (void)setLocalCourseClasses:(NSArray *)objects
{
    NSLog(@"---------- start ----------");
//    dispatch_queue_t myQueue = dispatch_queue_create("dbQueue",NULL);
//    dispatch_async(myQueue, ^{
//    dispatch_async(dispatch_get_main_queue(), ^{
    
        for (NSDictionary *dict in objects)
        {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:_moc];
            [fetchRequest setEntity:entity];
            
            NSPredicate *findPredicate = [NSPredicate predicateWithFormat:@"course == %@ AND courseclass == %@", dict[@"course"], dict[@"courseclass"]];
            [fetchRequest setPredicate:findPredicate];
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
            NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
            
            NSError *error;
            NSArray *objects = [_moc executeFetchRequest:fetchRequest error:&error];
//            [_moc executeFetchRequest:fetchRequest
//                           completion:^(NSArray *objects, NSError *error) {
                               NSLog(@"find course object (%d) : %@", [objects count], objects);
                
           Course *mo = nil;
           if ([objects count] > 0) {
               NSLog(@"UPDATE Course");
               mo = objects[0];
           }
           else
           {
               NSLog(@"INSERT Course");
               mo = [NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:_moc];
           }
           
           if (mo) {
               [mo setValuesForKeysWithDictionary:dict];
               NSLog(@"find Class Title : %@", mo.title);
               
//                                // log
//                                NSArray *keys = [[[mo entity] attributesByName] allKeys];
//                                NSLog(@"update backMOC data : %@", [mo dictionaryWithValuesForKeys:keys]);
               
               // 교수, 교직원, 학색 코드 부여
               if ([dict[@"course"] isEqualToString:@"FACULTY"]) {
                   mo.type = @"2";
               } else if ([dict[@"course"] isEqualToString:@"STAFF"]) {
                   mo.type = @"3";
               } else {
                   mo.type = @"1";
               }

           } // mo
           
           NSLog(@"completion end");
            
            
                               
//                           }]; // execute
        } // for
        
        
//        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"Done write courese classes.");
            
            NSError *error;
            if (![self.moc save:&error]) {
                NSLog(@"기수 목록 DB 저장 오류 : %@", [error localizedDescription]);
            }
            else {
                NSLog(@"기수 목록 DB 저장 성공!");
                
                NSLog(@".......... getLocalFavoriteClasses ..........");
                [self performSelector:@selector(getLocalFavoriteClasses:) withObject:nil];
                //                                       [self getLocalFavoriteClasses];
            }
//        });
    
//    });
    
    NSLog(@"---------- end ----------");
}



/// 기수 목록 저장하기
- (void)setLocalMajors:(NSArray *)objects
{
    NSLog(@"---------- start ----------");

    dispatch_queue_t myQueue = dispatch_queue_create("dbQueue",NULL);
    dispatch_async(myQueue, ^{

        for (NSDictionary *dict in objects)
        {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Major"];
            
            NSLog(@"찾기? major(%@).title = %@", dict[@"major"], dict[@"title"]);
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"major == %@", dict[@"major"]];
            [fetchRequest setPredicate:predicate];
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];

            [_moc executeFetchRequest:fetchRequest
                           completion:^(NSArray *objects, NSError *error) {
                               NSLog(@"find major objects ( %d )", [objects count]);

                               Major *mo = nil;
                               if ([objects count] > 0) {
                                   NSLog(@"UPDATE Major");
                                   
                                   mo = (Major *)objects[0];
                               }
                               else
                               {
                                   NSLog(@"INSERT Major");
                                   mo = (Major *)[NSEntityDescription  insertNewObjectForEntityForName:@"Major" inManagedObjectContext:_moc];
//                                          mo.major = dict[@"major"];
//                                          mo.title = dict[@"title"];
//                                          mo.title_en = dict[@"title_en"];
                               }
                               
                               if (mo)
                               {
                                   NSLog(@"set values Major");
                                   [mo setValuesForKeysWithDictionary:dict];
                               }
                               
                               NSLog(@"completion end");

                               dispatch_async(dispatch_get_main_queue(), ^{
                                   NSLog(@"Done write (dispatch_async(dispatch_get_main_queue())");

                                   NSError *error;
                                   if (![self.moc save:&error]) {
                                       NSLog(@"전공 목록 DB 저장 오류 : %@", [error localizedDescription]);
                                   }
                                   else {
                                       NSLog(@"전공 목록 DB 저장 성공!");
                                       NSLog(@"tmp major : %@, title : %@", mo.major, mo.title);
                                       // log
    //                                   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Major"];
    //                                   NSArray *Objects = [_moc executeFetchRequest:fetchRequest error:nil];
    //                                   NSLog(@"DB result cnt : %d", [Objects count]);
    //                                   
    //                                   for (Major *mo in Objects) {
    //                                       NSLog(@"tmp major : %@, title : %@", mo.major, mo.title);
    //                                   }
                                       
                                   }
                               });
                           }];
            
        } // for
        
    });
    NSLog(@"---------- end ----------");
}

/// 로컬 기수 목록 읽어오기
- (void)findLocalClasses
{
    NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundMOC setParentContext:_mainMoc];
    
    [backgroundMOC performBlock:^{
        NSLog(@"backgroundMOC performBlock:");
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:backgroundMOC];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(course == 'FACULTY') OR (course == 'STAFF') OR (favyn == 'y')"];
        [fetchRequest setPredicate:predicate];
        
        // order by (ZCOURSECLASS, ZCOURSE)
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
        
        NSError *error = nil;
        NSLog(@"backgroundMOC executeFetchRequest.");
        NSArray *fetchedObjects = [backgroundMOC executeFetchRequest:fetchRequest error:&error];
        NSLog(@"DB result cnt : %d", [fetchedObjects count]);
        
        for (Course *class in fetchedObjects) {
            NSLog(@"Background DB title : %@", class.title);
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"main queue");
            
            [_mainMoc performBlock:^{
                NSLog(@"mainMoc performBlock:");
                
                if (fetchedObjects)
                {
                    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
                    
                    for (NSManagedObject *mo in fetchedObjects)
                    {
                        NSManagedObjectID *moid = [mo objectID];
                        NSManagedObject *mainMO = [_mainMoc objectWithID:moid];
                        
                        [objects addObject:mainMO];
                    }
                    
                    //                    for (Course *class in objects) {
                    //                        NSLog(@"copy MO title : %@", class.title);
                    //                    }
                    
                    [_favorites setArray:objects];
                    
                    //                    for (Course *class in _favorites) {
                    //                        NSLog(@"maib DB title : %@", class.title);
                    //                    }
                    NSLog(@"즐겨찾기 테이블 업데이트 (%d) ...", [_favorites count]);
                    
                    if ([_favorites count] > 0)
                    {
                        // 즐겨찾기 목록 테이블 뷰 적용
                        [self.favoriteTableView reloadData];
                        
                        // 즐겨찾기 목록 메뉴 적용
                        MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
                        [menu setAddrMenuList:self.favorites];
                    }
                }
                
            }];
            
        });
        
    }];
    NSLog(@"-");
}


- (void)loadDB
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *mainMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [mainMOC setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    
    NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundMOC setParentContext:mainMOC];
    
    __block NSMutableArray *fetchedObjects = [[NSMutableArray alloc] init];
    NSLog(@"Start.");
    
    [backgroundMOC performBlock:^{
        NSLog(@"backgroundMOC performBlock Start.");
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:backgroundMOC];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(course == 'FACULTY') OR (course == 'STAFF') OR (favyn == 'y')"];
        [fetchRequest setPredicate:predicate];
        
        // order by (ZCOURSECLASS, ZCOURSE)
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
        
        NSLog(@"backgroundMOC executeFetchRequest run.");
        [fetchedObjects setArray:[backgroundMOC executeFetchRequest:fetchRequest error:nil]];
//        NSLog(@"DB result : %@", fetchedObjects);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"main queue");
            
            //            [_mainMoc save:nil];
            
            // execute a fetch request on the parent to see the results
            //            NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
            NSLog(@"Done: %@", [mainMOC executeFetchRequest:fetchRequest error:nil]);
        });
        
    }];
    
    NSLog(@"End.");
//    return fetchedObjects;
}

#pragma mark 즐겨찾기 DB 목록 로딩
/// 즐겨찾기 DB 목록 불러오기
- (NSArray *)loadDBFavoriteCourses
{
    NSManagedObjectContext *threadedMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    threadedMoc.parentContext = self.moc;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    
    // where ((ZCOURSE="FACULTY" OR ZCOURSE="STAFF") OR ZFAVYN="y")
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(course == 'FACULTY') OR (course == 'STAFF') OR (favyn == 'y')"];
    [fetchRequest setPredicate:predicate];
    
    // order by (ZCOURSECLASS, ZCOURSE)
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    NSLog(@"즐겨찾기 목록 개수 : %d", [fetchedObjects count]);
    
    // log
    for (Course *class in fetchedObjects) {
        NSLog(@"title : %@", class.title);
    }
    
    
    return fetchedObjects;
}

#pragma mark 기수별 과정목록 DB 추가
/// course classes DB 추가 및 업데이트
- (void)saveDBCourseClasses:(NSArray *)courseClasses
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [parentContext setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    //    [mainMoc setParentContext:writeMoc];
    
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:parentContext];
    
    NSManagedObjectContext *findContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [findContext setParentContext:parentContext];
    
    __block BOOL done = NO;
    
    [childContext performBlock:^{
        
        for (NSDictionary *info in courseClasses)
        {
            Course *course = nil;
            __block NSMutableArray *fetchedObjects = nil;
            NSLog(@"저장할 기수 : %@", info[@"title"]);
            
//            NSArray *fetched = [self findCourses:info];
            [childContext performBlockAndWait:^{
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:parentContext];
                [fetchRequest setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course == %@ AND courseclass == %@", info[@"course"], info[@"courseclass"]];
                [fetchRequest setPredicate:predicate];
                
                NSArray *objects = [childContext executeFetchRequest:fetchRequest error:nil];
                fetchedObjects = [objects mutableCopy];
                NSLog(@"기수 찾았나? %d", [fetchedObjects count]);
            }];
            
            if ([fetchedObjects count] > 0)
            {
                // 기존에 존재하던 기수 과정이면 내용 업데이트
                course = fetchedObjects[0];
                
                // ( NSManagedObject <- NSDictionary )
                NSLog(@"업데이트 (기수)과정 : course(%@), courseclass(%@), title(%@), favyn(%@), count (%@)", course.course, course.courseclass, course.title, course.favyn, course.count);
                course.count = info[@"count"];
                course.course = info[@"course"];
                course.courseclass = info[@"courseclass"];
                course.favyn = info[@"favyn"];
                course.title = info[@"title"];
                course.title_en = info[@"title_en"];
//                course.type = info["type"];
            }
            else
            {
                // 기존 목록에 없으면 추가 (INSERT)
                course = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:childContext];
                
                // ( NSManagedObject <- NSDictionary )
                course.count = info[@"count"];
                course.course = info[@"course"];
                course.courseclass = info[@"courseclass"];
                course.favyn = info[@"favyn"];
                course.title = info[@"title"];
                course.title_en = info[@"title_en"];
//                course.type = info["type"];
                
                // 교수, 교직원, 학색 타입 부여
                if ([info[@"course"] isEqualToString:@"FACULTY"]) {
                    course.type = @"2";
                } else if ([info[@"course"] isEqualToString:@"STAFF"]) {
                    course.type = @"3";
                } else {
                    course.type = @"1";
                }

                NSLog(@"추가 (기수)과정(%@) : course(%@), courseclass(%@), title(%@), favyn(%@), count (%@)", course.type, course.course, course.courseclass, course.title, course.favyn, course.count);
            }
            
            NSLog(@"(%@)과정 목록 DB 저장 성공!", course.courseclass);
            [childContext save:nil];
            
        } // for
        
        done = YES;
        NSLog(@"..... course done .....");
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"Saving parent");
            [parentContext save:nil];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
            NSArray *objects = [parentContext executeFetchRequest:request error:nil];
            NSLog(@"Done(Course): %d objects written \nobjects: %@", [objects count], objects);
            
            // 업데이트된 (기수)과정 목록 즐겨찾기 화면에 반영
            [_favorites setArray:[self loadDBFavoriteCourses]];
            
            for (Course *tmp in objects) {
                NSLog(@"old Objects : %@, %@", tmp.courseclass, tmp.title);
            }
            
            if ([_favorites count] > 0) {
                NSLog(@".......... updateTable ..........");
                [self refreshFavoriteTable];
//                [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
            }

        });
        
    }]; // childContext
    
    // execute a read request after 0.5 second
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
        [parentContext performBlockAndWait:^{
            
            NSArray *objects = [parentContext executeFetchRequest:request error:nil];
            NSLog(@"In between read: read %d objects", [objects count]);
        }];
    });
    NSLog(@"---------- END ----------");
}

#pragma mark 교수 전공 목록 DB 저장
/// major DB 추가 및 업데이트
- (void)saveDBMajors:(NSArray *)majors
{
    NSLog(@"---------- START ----------");
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [parentContext setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    //    [mainMoc setParentContext:writeMoc];
    
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:parentContext];
    
    NSManagedObjectContext *findContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [findContext setParentContext:parentContext];
    
//    NSLog(@"parent: %@,   child : %@,    find: %@,  main : %@", parentContext, childContext, findContext, appDelegate.managedObjectContext);
    __block BOOL done = NO;
    
    [childContext performBlock:^{

        for (NSDictionary *info in majors)
        {
            Major *major = nil;
            __block NSMutableArray *fetchedObjects = nil;

//            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Major"];
            
            // 이미 존재하는 전공인지 확인
            [childContext performBlockAndWait:^{
                NSLog(@"찾을 전공 : %@, %@", info[@"major"], info[@"title"]);
                
                NSEntityDescription * entity = [NSEntityDescription entityForName:@"Major" inManagedObjectContext:parentContext];
                [fetchRequest setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"major == %@", info[@"major"]];
                [fetchRequest setPredicate:predicate];
                
                NSArray *array = [childContext executeFetchRequest:fetchRequest error:nil];
                fetchedObjects = [array mutableCopy];
                NSLog(@"찾은 전공 개수 : %d", [fetchedObjects count]);

            }]; // childContext

            if ([fetchedObjects count] > 0)
            {
                major = fetchedObjects[0];
                
                // ( NSManagedObject <- NSDictionary )
                major.major = info[@"major"];
                major.title = info[@"title"];
                major.title_en = info[@"title_en"];
                NSLog(@"업데이트 전공 : major(%@), title(%@)", major.major, major.title);
            }
            else
            {
                major = (Major *)[NSEntityDescription insertNewObjectForEntityForName:@"Major" inManagedObjectContext:childContext];

                // ( NSManagedObject <- NSDictionary )
                major.major = info[@"major"];
                major.title = info[@"title"];
                major.title_en = info[@"title_en"];
//                major.facultys;

                NSLog(@"추가 전공 : major(%@), title(%@)", major.major, major.title);
            }
            
            NSLog(@"(%@)전공 DB 저장 성공!", major.title);
            [childContext save:nil];
        }
        
        done = YES;
        NSLog(@"..... major done .....");
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"Saving parent");
            [parentContext save:nil];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Major"];
            NSArray *objects = [parentContext executeFetchRequest:request error:nil];
            NSLog(@"Done(Major): %d objects written \nobjects: %@", [objects count], objects);
            
            for (Major *tmp in objects) {
                NSLog(@"old Objects : %@, %@", tmp.major, tmp.title);
            }

        });

    }]; // childContext

    // execute a read request after 0.5 second
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Major"];
        [parentContext performBlockAndWait:^{
            
            NSArray *objects = [parentContext executeFetchRequest:request error:nil];
            NSLog(@"In between read: read %d objects", [objects count]);
        }];
    });
    NSLog(@"---------- END ----------");
}

- (void)setFavoriteStudent:(NSArray *)objects
{
    NSLog(@"---------- start ----------");
    dispatch_queue_t myQueue = dispatch_queue_create("dbQueue",NULL);
    dispatch_async(myQueue, ^{
        
        for (NSDictionary *dict in objects)
        {
            NSLog(@"업데이트 학생 : %@", dict[@"name"]);
//            NSArray *filteredCourses = [self filteredCourses:decodeInfo];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            
            // select Table
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:_moc];
            [fetchRequest setEntity:entity];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course == %@ AND courseclass == %@", dict[@"course"], dict[@"courseclass"]];
            [fetchRequest setPredicate:predicate];
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
            NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
            
            [_moc executeFetchRequest:fetchRequest
                           completion:^(NSArray *objects, NSError *error) {
                               NSLog(@"find Student Info : %d", [objects count]);
                               
                               Course *course = nil;
                               
                               if ([objects count] > 0) {
                                   NSLog(@"UPDATE f Course");
                                   course = objects[0];
                               }
                               else {
                                   NSLog(@"INSERT f Course");
                                   course = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:_moc];
                                   
                                   course.course        = dict[@"course"];
                                   course.courseclass   = dict[@"courseclass"];
                                   course.title         = dict[@"classtitle"];
                                   course.title_en      = dict[@"classtitle_en"];
                                   course.favyn         = @"n";
                                   course.type          = @"1";
                               }
                               
                               if (course) {
                                   //- 학생 검색 하여 기수에 해당 학생 정보 삽입
                                   NSArray *filteredObjects = [self filteredObjects:dict[@"studcode"] memberType:MemberTypeStudent];
                                   Student *student = nil;
                                   
                                   if ([filteredObjects count] > 0)
                                   {
                                       // 로컬 DB에 존재하면 업데이트
                                       student = filteredObjects[0];
                                   }
                                   else
                                   {
                                       // 로컬 DB에 없으면 추가 (INSERT)
                                       student = (Student *)[NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:_moc];
                                       student.studcode = dict[@"studcode"];
                                   }
                                   
                                   // ( NSManagedObject <- NSDictionary )
                                   //[student setValuesForKeysWithDictionary:dict];
                                   student.name = dict[@"name"];
                                   student.name_en = dict[@"name_en"];
                                   student.classtitle = dict[@"classtitle"];
                                   student.classtitle_en = dict[@"classtitle_en"];
                                   student.mobile = dict[@"mobile"];
                                   student.email = dict[@"email"];
                                   student.company = dict[@"company"];
                                   student.company_en = dict[@"company_en"];
                                   student.department = dict[@"department"];
                                   student.department_en = dict[@"department_en"];
                                   student.status = dict[@"status"];
                                   student.status_en = dict[@"status_en"];
                                   student.title = dict[@"title"];
                                   student.title_en = dict[@"title_en"];
                                   student.share_company = dict[@"share_company"];
                                   student.share_email = dict[@"share_email"];
                                   student.share_mobile = dict[@"share_mobile"];
                                   student.photourl = dict[@"photourl"];
                                   student.viewphotourl = dict[@"viewphotourl"];
                                   
                                   [course addStudentsObject:student];
                               }
                               NSLog(@"Saved 1 Student");
                               
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   NSLog(@"Done write (dispatch_async(dispatch_get_main_queue())");
                                   
                                   NSError *error;
                                   if (![_moc save:&error]) {
                                       NSLog(@"학생 DB 저장 오류 : %@", [error localizedDescription]);
                                   } else {
                                       NSLog(@"...... 즐겨찾기 학생 저장 완료 .....");
                                   }
                               });

                           }];
            
        }
            
    });
}

#pragma mark 업데이트 (학생) 목록 저장
- (void)saveDBFavoriteStudent:(NSArray *)students
{
    NSLog(@"----- 학생목록 저장 시작 -----");
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    NSManagedObjectContext *writeMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    [writeMoc setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];

    NSManagedObjectContext *parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [parentContext setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
//    [mainMoc setParentContext:writeMoc];

    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:parentContext];

    NSManagedObjectContext *findContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [findContext setParentContext:parentContext];

    NSEntityDescription *courseEntity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:parentContext];
//    NSLog(@"parent: %@,   child : %@,    find: %@,  main : %@", parentContext, childContext, findContext, appDelegate.managedObjectContext);
    __block BOOL done = NO;
    
    [childContext performBlock:^{
        
        for (NSDictionary *info in students)
        {
            NSLog(@"학생(%@) 저장", info[@"name"]);
            
            Course *course = nil;
            Student *student = nil;
            __block NSArray *findCourses = nil;

            NSFetchRequest *courseFr = [[NSFetchRequest alloc] init];

            [childContext performBlockAndWait:^{
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
//                course = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:_moc];
//                course = [[Course alloc] initWithEntity:courseEntity insertIntoManagedObjectContext:childContext];
//                course.course = info[@"course"];
//                course.courseclass = info[@"courseclass"];
//                course.title = info[@"classtitle"];
//                course.title_en = info[@"classtitle_en"];
//                course.favyn = @"n";
//                course.type = @"1";
//                NSLog(@"추가 Course : %@", course.courseclass);
//                NSLog(@"..... Saving child (course)");
//                [childContext save:nil];
            }
            
            ++_cur;
            NSLog(@"..... 학생 저장 중 (%d)", _cur);
            [childContext save:nil];
            
        } // for
        
        done = YES;
        _studentSaveDone = YES;
        NSLog(@"..... student done .....");
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSLog(@"Saving parent");
            [parentContext save:nil];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
            NSLog(@"Done(학생): %d objects written", [[parentContext executeFetchRequest:request error:nil] count]);
//            [_progressView setHidden:YES];   // test
            [self hideUpdateProgress];
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

    
#if (0)
    for (NSDictionary *dict in students)
    {
        NSLog(@"저장 학생 : %@", dict[@"name"]);
        
        // 학생 기수 검색
        NSArray *fetched = [self findCourses:dict];
        Course *course = nil;
        
        if ([fetched count] > 0) {
            course = fetched[0];
            NSLog(@"UPDATE Course : %@", course.courseclass);
        }
        else {
            course = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:_moc];
            course.course = dict[@"course"];
            course.courseclass = dict[@"courseclass"];
            course.title = dict[@"classtitle"];
            course.title_en = dict[@"classtitle_en"];
            course.favyn = @"n";
            course.type = @"1";
            NSLog(@"INSERT Course : %@", course.courseclass);
        }
        
        // 학생 검색
        NSArray *filteredObjects = [self filteredObjects:dict[@"studcode"] memberType:MemberTypeStudent];
        Student *student = nil;
        
        if ([filteredObjects count] > 0) {
            student = filteredObjects[0];
            NSLog(@"UPDATE Student : %@", student.studcode);
        }
        else {
            student = (Student *)[NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.moc];
            student.studcode = dict[@"studcode"];
            NSLog(@"INSERT Course : %@", student.studcode);
        }
        
        // ( NSManagedObject <- NSDictionary )
        //[student setValuesForKeysWithDictionary:dict];
        student.name = dict[@"name"];
        student.name_en = dict[@"name_en"];
        student.classtitle = dict[@"classtitle"];
        student.classtitle_en = dict[@"classtitle_en"];
        student.mobile = dict[@"mobile"];
        student.email = dict[@"email"];
        student.company = dict[@"company"];
        student.company_en = dict[@"company_en"];
        student.department = dict[@"department"];
        student.department_en = dict[@"department_en"];
        student.status = dict[@"status"];
        student.status_en = dict[@"status_en"];
        student.title = dict[@"title"];
        student.title_en = dict[@"title_en"];
        student.share_company = dict[@"share_company"];
        student.share_email = dict[@"share_email"];
        student.share_mobile = dict[@"share_mobile"];
        student.photourl = dict[@"photourl"];
        student.viewphotourl = dict[@"viewphotourl"];
        
        [course addStudentsObject:student];
    }
#endif
//    [ModelUtil saveDataInBackgroundWithContext:^(NSManagedObjectContext *context) {
//        NSLog(@".......... 학생 저장 중 ..........");
//        
//    } completion:^{
//        NSLog(@".......... 학생 저장 완료 ..........");
//    }];

    NSLog(@"----- 학생목록 저장 종료 -----");
}

#pragma mark 업데이트 (교수) 목록 저장
- (void)saveDBFavoriteFaculty:(NSArray *)objects
{
    NSLog(@"----- 교수 목록 저장 시작 -----");
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [parentContext setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    //    [mainMoc setParentContext:writeMoc];
    
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:parentContext];
    
    NSManagedObjectContext *findContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [findContext setParentContext:parentContext];
    
//    NSLog(@"parent: %@,   child : %@,    find: %@,  main : %@", parentContext, childContext, findContext, appDelegate.managedObjectContext);
    __block BOOL done = NO;
    
    [childContext performBlock:^{
        
        for (NSDictionary *info in objects)
        {
            // 교수 전공 검색
            Major *major = nil;
            Faculty *faculty = nil;
            __block NSArray *findMajors = nil;
            
            [findContext performBlockAndWait:^{
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Major" inManagedObjectContext:parentContext];
                [fetchRequest setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"major == %@", info[@"major"]];
                [fetchRequest setPredicate:predicate];
                
                NSLog(@"(%@)교수의 (%@)전공 검색", info[@"name"], info[@"major"]);
                findMajors = [findContext executeFetchRequest:fetchRequest error:nil];
                NSLog(@"교수의 전공 찾았나? %d", [findMajors count]);
            }];
            
            if ([findMajors count] > 0)
            {
                major = findMajors[0];   // 이미 전공이 있으면 해당 전공을 가져와서 교수 정보 추가
                
                NSArray *majorFaculties = [major.facultys allObjects];
                NSLog(@"교수의 (%@)전공이 이미 존재함", major.major);
                
                // 이미 해당 전공에 교수 정보가 있는지 확인
                NSArray *findArray = [majorFaculties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"memberidx == %@", info[@"memberidx"]]];
                NSLog(@"해당 전공에 교수 찾았나? %d", [findArray count]);
                
                if ([findArray count] > 0)
                {
                    faculty = findArray[0];

                    if ([info[@"remove"] isEqualToString:@"y"]) {
                        NSLog(@"(%@)교수정보 삭제", faculty.name);
                        [major removeFacultysObject:faculty];
                        [childContext deleteObject:faculty];
                    }
                    else {
                        // 등록된 사용자이므로 정보만 업데이트
                        NSLog(@"(%@)교수 업데이트 : %@", faculty.name, faculty.memberidx);
                        faculty.email = info[@"email"];
                        faculty.mobile = info[@"mobile"];
                        faculty.name = info[@"name"];
                        faculty.name_en = info[@"name_en"];
                        faculty.office = info[@"office"];
                        faculty.office_en = info[@"office_en"];
                        faculty.photourl = info[@"photourl"];
                        faculty.tel = info[@"tel"];
                        faculty.viewphotourl = info[@"viewphotourl"];
                    }
                }
                else
                {
                    __block NSMutableArray *anotherArray = nil;
                    
                    [childContext performBlockAndWait:^{
                        NSLog(@"교수가 다른 전공에 정보가 있는지 조회");
                        NSFetchRequest *fetchedRequest = [[NSFetchRequest alloc] init];
                        
                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:parentContext];
                        [fetchedRequest setEntity:entity];
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberidx == %@", info[@"memberidx"]];
                        [fetchedRequest setPredicate:predicate];
                        
                        NSArray *array = [childContext executeFetchRequest:fetchedRequest error:nil];
                        anotherArray = [array mutableCopy];
                        NSLog(@"다른 전공에 교수가 존재하나? %d", [anotherArray count]);

                    }];
                    
                    if ([anotherArray count] > 0)
                    {
                        Faculty *anotherFaculty = anotherArray[0];
                        NSLog(@"교수(%@)의 전공이 달려저서 이전 전공 삭제. (%@ -> %@)", anotherFaculty.name, anotherFaculty.major, info[@"major"]);
                        [anotherFaculty.major removeFacultysObject:anotherFaculty];
                    }

                    NSManagedObjectContext *context = [major managedObjectContext];
                    Faculty *newFaculty = [NSEntityDescription insertNewObjectForEntityForName:@"Faculty" inManagedObjectContext:context];
                    newFaculty.memberidx = info[@"memberidx"];
                    NSLog(@"해당 전공에 교수(%@) 추가 : %@", info[@"name"], newFaculty.memberidx);
                    
                    newFaculty.email = info[@"email"];
                    newFaculty.mobile = info[@"mobile"];
                    newFaculty.name = info[@"name"];
                    newFaculty.name_en = info[@"name_en"];
                    newFaculty.office = info[@"office"];
                    newFaculty.office_en = info[@"office_en"];
                    newFaculty.photourl = info[@"photourl"];
                    newFaculty.tel = info[@"tel"];
                    newFaculty.viewphotourl = info[@"viewphotourl"];
                    newFaculty.major = major;

                    NSLog(@"전공 컨텍스트로 저장 (%@ ======= %@)", context, childContext);
                    [context save:nil];

                }
            }
            else {
                NSLog(@"교수의 해당 전공(%@)이 없으면 오류 !!!!!!!!!!", info[@"major"]);
//                NSLog(@"INSERT Major");
//                major = (Major *)[NSEntityDescription insertNewObjectForEntityForName:@"Major" inManagedObjectContext:_moc];
//                major.major = info[@"major"];
            }
            
            ++_cur;
            NSLog(@"..... 교수 저장 중 (%d)", _cur);
            [childContext save:nil];
            
        } // for
        
        done = YES;
        _facultySaveDone = YES;
        NSLog(@"..... student done .....");
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSLog(@"Saving parent");
            [parentContext save:nil];
            
            NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Faculty"];
            NSLog(@"Done(교수): %d objects written", [[parentContext executeFetchRequest:fr error:nil] count]);
            [self hideUpdateProgress];
            
        });
        
    }]; // childContext
    
    // execute a read request after 0.5 second
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Faculty"];
        [parentContext performBlockAndWait:^{
            NSArray *object = [parentContext executeFetchRequest:fr error:nil];
            NSLog(@"In between read: 교수 %d objects", [object count]);
//            NSLog(@"object : %@", object);
            
        }];
    });

    NSLog(@"----- 교수 목록 저장 종료 -----");
}

#pragma mark 업데이트 (교직원) 목록 저장
- (void)saveDBFavoriteStaff:(NSArray *)objects
{
    NSLog(@"----- 교직원 목록 저장 시작 -----");
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [parentContext setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
//    [mainMoc setParentContext:writeMoc];
    
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:parentContext];
    
    NSManagedObjectContext *findContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [findContext setParentContext:parentContext];
    
//    NSLog(@"parent: %@,   child : %@,    find: %@,  main : %@", parentContext, childContext, findContext, appDelegate.managedObjectContext);
    __block BOOL done = NO;
    
    [childContext performBlock:^{
        
        for (NSDictionary *info in objects)
        {
            // 교직원 검색
            Staff *staff = nil;
            __block NSMutableArray *findStaffes = nil;
            
            NSFetchRequest *staffFr = [[NSFetchRequest alloc] init];
            
            [childContext performBlockAndWait:^{
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Staff" inManagedObjectContext:parentContext];
                [staffFr setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberidx == %@", info[@"memberidx"]];
                [staffFr setPredicate:predicate];
                
                NSLog(@"교직원(%@) 검색", info[@"name"]);
                NSArray *array = [childContext executeFetchRequest:staffFr error:nil];
                findStaffes = [array mutableCopy];
                NSLog(@"교직원 찾았나? %d", [findStaffes count]);
            }];
            
            
            if ([findStaffes count] > 0)
            {
                staff = findStaffes[0]; // 이미 존재하는 교직원은 정보만 업데이트
                
                if ([info[@"remove"] isEqualToString:@"y"])
                {
                    NSLog(@"삭제 staff(%@)", staff.name);
                    [childContext deleteObject:staff];
                }
                else {
                    // 등록된 사용자이므로 정보만 업데이트
                    NSLog(@"업데이트 staff(%@) : %@", staff.name, staff.memberidx);
                    staff.email = info[@"email"];
                    staff.mobile = info[@"mobile"];
                    staff.name = info[@"name"];
                    staff.name_en = info[@"name_en"];
                    staff.office = info[@"office"];
                    staff.office_en = info[@"office_en"];
                    staff.photourl = info[@"photourl"];
                    staff.tel = info[@"tel"];
                    staff.viewphotourl = info[@"viewphotourl"];
                }
            }
            else
            {
                Staff *newStaff = [NSEntityDescription insertNewObjectForEntityForName:@"Staff" inManagedObjectContext:childContext];
                newStaff.memberidx = info[@"memberidx"];
                
                NSLog(@"(%@)교직원 추가 : %@", info[@"name"], newStaff.memberidx);
                newStaff.email = info[@"email"];
                newStaff.mobile = info[@"mobile"];
                newStaff.name = info[@"name"];
                newStaff.name_en = info[@"name_en"];
                newStaff.office = info[@"office"];
                newStaff.office_en = info[@"office_en"];
                newStaff.photourl = info[@"photourl"];
                newStaff.tel = info[@"tel"];
                newStaff.viewphotourl = info[@"viewphotourl"];
            }
            
            ++_cur;
            NSLog(@"..... Saving child (교직원)");
            [childContext save:nil];
            
        } // for
        
        done = YES;
        _staffSaveDone = YES;
        NSLog(@"..... staff done .....");
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSLog(@"Saving parent");
            [parentContext save:nil];
            
            NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Staff"];
            NSLog(@"Done(Staff): %d objects written", [[parentContext executeFetchRequest:fr error:nil] count]);
            [self hideUpdateProgress];
            
        });
        
    }]; // childContext
    
    // execute a read request after 0.5 second
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Staff"];
        [parentContext performBlockAndWait:^{
            
            NSArray *object = [parentContext executeFetchRequest:fr error:nil];
            NSLog(@"In between read: (교직원) %d objects", [object count]);
//            NSLog(@"object : %@", object);
        }];
    });
    NSLog(@"----- 교직원 목록 저장 종료 -----");
}

#pragma mark 즐겨찾기 업데이트 목록 저장
/// course classes DB 추가 및 업데이트
- (void)saveDBFavorite:(NSDictionary *)updateInfo
{
    NSLog(@"----------- saveDBFavorite START ----------");
    self.savedTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(setUpdateProgress:) userInfo:nil repeats:YES];

    if ([updateInfo[@"student"] isKindOfClass:[NSArray class]])
    {
        NSArray *students = updateInfo[@"student"];
        NSLog(@".......... 학생 저장 [%d] ..........", [students count]);
        [self saveDBFavoriteStudent:students];
    }

    if ([updateInfo[@"faculty"] isKindOfClass:[NSArray class]])
    {
        NSArray *students = updateInfo[@"faculty"];
        NSLog(@".......... 교수 저장 [%d] ..........", [students count]);
        [self saveDBFavoriteFaculty:students];
    }
    
    if ([updateInfo[@"staff"] isKindOfClass:[NSArray class]])
    {
        NSArray *students = updateInfo[@"staff"];
        NSLog(@".......... 교직원 저장 [%d] ..........", [students count]);
        [self saveDBFavoriteStaff:students];
    }
    
    NSLog(@"----------- END ----------");
    return;
    
//    [self showUpdateProgress];

//    dispatch_queue_t queue3 = dispatch_queue_create("dbqueue3", NULL);
//    dispatch_async(queue3, ^{
//    dispatch_async(dispatch_get_main_queue(), ^{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
    NSError *error = nil;

    NSLog("... 학생 목록 저장");
    if ([updateInfo[@"student"] isKindOfClass:[NSArray class]])
    {
        NSArray *students = updateInfo[@"student"];
        NSLog(@"즐겨찾기 업데이트 학생 수 [%d]", [students count]);
        
        [self performSelectorInBackground:@selector(setUpdateProgress:) withObject:nil];

        for (NSDictionary *dict in students)
        {
            // DB에 현재 학생의 기수가 존재하면 해당 기수에 학생을 추가하도록 함. (relationship 연결 처리)
            NSLog(@"저장할 학생 : %@", dict[@"name"]);
            
            //- 학생의 기수 종류 먼저 검색
            Course *course = nil;
            NSArray *fetched = [self findCourses:dict];
            
            if ([fetched count] > 0) {
                NSLog(@"UPDATE Course");
                course = fetched[0];
            }
            else {
                NSLog(@"INSERT Course");
                course = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:_moc];
                course.course = dict[@"course"];
                course.courseclass = dict[@"courseclass"];
                course.title = dict[@"classtitle"];
                course.title_en = dict[@"classtitle_en"];
                course.favyn = @"n";
                course.type = @"1";
            }
            
            //- 학생 검색 하여 기수에 해당 학생 정보 삽입
            NSArray *filteredObjects = [self filteredObjects:dict[@"studcode"] memberType:MemberTypeStudent];
            Student *student = nil;
            
            if ([filteredObjects count] > 0) {
                // 로컬 DB에 존재하면 업데이트
                student = filteredObjects[0];
            }
            else {
                // 로컬 DB에 없으면 추가 (INSERT)
                student = (Student *)[NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.moc];
                student.studcode = dict[@"studcode"];
            }

            // ( NSManagedObject <- NSDictionary )
            //[student setValuesForKeysWithDictionary:dict];
            student.name = dict[@"name"];
            student.name_en = dict[@"name_en"];
            student.classtitle = dict[@"classtitle"];
            student.classtitle_en = dict[@"classtitle_en"];
            student.mobile = dict[@"mobile"];
            student.email = dict[@"email"];
            student.company = dict[@"company"];
            student.company_en = dict[@"company_en"];
            student.department = dict[@"department"];
            student.department_en = dict[@"department_en"];
            student.status = dict[@"status"];
            student.status_en = dict[@"status_en"];
            student.title = dict[@"title"];
            student.title_en = dict[@"title_en"];
            student.share_company = dict[@"share_company"];
            student.share_email = dict[@"share_email"];
            student.share_mobile = dict[@"share_mobile"];
            student.photourl = dict[@"photourl"];
            student.viewphotourl = dict[@"viewphotourl"];

            [course addStudentsObject:student];
            
//            NSLog(@"UPDATE 즐겨찾기 학생 : course(%@ = %@), courseclass(%@ = %@), title(%@ = %@), title_en(%@), favyn(%@), count (%@), students(%d) ",
//                  course.course, dict[@"course"], course.courseclass, dict[@"courseclass"], course.title, dict[@"classtitle"], course.title_en, course.favyn, course.count, [course.students count]);
//            mo.class_info.course = student[@"course"];
//            mo.class_info.courseclass = student[@"courseclass"];
//            mo.class_info.title = student[@"classtitle"];
//            mo.class_info.title_en = student[@"classtitle_en"];

            ++_cur;
            NSLog(@"학생 프로그래스 세팅(%d) : %f", _cur, (CGFloat)((_cur * 10) / _tot));
            if ((_cur % 10) == 0) {
//                [self performSelectorInBackground:@selector(setUpdateProgress:) withObject:nil];
            }
        }
//        [self.moc save:&error];
//            NSLog(@"학생 업데이트 목록 저장 완료!");
    }

    NSLog("... 교수 목록 저장");
    if ([updateInfo[@"faculty"] isKindOfClass:[NSArray class]])
    {
        // 교수 목록이 있으면 학생 테이블 추가(업데이트)
        NSArray *facultys = updateInfo[@"faculty"];
        NSLog(@"즐겨찾기 업데이트 교수 수 [%d]", [facultys count]);
        
        for (NSDictionary *dict in facultys)
        {
            NSLog(@"저장할 교수 : %@", dict[@"name"]);
            
            //- 교수 전공 종류 먼저 검색
            Major *major = nil;
            NSArray *fetchedMajors = [self findMajors:dict];
            
            if ([fetchedMajors count] > 0) {
                NSLog(@"UPDATE Major");
                major = fetchedMajors[0];
            }
            else {
                NSLog(@"INSERT Major");
                major = (Major *)[NSEntityDescription insertNewObjectForEntityForName:@"Major" inManagedObjectContext:_moc];
                major.major = dict[@"major"];
            }

            // 교수 검색하여 해당 전공에 교수 정보 삽입
            NSArray *filteredObjects = [self filteredObjects:dict[@"memberidx"] memberType:MemberTypeFaculty];
            Faculty *faculty = nil;
            
            if ([filteredObjects count] > 0) {
                NSLog(@"UPDATE Faculty");
                faculty = filteredObjects[0];
            }
            else
            {
                NSLog(@"INSERT Faculty");
                faculty = (Faculty *)[NSEntityDescription insertNewObjectForEntityForName:@"Faculty" inManagedObjectContext:_moc];
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
            faculty.name    = dict[@"name"];
            faculty.name_en = dict[@"name_en"];
            faculty.tel     = dict[@"tel"];
            faculty.mobile  = dict[@"mobile"];
            faculty.email   = dict[@"email"];
            faculty.office  = dict[@"office"];
            faculty.office_en = dict[@"office_en"];
            faculty.photourl = dict[@"photourl"];
            faculty.viewphotourl = dict[@"viewphotourl"];

            [major addFacultysObject:faculty];
            
//            NSLog(@"UPDATE 즐겨찾기 교수 : memberIdx(%@) major(%@ = %@), title(%@ = %@), title_en(%@), facultys(%d)",
//                  dict[@"memberIdx"], major.major, dict[@"major"], major.title, dict[@"title"], major.title_en, [major.facultys count]);
            
//            mo.major.major = faculty[@"major"];
            
                ++_cur;
                NSLog(@"교수 프로그래스 세팅(%d) : %f", _cur, (CGFloat)((_cur * 10) / _tot));
//                [self updateProgress:_cur];
//            [_progressView setPos:_cur];
        }
//        [self performSelectorInBackground:@selector(setUpdateProgress:) withObject:nil];
//        [self.moc save:&error];
//            NSLog(@"교수 업데이트 목록 저장 완료!");

    }

    NSLog("... 교직원 목록 저장");
    if ([updateInfo[@"staff"] isKindOfClass:[NSArray class]])
    {
        // 교직원 목록이 있으면 학생 테이블 추가(업데이트)
        NSArray *staffs = updateInfo[@"staff"];
        NSLog(@"저장할 교직원 개수 (%d)", [staffs count]);
        
        for (NSDictionary *dict in staffs)
        {
            NSLog(@"저장할 교직원 : %@", dict[@"name"]);
            
            NSArray *filteredObjects = [self filteredObjects:dict[@"memberidx"] memberType:MemberTypeStaff];
            Staff *mo = nil;
            
            if ([filteredObjects count] > 0)
            {
                NSLog(@"UPDATE Staff");
                mo = filteredObjects[0];
            }
            else
            {
                NSLog(@"INSERT Staff");
                mo = (Staff *)[NSEntityDescription insertNewObjectForEntityForName:@"Staff" inManagedObjectContext:_moc];
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
            mo.viewphotourl = dict[@"viewphotourl"];
            
            NSLog(@"UPDATE 즐겨찾기 교직원 : memberIdx(%@), name(%@), name_en(%@), tel(%@)", mo.memberidx, mo.name, mo.name_en, mo.tel);
            
            ++_cur;
            NSLog(@"교직원 프로그래스 세팅(%d) : %f", _cur, (CGFloat)((_cur * 10) / _tot));
            if ((_cur % 10) == 0) {
//                [self performSelectorInBackground:@selector(setUpdateProgress:) withObject:nil];
            }

//            [self performSelectorInBackground:@selector(setUpdateProgress:) withObject:nil];
//            [self updateProgress:_cur];
//            [_progressView setPos:((count * 10) / maxItem)];
        }
        
//        [self performSelectorInBackground:@selector(setUpdateProgress:) withObject:nil];
//        [self.moc save:&error];
//        NSLog(@"교직원 업데이트 목록 저장 완료!");

    }
    
//    NSLog(@"프로그래스 세팅 : 10");
//    [_progressView setPos:10];

    if (![self.moc save:&error]) {
        NSLog(@"error : %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"즐겨찾기 업데이트 목록 전체 저장 성공!");

//        [self performSelector:@selector(hideUpdateProgress) withObject:nil];

////        [self performSelectorOnMainThread:@selector(stopDimLoading) withObject:nil waitUntilDone:NO];
////        [_loadingIndicatorView stop];
//        // 즐겨찾기 목록 로컬 DB에서 갱신.
////        [self.favorites setArray:[self loadDBFavoriteCourse]];
    }
//    });// dispatch
    
    
    NSLog(@"----------- END ----------");
}


/// courseclass DB 찾기
- (NSArray *)fetchedCourses:(NSDictionary *)info
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // select Table
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.moc];
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
    NSArray *filtered = [self.moc executeFetchRequest:fetchRequest error:&error];
    NSLog(@"filtered DB count : %d", [filtered count]);

    return filtered;
}

                                             
/// major DB 찾기
- (NSArray *)findMajors:(NSDictionary *)info
{
    if ([info[@"major"] length] == 0) {
        return nil;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Major" inManagedObjectContext:_moc];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"major == %@", info[@"major"]];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    NSLog(@"찾은 전공 개수 : %d", [fetchedObjects count]);

    return fetchedObjects;
}


#pragma mark 기수 찾기
/// 조건에 맞는 기수 검색
- (NSArray *)findCourses:(NSDictionary *)info
{
//    NSManagedObjectContext *backMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    [backMoc setParentContext:_moc];
//    
//    [backgroundMOC performBlock:^{
//        NSLog(@" backgroundMOC performBlock:");

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // select Table
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:_moc];
        [fetchRequest setEntity:entity];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course == %@ AND courseclass == %@", info[@"course"], info[@"courseclass"]];
        [fetchRequest setPredicate:predicate];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
        
        NSError *error = nil;
        NSArray *filtered = [_moc executeFetchRequest:fetchRequest error:&error];
        NSLog(@"찾은 기수 개수 : %d", [filtered count]);
//    }];
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
        entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:self.moc];
        
        predicate = [NSPredicate predicateWithFormat:@"(studcode == %@)", code];
    }
    else if (memType == MemberTypeFaculty)
    {
        // 교수 table
        entity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:self.moc];
        
        predicate = [NSPredicate predicateWithFormat:@"(memberidx == %@)", code];
    }
    else if (memType == MemberTypeStaff)
    {
        // 교직원 table
        entity = [NSEntityDescription entityForName:@"Staff" inManagedObjectContext:self.moc];
        
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
    NSArray *filtered = [self.moc executeFetchRequest:fetchRequest error:&error];
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
    
    if ([_favorites count] > 0)
    {
        
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
    
    if ([_favorites count] > 0)
    {
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
}


@end
