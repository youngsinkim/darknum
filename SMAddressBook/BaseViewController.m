//
//  BaseViewController.m
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "BaseViewController.h"
#import <MFSideMenuContainerViewController.h>

@interface BaseViewController ()

@end

@implementation BaseViewController

#pragma mark - MFSideMenu methods

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

#pragma mark - ViewController lifecycle's
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // 공통 뷰 배경
 //   [self setBackgroundImage];
    
    // 네비게이션 버튼
    [self setupMenuBarButtonItems];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBackgroundImage
{
    UIImage *image = [UIImage imageNamed:@"007-StockPhoto-320x568"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:backgroundView];
}

#pragma mark - UIBarButtonItems

/// 네비게이션바 버튼 설정
- (void)setupMenuBarButtonItems
{
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed && ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self])
        {
        // 최상위 화면이 아니면 [이전]버튼 표시
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
        
        } else {
            // 최상위 화면이면 [메뉴]버튼 표시
            self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
        }
}

/// 네비게이션 왼쪽 [메뉴] 버튼
- (UIBarButtonItem *)leftMenuBarButtonItem {
    // TODO: 메뉴 버튼 이미지 변경
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0.0f, 0.0f, 28.0f, 29.0f);
    
    [menuButton setImage:[UIImage imageNamed:@"btn_menu"] forState:UIControlStateNormal];
    //    [menuButton setImage:[UIImage imageNamed:@"btn_menu"] forState:UIControlStateHighlighted];
    [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    //    return [[UIBarButtonItem alloc]
    //            initWithImage:[UIImage imageNamed:@"btn_menu"] style:UIBarButtonItemStyleDone
    //            target:self
    //            action:@selector(menuButtonClicked:)];
}

/// 네비게이션 왼쪽 [이전] 버튼
- (UIBarButtonItem *)backBarButtonItem {
    //FIXME: 이전 버튼 이미지 변경
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0f, 0.0f, 22.0f, 18.0f);
    
    [backButton setImage:[UIImage imageNamed:@"back-arrow"] forState:UIControlStateNormal];
    //    [backButton setImage:[UIImage imageNamed:@"back-arrow"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    //    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
    //                                            style:UIBarButtonItemStyleBordered
    //                                           target:self
    //                                           action:@selector(backButtonClicked:)];
}

/// 네비게이션 오른쪽 버튼
- (UIBarButtonItem *)rightMenuBarButtonItem
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.01f)]; // 44.01 shifts it up 1px for some reason
    [toolbar setBarStyle: UIBarStyleBlackOpaque];
    
    toolbar.clearsContextBeforeDrawing = NO;
    toolbar.clipsToBounds = NO;
    toolbar.tintColor = [UIColor colorWithWhite:0.305f alpha:0.0f]; // closest I could get by eye to black, translucent style.
    //    tools.tintColor = [UIColor blueColor];
    //    tools.backgroundColor = [UIColor redColor];
    // anyone know how to get it perfect?
    toolbar.barStyle = -1; // clear background
    
    
    UIBarButtonItem *barButtonItem = nil;
    
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    /* 닫기 버튼 */
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    [closeButton setImage:[UIImage imageNamed:@"web_pre_off"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(onCloseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    
    [buttons addObject:barButtonItem];
    
    
    /* 홈 버튼 */
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    homeButton.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    [homeButton setImage:[UIImage imageNamed:@"profile_iconbtn_9"] forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(onHomeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
    
    [buttons addObject:barButtonItem];
    
    
    /* 검색 버튼 */
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    [searchButton setImage:[UIImage imageNamed:@"common_input_search_icon"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(onSearchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    [buttons addObject:barButtonItem];
    
    
    // Add buttons to toolbar and toolbar to nav bar.
    [toolbar setItems:buttons animated:NO];
    
    return [[UIBarButtonItem alloc] initWithCustomView:toolbar];
}

#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

/// 네비게이션 [이전] 버튼 선택
- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/// 네비게이션 [메뉴] 버튼 선택
- (void)menuButtonClicked:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

/// 네비게이션 [닫기] 버튼 선택
- (void)onCloseButtonClicked:(id)sender {
    //    UINavigationController *nav = self.menuContainerViewController.centerViewController;
    //    UIViewController *vc = nav.viewControllers[0];
    //    NSLog(@"centerViewController : %@", vc);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/// 네비게이션 [홈] 버튼 선택
- (void)onHomeButtonClicked:(id)sender
{
    //    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BaseViewController *favoriteViewController = [[BaseViewController alloc] init];
    
    UINavigationController *nav = self.menuContainerViewController.centerViewController;
    NSLog(@"centerViewController : %@", nav.viewControllers[0]);
    
    if (![nav.viewControllers[0] isEqual:favoriteViewController])
        {
        NSArray *controllers = [NSArray arrayWithObject:favoriteViewController];
        nav.viewControllers = controllers;
        
        //        nav.viewControllers = @[appDelegate.favoriteViewController];
        }
    
}

/// 네비게이션 [검색] 버튼 선택
- (void)onSearchButtonClicked:(id)sender {
    
}

@end
