//
//  AppDelegate.h
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MBProgressHUD.h>
#import <MFSideMenu.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, MBProgressHUDDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MFSideMenuContainerViewController *container;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (BOOL)resetDatastore;
- (NSURL *)applicationDocumentsDirectory;

// 로그인 뷰 컨트롤러
- (UINavigationController *)loginViewController;

/// 약관동의 뷰 컨트롤러
- (UINavigationController *)termsViewController;

/// 메인(즐겨찾기) 화면 뷰 컨트롤러
- (void)showMainViewController:(UIViewController *)viewControllder animated:(BOOL)isAnimated;

/// 로그인 화면으로 이동
- (void)goLoginViewControllerWithDataReset:(BOOL)isReset;

@end
