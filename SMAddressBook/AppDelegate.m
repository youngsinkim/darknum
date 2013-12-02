//
//  AppDelegate.m
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "AppDelegate.h"
#import "FavoriteViewController.h"      //< 즐겨찾기(메인) 뷰 컨트롤러
#import "PortraitNavigationController.h"//< 세로모드 네비게이션 컨트롤러
#import "MenuTableViewController.h"     //< 왼쪽 메뉴 테이블 뷰 컨트롤러

#import "SmsAuthViewController.h"       //< 본인인증 뷰 컨트롤러
#import "LoginViewController.h"         //< 로그인 뷰 컨트롤러
#import "TermsViewController.h"

#import <AFNetworkActivityIndicatorManager.h>
#import <MFSideMenuContainerViewController.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "NSString+MD5.h"



@interface AppDelegate ()

@property (strong, nonatomic) UIViewController *splashViewController;
@property (strong, nonatomic) MBProgressHUD *HUD;

@end


@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    
    //-------------------- App 사용 메모리 설정 --------------------
    int cacheSizeMemory = 4 * 1024 * 1024;
	int cacheSizeDisk	= 32 * 1024 * 1024;
    
	NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory
                                                            diskCapacity:cacheSizeDisk
                                                                diskPath:@"NSUrlCache"];
    
	[NSURLCache setSharedURLCache:sharedCache];
    
    
    //------------------- 상태바 Indicator 설정 ------------------
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
        
    // UserInfo의 auto login 정보에 따라 로그인 창 띄우기
//    NSLog(@"AUTO LOGIN : %d", [UserContext shared].isAutoLogin);
//
//    if ([UserContext shared].isAutoLogin == YES)
//    {
//        //---------- 자동 로그인 (0) : 대쉬보드 화면 표시 ----------
//        [self showMainViewController:nil animated:NO];
////        self.window.rootViewController = [self sideMenuConrainer];
//    }
//    else
//    {
//        //---------- 자동 로그인 (X) : 로그인 화면 표시 ----------
//        self.window.rootViewController = [self loginViewController];
////        self.window.rootViewController = [self sideMenuConrainer];
//    }

    
    // MARK: App 실행 (왼쪽 메뉴, 즐겨찾기 메인 뷰 구성)
//    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}]; // 네비게이션바 타이틀 색

    
    // sochae - 메뉴 구성 먼저 하고 로그인 창 모달로 띄우도록 시나리오 변경
    [self showMainViewController:nil animated:NO];
    [self.window makeKeyAndVisible];

    
    // 로그인 여부 확인
    BOOL isAutoLogin = [[UserContext shared] isAutoLogin];
    NSString *phoneNumber = [Util phoneNumber];
    NSLog(@"AUTO_LOGIN(%d), CertNo : %@, Phone : %@", isAutoLogin, [UserContext shared].certNo, phoneNumber);
    
    // 자동 로그인 설정 유무
    if (isAutoLogin && [[UserContext shared].userId length] > 0 && [[UserContext shared].userPwd length] > 0)
    {
        /* Splash 뷰 노출 */
        CGRect screenRect = [[UIScreen mainScreen] bounds];
//        float screenWidth = screenRect.size.width;
        float screenHeight = screenRect.size.height;
        UIImage *splashImage = nil;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//            splashView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
            if (screenHeight == 568.0) {
                NSLog(@"iPhone 5 이미지 로딩");
                splashImage = [UIImage imageNamed:@"Default-568h.png"];//iPhone 5
            }else{
                NSLog(@"iPhone 이미지 로딩");
                splashImage = [UIImage imageNamed:@"Default.png"]; //other iPhones
            } 
        }
            
        self.splashViewController = [[UIViewController alloc] init];
        self.splashViewController.view.layer.contents = (id)splashImage.CGImage;

        [self.container.centerViewController presentViewController:self.splashViewController animated:NO completion:nil];

        
        // 자동 로그인 요청
        [self requestAPILogin];
        
    }
    else if (phoneNumber.length == 0) {
        // 최초 설치 후, 휴대전화 인증을 받지 않은 유저는 휴대전화 본인인증을 받고 로그인 창으로 이동하도록 시나리오 추가.
        SmsAuthViewController *smsAuthViewController = [[SmsAuthViewController alloc] init];
        
        [self.container.centerViewController presentViewController:[self navigationController:smsAuthViewController] animated:NO completion:nil];
    }
    else
    {
#if (1) // 로그인 화면으로 이동하는 flow 작성으로 기존 코드 수정
        [self goLoginViewControllerWithDataReset:NO];
#else
        // TODO: 자동 로그인이 아니면 이전 설정값 삭제
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserId];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserPwd];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCertNo];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMemType];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUpdateCount];

            [[NSUserDefaults standardUserDefaults] synchronize];
        }

        // MARK: 로그인 전이면, 로그인 화면 표시
        UINavigationController *loginNavigationController = [self loginViewController];
        
        [self.container.centerViewController presentViewController:loginNavigationController animated:NO completion:nil];
#endif
//        if (self.loginSaveCheckBtn.selected == YES)
//            {
//            [[NSUserDefaults standardUserDefaults] setValue:[self.idTextField text] forKey:@"userId"];
//            [[NSUserDefaults standardUserDefaults] setValue:[self.pwdTextField text] forKey:@"userPwd"];
//            }
    }
//    else if (![[UserContext shared] isAcceptTerms])
//        {
//        // MARK: 약관 동의를 하지 않았으면 약관동의 화면 노출.
//        UIViewController *termsViewController = [appDelegate termsViewController];
//
//        [self.navigationController presentViewController:termsViewController animated:NO completion:nil];
//        }

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (BOOL)resetDatastore
{
    [[self managedObjectContext] lock];
    [[self managedObjectContext] reset];
    NSPersistentStore *store = [[[self persistentStoreCoordinator] persistentStores] lastObject];
    BOOL resetOk = NO;
    
    if (store)
    {
        NSURL *storeUrl = store.URL;
        NSError *error;
        
        if ([[self persistentStoreCoordinator] removePersistentStore:store error:&error])
        {
            _persistentStoreCoordinator = nil;
            _managedObjectContext = nil;
            
            if (![[NSFileManager defaultManager] removeItemAtPath:storeUrl.path error:&error])
            {
                NSLog(@"\nresetDatastore. Error removing file of persistent store: %@",
                      [error localizedDescription]);
                resetOk = NO;
            }
            else
            {
                //now recreate persistent store
                [self persistentStoreCoordinator];
                [[self managedObjectContext] unlock];
                resetOk = YES;
            }
        }
        else
        {
            NSLog(@"\nresetDatastore. Error removing persistent store: %@",
                  [error localizedDescription]);
            resetOk = NO;
        }
        return resetOk;
    }
    else
    {
        NSLog(@"\nresetDatastore. Could not find the persistent store");
        return resetOk;
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SMAddressBook" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SMAddressBook.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
//         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - ViewControllers

/// 세로 모드 네비게이션바 세팅
- (UINavigationController *)navigationController:(UIViewController *)viewController {
    return [[PortraitNavigationController alloc] initWithRootViewController:viewController];
}

/// 사이드 메뉴 컨테이너 구성
- (MFSideMenuContainerViewController *)sideMenuConrainer
{
    // 대시보드(즐겨찾기) 화면
    FavoriteViewController *viewController = [[FavoriteViewController alloc] init];
    
    // 왼쪽 메뉴
    MenuTableViewController *leftMenuViewController = [[MenuTableViewController alloc] init];
    
//    MFSideMenuContainerViewController *
    self.container =
    [MFSideMenuContainerViewController containerWithCenterViewController:[self navigationController:viewController]
                                                  leftMenuViewController:leftMenuViewController
                                                 rightMenuViewController:nil];
    
    return self.container;
}

- (void)performViewController:(UIViewController *)viewController
{
    CATransition* transition = [CATransition animation];
    
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    
//    [[self.sourceViewController navigationController].view.layer addAnimation:transition forKey:kCATransition];
//    [[self.sourceViewController navigationController] pushViewController:[self destinationViewController] animated:NO];
}

/// 로그인 뷰 컨트롤러
- (UINavigationController *)loginViewController
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    
    return [self navigationController:loginVC];
}

/// 약관동의 뷰 컨트롤러
- (UINavigationController *)termsViewController
{
    TermsViewController *termsVC = [[TermsViewController alloc] init];
    
    return [self navigationController:termsVC];
}

/// 메인(즐겨찾기) 화면 뷰 컨트롤러
- (void)showMainViewController:(UIViewController *)viewControllder animated:(BOOL)isAnimated
{
    if (isAnimated == NO)
    {
        self.window.rootViewController = [self sideMenuConrainer];
    }
    else
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             viewControllder.view.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             
                             if (viewControllder) {
                                 [viewControllder.view removeFromSuperview];
                             }
                             
                             self.window.rootViewController = [self sideMenuConrainer];

                         }];

//        [UIView transitionWithView:viewControllder.view
//                          duration:2.0f
//                           options:UIViewAnimationOptionTransitionFlipFromTop
//                        animations:^{
//                            
////                        self.window.rootViewController.view.alpha = 0.0f;
////                            viewControllder.view.alpha = 0.5f;
//                        }
//                        completion:^(BOOL finished) {
//                            
//                            if (viewControllder) {
//                                [viewControllder.view removeFromSuperview];
//                            }
//                            
//                            self.window.rootViewController = [self sideMenuConrainer];
//                            
//                        }];
    }
}

#pragma mark 로그인 화면 표시
- (void)goLoginViewControllerWithDataReset:(BOOL)isReset
{
    NSLog(@".......... 로그인 화면으로 이동 ..........");
    if (isReset == YES)
    {
        [self resetDBData];

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kProfileInfo];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastUpdate];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserId];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserPwd];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserKey];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCertNo];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMemType];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUpdateCount];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMyClass];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAcceptTerms];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSetProfile];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSavedId];
        

        [[UserContext shared].profileInfo removeAllObjects];
        [UserContext shared].profileInfo = [[NSMutableDictionary alloc] init];

        [UserContext shared].lastUpdateDate = @"0000-00-00 00:00:00";
        [UserContext shared].userId = @"";
        [UserContext shared].userPwd = @"";
        [UserContext shared].userKey = @"";
        
        [UserContext shared].certNo = @"";
        [UserContext shared].memberType = @"";
        [UserContext shared].updateCount = @"";
        [UserContext shared].myClass = @"";
        
        [UserContext shared].isAcceptTerms = NO;
        [UserContext shared].isExistProfile = NO;
        [UserContext shared].isSavedID = NO;
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAutoLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [UserContext shared].isLogined = NO;
    [UserContext shared].isAutoLogin = NO;


    // MARK: 로그인 전이면, 로그인 화면 표시
    UINavigationController *loginNavigationController = [self loginViewController];
    
    [self.container.centerViewController presentViewController:loginNavigationController animated:NO completion:nil];
}

#pragma mark - DB methods
// 전체 데이터 초기화
- (void)resetDBData
{
    NSLog(@"..... DB 파일 삭제 후 제 생성");
    [self resetDatastore];
}

#pragma mark - Network methods
/// 로그인 요청
- (void)requestAPILogin
{
//    self.HUD = [MBProgressHUD showHUDAddedTo:self.window.rootViewController.view animated:YES];
//	self.HUD.delegate = self;
//    self.HUD.color = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
//    self.HUD.margin = 10.0f;

    NSString *crytoMobileNo = [Util phoneNumber];
    NSString *lastUpdate = [[UserContext shared] lastUpdateDate];
    NSLog(@".......... 마지막 업데이트 시간 : %@ ..........", lastUpdate);
    NSString *lang = [UserContext shared].language;
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    // TODO: 업데이트 시간 최초 이회에 마지막 시간 값으로 세팅되도록 수정 필요
    NSDictionary *param = @{@"scode":[crytoMobileNo MD5],
                            @"phone":crytoMobileNo,
                            @"updatedate":lastUpdate,
                            @"userid":[UserContext shared].userId,
                            @"passwd":[UserContext shared].userPwd,
                            @"lang":lang,
                            @"os":@"iOS",
                            @"version":version};

    NSLog(@"(/fb/login) Request Parameter : %@", param);

//    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
    
    // 로그인 요청
    [[SMNetworkClient sharedClient] postLogin:param
                                        block:^(NSDictionary *result, NSError *error) {

                                            NSLog(@"API(LOGIN) Result : \n%@", result);
//                                            [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];                                            
                                            //[self.HUD hide:YES];

                                            if (error) {
                                                
                                                NSLog(@"error ---- %@", [error localizedDescription]);
                                                NSDictionary *info = [NSDictionary dictionaryWithDictionary:[error userInfo]];
                                                NSLog(@"error UserInfo : %@", info);
                                                BOOL isErrorAlert = YES;
                                                
                                                if ([info isKindOfClass:[NSDictionary class]]) {
                                                    if ([info[@"errcode"] isEqualToString:@"2"]) {
                                                        isErrorAlert = NO;
                                                        NSLog(@"..... 모든 정보 리셋하고 로그인 화면으로 이동");
                                                        
                                                        [self.splashViewController dismissViewControllerAnimated:NO completion:nil];

                                                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                                        [appDelegate goLoginViewControllerWithDataReset:YES];
                                                        isErrorAlert = NO;
                                                    }
                                                }

                                                if (isErrorAlert) {
                                                    [[SMNetworkClient sharedClient] showNetworkError:error];
                                                }
                                            }
                                            else
                                            {
                                                // 로그인 결과 로컬(파일) 저장.
                                                NSDictionary *dict = [NSDictionary dictionaryWithDictionary:result];
                                                if (![dict isKindOfClass:[NSNull class]])
                                                {
                                                    [UserContext shared].certNo     = dict[kCertNo];
                                                    [UserContext shared].memberType = dict[kMemType];
                                                    [UserContext shared].updateCount= dict[kUpdateCount];
                                                    
                                                    [[NSUserDefaults standardUserDefaults] setValue:dict[kCertNo] forKey:kCertNo];
                                                    [[NSUserDefaults standardUserDefaults] setValue:dict[kMemType] forKey:kMemType];
                                                    [[NSUserDefaults standardUserDefaults] setValue:dict[kUpdateCount] forKey:kUpdateCount];
                                                
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    [UserContext shared].isLogined = YES;
                                                    
                                                }
                                                
                                                // 업데이트가 존재하면 팝업으로 공지함.
                                                if ([dict[@"forceupdate"] isEqualToString:@"y"])
                                                {
                                                    // update url
                                                    NSString *appUpdateUrl = [NSString stringWithFormat:@"%@", dict[@"updateurl"]];
                                                    if (appUpdateUrl.length > 0)
                                                    {
                                                        [UserContext shared].appUpdateUrl = appUpdateUrl;
                                                        
                                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                                                            message:LocalizedString(@"update alert msg", @"업데이트 알림 메시지")
                                                                                                           delegate:self
                                                                                                  cancelButtonTitle:LocalizedString(@"Ok", @"Ok")
                                                                                                  otherButtonTitles:LocalizedString(@"Cancel", @"Cancel"),
                                                                                  nil];
                                                        alertView.tag = 900;
                                                        [alertView show];
                                                        return;
                                                    }
                                                }

                                                
                                                [self.splashViewController dismissViewControllerAnimated:NO completion:nil];
                                                
                                                // 로그인 성공 후, 약관 동의를 하지 않았으면 약관동의 화면으로 이동
                                                if ([[UserContext shared] isAcceptTerms] == NO)
                                                {
                                                    // 약관 동의 하지 않았으면, 약관 동의 화면으로 이동
                                                    TermsViewController *termsViewController = [[TermsViewController alloc] init];
                                                    
                                                    [self.container.centerViewController presentViewController:[self navigationController:termsViewController] animated:NO completion:nil];
                                                }
                                                else if ([[UserContext shared] isExistProfile] == NO)
                                                {
                                                    // 로그인 이후, 최초 프로필 설정이 안되어 있으면 프로필 화면으로 이동
                                                    MenuTableViewController *leftMenuViewController = (MenuTableViewController *)self.container.leftMenuViewController;
                                                    
                                                    [leftMenuViewController menuNavigationController:MenuViewTypeSettMyInfo withMenuInfo:nil];
                                                }
                                                else
                                                {
                                                    // 로그인 성공하면 즐겨찾기 화면으로 이동
                                                    //                                                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                                    //                                                    [appDelegate showMainViewController:self animated:YES];
                                                    
                                                    // 메뉴 구성 먼저하고, 로그인 창을 모달로 띄운 시나리오에서는 해당 로그인 창을 닫는 루틴 처리.
//                                                    [self.splashViewController.parentViewController dismissViewControllerAnimated:NO completion:nil];
                                                }
                                                
                                            }
                                            
                                        }];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 900)
    {
        /* 업데이트 진행 */
        if (buttonIndex == alertView.cancelButtonIndex)
        {
            NSString *url = [UserContext shared].appUpdateUrl;
            if (url.length > 0) {
                // https://itunes.apple.com/kr/app/~
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        }
        else
        {
            [self.splashViewController dismissViewControllerAnimated:NO completion:nil];
            
            // 로그인 성공 후, 약관 동의를 하지 않았으면 약관동의 화면으로 이동
            if ([[UserContext shared] isAcceptTerms] == NO)
            {
                // 약관 동의 하지 않았으면, 약관 동의 화면으로 이동
                TermsViewController *termsViewController = [[TermsViewController alloc] init];
                
                [self.container.centerViewController presentViewController:[self navigationController:termsViewController] animated:NO completion:nil];
            }
            else if ([[UserContext shared] isExistProfile] == NO)
            {
                // 로그인 이후, 최초 프로필 설정이 안되어 있으면 프로필 화면으로 이동
                MenuTableViewController *leftMenuViewController = (MenuTableViewController *)self.container.leftMenuViewController;
                
                [leftMenuViewController menuNavigationController:MenuViewTypeSettMyInfo withMenuInfo:nil];
            }
            else
            {
                // 로그인 성공하면 즐겨찾기 화면으로 이동
                //                                                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                //                                                    [appDelegate showMainViewController:self animated:YES];
                
                // 메뉴 구성 먼저하고, 로그인 창을 모달로 띄운 시나리오에서는 해당 로그인 창을 닫는 루틴 처리.
                //                                                    [self.splashViewController.parentViewController dismissViewControllerAnimated:NO completion:nil];
            }
        }
    }
}

@end
