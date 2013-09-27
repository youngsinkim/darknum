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
@property (assign) CGFloat tot;
@property (assign) CGFloat cur;
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
    // 로딩 프로그래스 시작...
    [_progressView setHidden:NO];   // 우선 화면만 노출 시킴
//    [_progressView start];

//    [self showUpdateProgress];
//    [self performSelector:@selector( showUpdateProgress) withObject:nil];
//    [NSThread detachNewThreadSelector:@selector(showUpdateProgress) toTarget:self withObject:nil];

    
    // 로그인 여부 확인
    NSLog(@"로그인 했나? ( %d )", [UserContext shared].isLogined);
    if ([[UserContext shared] isLogined])
    {
        // 약관동의 여부 확인
        if (![[UserContext shared] isAcceptTerms]) {
            NSLog(@"약관 동의 전입니다.");
            return;
        }
        // 프로필 설정 여부 확인
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
        NSLog(@"updateCount (%d)", updateCount);

//        if (updateCount > 0)
        {
            NSLog(@".......... REQUEST Update Favorites .........");
            [self requestAPIFavorites];
            
//            NSLog(@"과정별 기수 목록 요청");
//            // 과정별 기수 목록
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
//    NSLog(@"hide progress..");
//    [self hideUpdateProgress];
    NSLog(@"---------- END ----------");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
    [menu updateHeaderInfo];
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


    _progressView = [[LoadingProgressView alloc] initWithFrame:self.view.bounds];
    _progressView.delegate = self;
    [[[UIApplication sharedApplication] keyWindow] addSubview:_progressView];

}

- (void)workerBee
{
    dispatch_queue_t myQueue = dispatch_queue_create("dbQueue", NULL);
    dispatch_async(myQueue, ^{

//    @autoreleasepool
    {
        for (float i = 0; i < 1; i += 0.1)
        {
//            dispatch_queue_t myQueue = dispatch_queue_create("dbQueue", NULL);
//            dispatch_async(myQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateProgress:[NSNumber numberWithFloat:i]];
//                [self performSelectorInBackground:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:i]];

//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [_progressView setNeedsDisplay];
//                });
                usleep(10);
            });
        }
    }
    });
}

- (void)updateProgress:(NSNumber*)number
{
    NSLog("Progress is now: %@", number);
    [_progressView setProgress:[number floatValue]];
}


- (void)showUpdateProgress
{
//    NSNumber *expired = [NSNumber numberWithFloat:pos];
//    NSDictionary *info = @{@"expired":expired};

    _tot = 307.0f;
    _cur = 0.0f;
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


/// 교수 전공 목록 서버로 요청
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

    // 과정별 기수 목록
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


/// 업데이트된 즐겨찾기 목록 (updatecount > 0)
- (void)requestAPIFavorites
{
    NSLog(@"---------- start ----------");
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    NSString *lastUpdate = [UserContext shared].lastUpdateDate;
    lastUpdate = @"0000-00-00 00:00:00";
    
    if (!mobileNo || !userId | !certNo || !lastUpdate) {
        return;
    }
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo, @"updatedate":lastUpdate};

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
    NSLog(@"progress callback...");
    
    if ([sender isKindOfClass:[UIProgressView class]]) {
        UIProgressView *progressBar = (UIProgressView *)sender;
        
        float progress = 0.0f;
        while (progress < 1.0f) {
            progress += 0.01f;
            progressBar.progress = progress;
            NSLog(@"progress : %f", progressBar.progress);
            usleep(1000);
        }
    }
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

- (void)updateUI
{
    NSLog(@"updateUI callback...");

    static int count = 0;
    
    while (count <= 10) {
//    if (count <= 10) {
//        count++;

        _progressView.percent = [NSString stringWithFormat:@"Download %f / %f", _cur, _tot];
//        self.percentLabel.text = [NSString stringWithFormat:@"%d %%",count*10];
        NSLog(@"persent str : %@", _progressView.percent);

//        _progressView.progress = (float)count/10.0f;
        _progressView.progress = (float)((_cur * 10) / _tot);
        NSLog(@"프로그래스 값 : %f", self.progressView.progress);
        //        NSLog(@"..... progress() .....");//, self.progressView.progress);
        usleep(3000);
    }
//    else {
//        self.hidden = YES;
//        [self.myTimer invalidate];
//        self.myTimer = nil;
//    }
    [_progressView stop];
}

- (void)saveDBFavoriteUpdates
{
    NSLog(@"---------- START ----------");
    NSLog(@"교수전공 (%d), 기수 (%d), 즐겨찾기 업데이트 (%d)", [_majors count], [_courses count], [_updateInfo count]);
    if ([_updateInfo count] > 0)
    {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [NSThread detachNewThreadSelector:@selector(onUpdateDBFavorites:) toTarget:self withObject:_updateInfo];
            [self saveDBFavorite:_updateInfo];
//        });
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

/// 즐겨찾기 DB 목록 불러오기
- (NSArray *)loadDBFavoriteCourses
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:_moc];
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

/// course classes DB 추가 및 업데이트
- (void)saveDBCourseClasses:(NSArray *)courseClasses
{
    for (NSDictionary *info in courseClasses)
    {
        Course *course = nil;
        NSLog(@"저장할 기수 : %@", info[@"title"]);
        
        NSArray *fetched = [self findCourses:info];
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
            [course setValuesForKeysWithDictionary:info];
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
           course = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:_moc];
            
            // ( NSManagedObject <- NSDictionary )
            [course setValuesForKeysWithDictionary:info];
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
        
        // 교수, 교직원, 학색 타입 부여
        if ([info[@"course"] isEqualToString:@"FACULTY"]) {
            course.type = @"2";
        } else if ([info[@"course"] isEqualToString:@"STAFF"]) {
            course.type = @"3";
        } else {
            course.type = @"1";
        }

    }
    
    NSError *error;
    if (![self.moc save:&error]) {
        NSLog(@"과정기수 목록 DB 저장 오류  : %@", [error localizedDescription]);
    }
    else {
        NSLog(@"과정기수 목록 DB 저장 성공!");
        [_favorites setArray:[self loadDBFavoriteCourses]];
        
        if ([_favorites count] > 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@".......... updateTable ..........");
//            [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
                [self refreshFavoriteTable];
            });
            
        }
    }
}

                                             
/// major DB 추가 및 업데이트
- (void)saveDBMajors:(NSArray *)majors
{
    NSLog(@"---------- START ----------");
    for (NSDictionary *info in majors)
    {
        Major *major = nil;
        NSLog(@"저장할 전공 : %@", info[@"title"]);
        
        NSArray *fetched = [self findMajors:info];

        if ([fetched count] > 0)
        {
            NSLog(@"... UPDATE Major");
            major = fetched[0];

            // ( NSManagedObject -> NSDictionary )
            //            NSArray *keys = [[[courseClass entity] attributesByName] allKeys];
            //            NSDictionary *dict = [courseClass dictionaryWithValuesForKeys:keys];
            //            NSLog(@"학생 셀 정보 : %@", dict);

            // ( NSManagedObject <- NSDictionary )
            [major setValuesForKeysWithDictionary:info];
//            NSLog(@"UPDATE 전공 : major(%@), title(%@), title_en(%@), facultys(%d) ", major.major, major.title, major.title_en, [major.facultys count]);
        }
        else
        {
            NSLog(@"... INSERT Major");
            major = (Major *)[NSEntityDescription insertNewObjectForEntityForName:@"Major" inManagedObjectContext:_moc];

            // ( NSManagedObject <- NSDictionary )
            [major setValuesForKeysWithDictionary:info];
//            NSLog(@"UPDATE 전공 : major(%@), title(%@), title_en(%@), facultys(%d) ", major.major, major.title, major.title_en, [major.facultys count]);
        }
    }
    
    NSError *error;
    if (![self.moc save:&error]) {
        NSLog(@"전공 목록 DB 저장 오류 : %@", [error localizedDescription]);
    }
    else {
        NSLog(@"전공 목록 DB 저장 성공!");
    }
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

/// course classes DB 추가 및 업데이트
- (void)saveDBFavorite:(NSDictionary *)updateInfo
{
    NSLog(@"----------- START ----------");
//    [self performSelectorInBackground:@selector(showUpdateProgress) withObject:nil];
//    [_progressView start];
//    [_progressView setPos:1];
    [self showUpdateProgress];
    
    NSError *error = nil;

//    static CGFloat count = 0;
//    static CGFloat maxItem = 307.0f;
//    maxItem = [[UserContext shared].updateCount intValue];
    
    NSLog("... 학생 목록 저장");
    if ([updateInfo[@"student"] isKindOfClass:[NSArray class]])
    {
        NSArray *students = updateInfo[@"student"];
        NSLog(@"즐겨찾기 업데이트 학생 수 [%d]", [students count]);
        
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
            
            if ([filteredObjects count] > 0)
            {
                // 로컬 DB에 존재하면 업데이트
                student = filteredObjects[0];
            }
            else
            {
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
//
            NSLog(@" count ==== %f", ++_cur);
            
            NSLog(@"학생 프로그래스 세팅 : %f", (_cur * 10) / _tot);
//            [_progressView setPos:((count * 10) / maxItem)];
//            [_progressView setPos:((count * 10) / maxItem) withIndex:count max:maxItem];

        }
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
            
            NSLog(@" count ==== %f", ++_cur);
//            NSLog(@"교수 프로그래스 세팅 : %f", (CGFloat)((count  * 10) / maxItem));
//            [_progressView setPos:((count * 10) / maxItem)];
//            [_progressView setPos:((count * 10) / maxItem) withIndex:count max:maxItem];

        }
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
            NSLog(@" count ==== %f", ++_cur);
//            NSLog(@"교직원 프로그래스 세팅 : %f", (CGFloat)((count * 10) / maxItem));
//            [_progressView setPos:((count * 10) / maxItem)];
//            [_progressView setPos:((count * 10) / maxItem) withIndex:count max:maxItem];

        }
    }
    
//    NSLog(@"프로그래스 세팅 : 10");
//    [_progressView setPos:10];

//    NSError *error = nil;
    if (![self.moc save:&error]) {
        NSLog(@"error : %@", [error localizedDescription]);
    }
    else {
        NSLog(@"즐겨찾기 업데이트 목록 전체 저장 성공!");
//        [self performSelectorOnMainThread:@selector(stopDimLoading) withObject:nil waitUntilDone:NO];
        
//        [_loadingIndicatorView stop];

        // 즐겨찾기 목록 로컬 DB에서 갱신.
//        [self.favorites setArray:[self loadDBFavoriteCourse]];
        
//        [self performSelectorOnMainThread:@selector(hideUpdateProgress) withObject:nil waitUntilDone:YES];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self hideUpdateProgress];
//        });

    }

//    });// dispatch
//    [_progressView stop];
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


/// 조건에 맞는 기수 검색
- (NSArray *)findCourses:(NSDictionary *)info
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // select Table
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course == %@ AND courseclass == %@", info[@"course"], info[@"courseclass"]];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
    
    NSError *error = nil;
    NSArray *filtered = [self.moc executeFetchRequest:fetchRequest error:&error];
    NSLog(@"찾은 기수 개수 : %d", [filtered count]);
    
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
