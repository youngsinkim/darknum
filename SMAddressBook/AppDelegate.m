//
//  AppDelegate.m
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseViewController.h"          //< 공통 뷰 컨트롤러
#import "PortraitNavigationController.h"//< 세로모드 네비게이션 컨트롤러
#import "MenuTableViewController.h"     //< 왼쪽 메뉴 테이블 뷰 컨트롤러
#import "LoginViewController.h"         //< 로그인 뷰 컨트롤러

#import <AFNetworkActivityIndicatorManager.h>
#import <MFSideMenuContainerViewController.h>
#import <QuartzCore/QuartzCore.h>


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
    NSLog(@"AUTO LOGIN : %d", [UserContext shared].isAutoLogin);
    
    if ([UserContext shared].isAutoLogin == YES)
    {
        //---------- 자동 로그인 (0) : 대쉬보드 화면 표시 ----------
        [self showMainViewController:nil animated:NO];
//        self.window.rootViewController = [self sideMenuConrainer];
    }
    else
    {
        //---------- 자동 로그인 (X) : 로그인 화면 표시 ----------
        self.window.rootViewController = [self loginViewController];
//        self.window.rootViewController = [self sideMenuConrainer];        
    }

    
    //
    [self.window makeKeyAndVisible];
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
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
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
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
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
//    _favoriteViewController = [[FavoriteViewController alloc] init];
    BaseViewController *viewController = [[BaseViewController alloc] init];
    
    // 왼쪽 메뉴
    MenuTableViewController *leftMenuViewController = [[MenuTableViewController alloc] init];
    
    MFSideMenuContainerViewController *container =
    [MFSideMenuContainerViewController containerWithCenterViewController:[self navigationController:viewController]
                                                  leftMenuViewController:leftMenuViewController
                                                 rightMenuViewController:nil];
    
    return container;
}

/// 로그인 뷰 컨트롤러
- (UINavigationController *)loginViewController
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    
    return [self navigationController:loginViewController];
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
@end
