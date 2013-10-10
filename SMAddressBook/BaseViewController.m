//
//  BaseViewController.m
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "BaseViewController.h"
#import "FavoriteViewController.h"
#import "MenuTableViewController.h"
#import "SearchViewController.h"

@interface BaseViewController ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *homeButton;
@property (strong, nonatomic) UIButton *searchButton;

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
    
//    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, 320, 44)];
//    _titleLabel.textAlignment = UITextAlignmentLeft;
////    titleLabel.text = LocalizedString(@"favorite_title", @"즐겨찾기");
//    self.navigationItem.titleView = _titleLabel;

    // 공통 뷰 배경
    self.view.backgroundColor = [UIColor whiteColor];
    //   [self setBackgroundImage];

//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_title_bg"] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setTranslucent:YES];
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance] setBackgroundColor:UIColorFromRGB(0x104E8B)];
    if (IS_LESS_THEN_IOS7) {
        [self.navigationController.navigationBar setTintColor:[UIColor blueColor]];
    } else {
//        [self.navigationController.navigationBar setTintColor:[UIColor blueColor]];
//        [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
//        [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x0080FF)];
//        [self.navigationController.navigationBar setTranslucent:NO];
//        self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
//        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//        self.navigationController.navigationBar.translucent = NO;
    }
    
    
    // 네비게이션 버튼
    [self setupMenuBarButtonItems];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed && ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self])
    {
        _prevButton.hidden = NO;
    } else {
        // 최상위 화면이면 이전 버튼 노출 안함
        _prevButton.hidden = YES;
    }
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

//- (void)setTitle:(NSString *)title
//{
//    _titleLabel.text = title;
//}

#pragma mark - Autorotate (세로모드 only)

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait)? YES : NO;
}


#pragma mark - UIBarButtonItems

/// 네비게이션바 버튼 설정
- (void)setupMenuBarButtonItems
{
    // 디자인 구조상 왼쪽은 무조건 메뉴 버튼을 고정.
//    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed && ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self])
//        {
//        // 최상위 화면이 아니면 [이전]버튼 표시
//        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
//        
//        } else {
//            // 최상위 화면이면 [메뉴]버튼 표시
//            self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
//        }
    

    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
//    [self rightMenuBarButtonItem];
}

/// 네비게이션 왼쪽 [메뉴] 버튼
- (UIBarButtonItem *)leftMenuBarButtonItem {
    // TODO: 메뉴 버튼 이미지 변경
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0.0f, 0.0f, 28.0f, 29.0f);
    
    [menuButton setImage:[UIImage imageNamed:@"menu_img"] forState:UIControlStateNormal];
    //    [menuButton setImage:[UIImage imageNamed:@"menu_img"] forState:UIControlStateHighlighted];
    [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    //    return [[UIBarButtonItem alloc]
    //            initWithImage:[UIImage imageNamed:@"menu_img"] style:UIBarButtonItemStyleDone
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
//    UIToolbar *tools = [[UIToolbar alloc]
//                        initWithFrame:CGRectMake(0.0f, 10.0f, 103.0f, 30.01f)]; // 44.01 shifts it up 1px for some reason
//    tools.clearsContextBeforeDrawing = NO;
//    tools.clipsToBounds = NO;
//    tools.tintColor = [UIColor colorWithWhite:0.305f alpha:0.0f]; // closest I could get by eye to black, translucent style.
    // anyone know how to get it perfect?
//    tools.barStyle = -1; // clear background
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 44.0f)];
//    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 44.0f)]; // 44.01 shifts it up 1px for some reason
//    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
//    [toolbar setBackgroundColor:[UIColor whiteColor]];
//    [toolbar setTintColor:[UIColor whiteColor]];
//    [toolbar setBarStyle: UIBarStyleBlackOpaque];
    
//    toolbar.clearsContextBeforeDrawing = NO;
//    toolbar.clipsToBounds = NO;
//    toolbar.tintColor = [UIColor clearColor];
//    toolbar.tintColor = [UIColor colorWithWhite:0.305f alpha:0.0f]; // closest I could get by eye to black, translucent style.
    //    tools.tintColor = [UIColor blueColor];
    //    tools.backgroundColor = [UIColor redColor];
    // anyone know how to get it perfect?
//    toolbar.barStyle = -1; // clear background
    
    
    UIBarButtonItem *barButtonItem = nil;
    
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    CGFloat size = 40.0f;
    
    /* back 버튼 */
    _prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _prevButton.frame = CGRectMake(0.0f, 5.0f, size, size);
    [_prevButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [_prevButton addTarget:self action:@selector(onBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_prevButton];

    [toolbar addSubview:_prevButton];
    [buttons addObject:barButtonItem];
    
    
    /* 홈 버튼 */
    _homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _homeButton.frame = CGRectMake(40.0f, 5.0f, size, size);
    [_homeButton setImage:[UIImage imageNamed:@"btn_home"] forState:UIControlStateNormal];
    [_homeButton addTarget:self action:@selector(onHomeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_homeButton];
    
    [toolbar addSubview:_homeButton];
    [buttons addObject:barButtonItem];
    
    
    /* 검색 버튼 */
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(80.0f, 5.0f, size, size);
    [searchButton setImage:[UIImage imageNamed:@"btn_filter"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(onSearchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    [toolbar addSubview:searchButton];
    [buttons addObject:barButtonItem];
    
    
    // Add buttons to toolbar and toolbar to nav bar.
//    [toolbar setItems:buttons animated:NO];
//    self.navigationItem.rightBarButtonItems = buttons;
    
//    return [[UIBarButtonItem alloc] initWithCustomView:tools];
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
- (void)onBackButtonClicked:(id)sender {
    //    UINavigationController *nav = self.menuContainerViewController.centerViewController;
    //    UIViewController *vc = nav.viewControllers[0];
    //    NSLog(@"centerViewController : %@", vc);
    
//    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed && ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self])
    {
        // 최상위 화면이 아니면 [이전]버튼 표시
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        UINavigationController *nav = self.menuContainerViewController.centerViewController;
        UIViewController *vc = nav.viewControllers[0];
        NSLog(@"centerViewController : %@", vc);
    }
}

/// 네비게이션 [홈] 버튼 선택
- (void)onHomeButtonClicked:(id)sender
{
    UINavigationController *nav = self.menuContainerViewController.centerViewController;
    UIViewController *vc = nav.viewControllers[0];
    
    if ([vc isKindOfClass:[FavoriteViewController class]]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        NSLog(@"centerViewController : %@", vc);
        return;
    }
    FavoriteViewController *favoriteViewController = [[FavoriteViewController alloc] init];

    MenuTableViewController *leftMenu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
    self.menuContainerViewController.centerViewController = [leftMenu navigationController:favoriteViewController];


//    UINavigationController *nav = self.menuContainerViewController.centerViewController;
//    NSLog(@"centerViewController : %@", nav.viewControllers[0]);
//    
//    if (![nav.viewControllers[0] isEqual:favoriteViewController])
//    {
//        NSArray *controllers = [NSArray arrayWithObject:favoriteViewController];
//        nav.viewControllers = controllers;
//        
////        nav.viewControllers = @[appDelegate.favoriteViewController];
//    }
    
}

/// 네비게이션 [검색] 버튼 선택
- (void)onSearchButtonClicked:(id)sender
{
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
    
    MenuTableViewController *leftMenu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
    self.menuContainerViewController.centerViewController = [leftMenu navigationController:searchViewController];
}

@end
