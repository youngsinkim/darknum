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

@end

@implementation BaseViewController

#pragma mark - MFSideMenu methods

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

- (void)sideMenuEvent:(NSNotification *)notification
{
//    NSNumber *menuEventType = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
//    MFSideMenuStateEvent event = [menuEventType intValue];
//    if (event == MFSideMenuStateEventMenuWillClose)
    {
        if(self.menuContainerViewController.menuState == MFSideMenuStateClosed && ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self])
        {
            [_prevButton setHidden:NO];
        } else {
            // 최상위 화면이면 이전 버튼 노출 안함
            [_prevButton setHidden:YES];
        }
    }
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
    self.view.backgroundColor = UIColorFromRGB(0xf0f0f0);
    //   [self setBackgroundImage];

//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_title_bg"] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setTranslucent:YES];
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance] setBackgroundColor:UIColorFromRGB(0x104E8B)];
    if (IS_LESS_THEN_IOS7) {
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:22.0/255.0 green:44.0/255.0 blue:109.0/255.0 alpha:1]];
    }
    else
    {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        
//        [self.navigationController.navigationBar setTintColor:[UIColor blueColor]];
//        [self.navigationController.navigationBar setBackgroundColor:[UIColor grayColor]];
//        [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x0080FF)];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:22.0/255.0 green:44.0/255.0 blue:109.0/255.0 alpha:1];// UIColorFromRGB(0x142c6d);
        [self.navigationController.navigationBar setTranslucent:NO];

        //sets navBar TITLE color and font
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    }
    
    // 타이틀 뷰
//    _titleView = [[TitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
//    _titleView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
    
//    [self.navigationItem setTitleView:_titleView];
//    self.titleLabel.textColor = [UIColor whiteColor];
    
    // 네비게이션 버튼
    [self setupMenuBarButtonItems];

    // 메뉴 이벤트 수신
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sideMenuEvent:) name:MFSideMenuStateNotificationEvent object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed && ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self])
    {
        [_prevButton setHidden:NO];
//        [_homeButton setHidden:YES];
    } else {
        // 최상위 화면이면 이전 버튼 노출 안함
        [_prevButton setHidden:YES];
//        [_homeButton setHidden:NO];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBackgroundImage
{
//    UIImage *image = [UIImage imageNamed:@"007-StockPhoto-320x568"];
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
    

//    [self rightMenuBarButtonItem];
    
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed && ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self])
    {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
//        [_prevButton setHidden:NO];
//        [_homeButton setHidden:YES];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
        // 최상위 화면이면 이전 버튼 노출 안함
//        [_prevButton setHidden:YES];
//        [_homeButton setHidden:NO];
    }
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];

}

/// 네비게이션 왼쪽 [메뉴] 버튼
- (UIBarButtonItem *)leftMenuBarButtonItem
{
    // TODO: 메뉴 버튼 이미지 변경
    UIImage *menuImage = [UIImage imageNamed:@"nvicon_menu"];
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0.0f, 0.0f, menuImage.size.width, menuImage.size.height);
    [menuButton setImage:menuImage forState:UIControlStateNormal];
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
    backButton.frame = CGRectMake(0.0f, 0.0f, 13.0f, 24.0f);
    
    [backButton setImage:[UIImage imageNamed:@"nvicon_back"] forState:UIControlStateNormal];
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
    // dkkim, 상단바 오른쪽 화면에서 'back' 제거
//    UIImage *backImage = [UIImage imageNamed:@"nvicon_back"];
    UIImage *homeImage = [UIImage imageNamed:@"nvicon_home"];
    UIImage *searchImage = [UIImage imageNamed:@"nvicon_search"];

    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, (homeImage.size.width + searchImage.size.width + 10.0f), homeImage.size.height)];
    UIBarButtonItem *barButtonItem = nil;
    
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];

    /* back 버튼 */
//    _prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _prevButton.frame = CGRectMake(0.0f, 0.0f, backImage.size.width, backImage.size.height);
//    [_prevButton setImage:backImage forState:UIControlStateNormal];
//    [_prevButton addTarget:self action:@selector(onBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    
//    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_prevButton];
//
//    [toolbar addSubview:_prevButton];
//    [buttons addObject:barButtonItem];
//    [_prevButton setHidden:YES];
    
    
    /* 홈 버튼 */
    _homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _homeButton.frame = CGRectMake(0.0f, 0.0f, homeImage.size.width, homeImage.size.height);
    [_homeButton setImage:homeImage forState:UIControlStateNormal];
    [_homeButton addTarget:self action:@selector(onHomeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_homeButton];
    
    [toolbar addSubview:_homeButton];
    [buttons addObject:barButtonItem];
    
    
    /* 검색 버튼 */
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchButton.frame = CGRectMake(homeImage.size.width + 20.0f, 0.0f, searchImage.size.width, searchImage.size.height);
    [_searchButton setImage:searchImage forState:UIControlStateNormal];
    [_searchButton addTarget:self action:@selector(onSearchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_searchButton];
    
    [toolbar addSubview:_searchButton];
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
