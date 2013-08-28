//
//  MenuTableViewController.m
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "MenuTableViewController.h"
#import "MenuCell.h"

#import "BaseViewController.h"              // imsi
#import "CourseClassViewController.h"       //< 과정 기수 뷰 컨트롤러
#import "CourseTotalViewController.h"       //< 과전 전체보기 뷰 컨트롤러

#import "MyInfoViewController.h"            //< 내 정보 설정 뷰 컨트롤러
#import "FavoriteSettingViewController.h"   //< 즐겨찾기 설정 뷰 컨트롤러
#import "TermsViewController.h"             //< 약관 동의 화면 뷰 컨트롤러
#import "HelpViewController.h"              //< 도움말 뷰 컨트롤러
#import <UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import "Course.h"

#import "PortraitNavigationController.h"

#pragma mark - UITableView UI Size Values

#define kHeaderH        62.0f
#define kSectionH       32.0f


@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

#pragma mark - MFSideMenu methods

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.parentViewController;
}


#pragma mark - Default methods

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // 메뉴 테이블 구성
    [self setupMenuTableView];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupMenuTableView
{
    self.tableView.backgroundColor = [UIColor colorWithRed:43.0f/255.0f green:46.0f/255.0f blue:49.0f/255.0f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithRed:56.0f/255.0f green:60.0f/255.0f blue:64.0f/255.0f alpha:1.0f];
    
    // TODO: 내 프로필 정보에서 헤더 구성 데이터 가져오기
    NSDictionary *profileDict = @{@"name":@"홍길동", @"class":@"GMBA 5기", @"photourl":@""};

    // 내 정보 해더 구성
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, kHeaderH)];
    headerView.backgroundColor = [UIColor colorWithRed:43.0f/255.0f green:46.0f/255.0f blue:49.0f/255.0f alpha:1.0f];
    
    self.tableView.tableHeaderView = headerView;

    {
        // 내 프로필 사진
        UIImageView *profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 28.0f, 28.0f)];
        [profileImgView setImageWithURL:[NSURL URLWithString:profileDict[@"photourl"]] placeholderImage:[UIImage imageNamed:@"photo_thumb"]];
        
        [headerView addSubview:profileImgView];
        
        // 내 이름
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0f, 7.0f, 150.0f, 16.0f)];
        nameLabel.text = profileDict[@"name"];
        nameLabel.textColor = [UIColor whiteColor];
        [nameLabel setFont:[UIFont systemFontOfSize:15.0f]];
        nameLabel.backgroundColor = [UIColor clearColor];
        
        [headerView addSubview:nameLabel];
        
        // 내 기수
        UILabel *classLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0f, 25.0f, 150.0f, 14.0f)];
        classLabel.text = profileDict[@"class"];
        classLabel.textColor = [UIColor colorWithRed:170.0f/255.0f green:102.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
        [classLabel setFont:[UIFont systemFontOfSize:11.0f]];
        classLabel.backgroundColor = [UIColor clearColor];
        
        [headerView addSubview:classLabel];
        
        UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        settingBtn.frame = CGRectMake(headerView.frame.size.width - 105.0f, 3.0f, 47.0f, 47.0f);
        [settingBtn setImage:[UIImage imageNamed:@"profile_btn_my_set"] forState:UIControlStateNormal];
//        [settingBtn setImage:[UIImage imageNamed:@"menu_img"] forState:UIControlStateHighlighted];
        [settingBtn addTarget:self action:@selector(onMyInfoSettingClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [headerView addSubview:settingBtn];
    }
    
    
    // 주소록 목록 섹션 구성
    _addrMenuList = [@[[self classTotalViewController]] mutableCopy];
    
    // 설정 목록 섹션 구성
    MyInfoViewController *myInfoVC = [[MyInfoViewController alloc] init];
    FavoriteSettingViewController *fvSettingVC = [[FavoriteSettingViewController alloc] init];
    TermsViewController *termsVC = [[TermsViewController alloc] init];
    HelpViewController *helpVC = [[HelpViewController alloc] init];

    _settMenuList = @[@{@"type":[NSNumber numberWithInt:MenuViewTypeSettMyInfo], @"title":LocalizedString(@"my_info_setting", @"내 정보설정"), @"icon":@"help_icon", @"viewController":myInfoVC},
                      @{@"type":[NSNumber numberWithInt:MenuViewTypeSettFavorite], @"title":LocalizedString(@"favorite_setting", @"즐겨찾기 설정"), @"icon":@"help_icon", @"viewController":fvSettingVC},
                      @{@"type":[NSNumber numberWithInt:MenuViewTypeSettTerms], @"title":LocalizedString(@"terms_and_policy", @"약관 및 정책"), @"icon":@"help_icon", @"viewController":termsVC},
                      @{@"type":[NSNumber numberWithInt:MenuViewTypeSettHelp], @"title":LocalizedString(@"help", @"도움말"), @"icon":@"help_icon", @"viewController":helpVC}];
    

}

- (void)setAddrMenuList:(NSMutableArray *)addrMenuList
{
    if (![addrMenuList isEqual:[NSNull null]])
    {
//        _addrMenuList = addrMenuList;
        [_addrMenuList setArray:addrMenuList];
        
        [_addrMenuList addObject:[self classTotalViewController]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });

    }
}


/// 주소록 전체보기 뷰 컨트롤러
- (NSDictionary *)classTotalViewController
{
    CourseTotalViewController *courseTotalVC = [[CourseTotalViewController alloc] init];
    
    NSDictionary *courseDict = @{@"title":LocalizedString(@"total_view_text", @"전체보기"), @"icon":@"help_icon", @"viewController":courseTotalVC};
    
    return courseDict;
}


#pragma mark - UI Control Callbacks
- (void)onMyInfoSettingClicked
{
    
}

#pragma mark - Table view data source

// section (header) - 내정보 메뉴
// section (0) - 주소록 메뉴
// section (1) - 설정 메뉴
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = nil;
    
    if (section == 0) {
        sectionTitle = LocalizedString(@"address_title", @"주소록");
    } else if (section == 1) {
        sectionTitle = LocalizedString(@"setting_title", @"설정");
    }
    
    return sectionTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return ([_addrMenuList count] > 0)? [_addrMenuList count] : 1;
    } else {
        return ([_settMenuList count] > 0)? [_settMenuList count] : 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
//    cell.textLabel.text = [NSString stringWithFormat:@"Item %d", indexPath.row];
    if (indexPath.section == 0)
    {
        if (indexPath.row == (_addrMenuList.count - 1)) {
            // (1)섹션의 마지막 메뉴는 전체보기 항목
            NSDictionary *dict = _addrMenuList[indexPath.row];
            NSLog(@"주소록 목록 : %@", [dict description]);
            
            if (![dict isEqual:[NSNull null]]) {
                cell.textLabel.text = dict[@"title"];
            }
        } else {
            Course *course = _addrMenuList[indexPath.row];
            cell.textLabel.text = course.title;
        }
    
    } else {
        NSDictionary *dict = _settMenuList[indexPath.row];
        
        if (![dict isEqual:[NSNull null]]) {
            cell.textLabel.text = dict[@"title"];
        }
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

/// 테이블 뷰 섹션 헤더 높이
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self tableView:tableView titleForHeaderInSection:section]) {
        return kSectionH;
    } else {
        return 0.0f;
    }
}

/// 테이블 뷰 섹션별 셀 높이
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return kCellH;
    } else {
        return kCellH;
    }
}

/// 테이블 뷰 섹션 뷰
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *titleString = [self tableView:tableView titleForHeaderInSection:section];
    
    if (!titleString)
        return nil;

    UIImageView *sectionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, kSectionH)];
    sectionImageView.backgroundColor = [UIColor colorWithRed:35.0f/255.0f green:38.0f/255.0f blue:41.0f/255.0f alpha:1.0f];
//    sectionImageView.image = [[UIImage imageNamed:@"section_background"] stretchableImageWithLeftCapWidth:0.0f topCapHeight:0.0f];
    
    // 섹션 타이틀
    UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectInset(sectionImageView.frame, 10.0f, 0.0f)];
    sectionTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
    sectionTitleLabel.textAlignment = NSTextAlignmentLeft;;
//    sectionTitleLabel.textColor = [UIColor colorWithRed:125.0f/255.0f green:129.0f/255.0f blue:146.0f/255.0f alpha:1.0f];
    sectionTitleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    sectionTitleLabel.shadowColor = [UIColor colorWithRed:40.0f/255.0f green:45.0f/255.0f blue:57.0f/255.0f alpha:1.0f];
    sectionTitleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    sectionTitleLabel.backgroundColor = [UIColor clearColor];
    sectionTitleLabel.text = titleString;
    
    [sectionImageView addSubview:sectionTitleLabel];

    // 섹션 라인 (imsi)
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0.0f, sectionImageView.frame.size.height - 1.0f, 320.0f, 1.0f)];
    [lineV.layer setCornerRadius:2.0f];
    [lineV.layer setBorderColor:[UIColor colorWithRed:30.0f/255.0f green:32.0f/255.0f blue:34.0f/255.0f alpha:1.0f].CGColor];
    [lineV.layer setBorderWidth:1.0f];
    
    [sectionImageView addSubview:lineV];

    return sectionImageView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    // 각 메뉴 뷰로 이동
    [self showMenuViewController:indexPath];
    
//    BaseViewController *demoController = [[BaseViewController alloc] init];
//    demoController.title = [NSString stringWithFormat:@"Demo #%d-%d", indexPath.section, indexPath.row];
//    
//    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
//    NSArray *controllers = [NSArray arrayWithObject:demoController];
//    navigationController.viewControllers = controllers;
//    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (void)showMenuViewController:(NSIndexPath *)indexPath
{
//    BaseViewController *demoController = [[BaseViewController alloc] init];
//    demoController.title = [NSString stringWithFormat:@"Demo #%d-%d", indexPath.section, indexPath.row];

    NSDictionary *menuDict = nil;
    NSArray *controllers = nil;
    
    if (indexPath.section == 0)
    {
        NSLog(@"selected row = %d", indexPath.row);
        menuDict = _addrMenuList[indexPath.row];

        if (indexPath.row == (_addrMenuList.count - 1))
        {
            UIViewController *viewController = [menuDict objectForKey:@"viewController"];
            viewController.title = [menuDict objectForKey:@"title"];
            
            controllers = [NSArray arrayWithObject:viewController];
        }
        else
        {
            Course *course = _addrMenuList[indexPath.row];
            CourseClassViewController *courseClassVC = [[CourseClassViewController alloc] init];
            courseClassVC.title = course.title;
            
            controllers = [NSArray arrayWithObject:courseClassVC];
        }
    }
    else
    {
        menuDict = _settMenuList[indexPath.row];
        
        if (![menuDict isEqual:[NSNull null]])
        {
            if ([menuDict[@"type"] intValue] == MenuViewTypeSettMyInfo)
            {
                [self menuNavigationController:MenuViewTypeSettMyInfo];
                return;
            }
            else if ([menuDict[@"type"] intValue] == MenuViewTypeSettTerms)
            {
                [self menuNavigationController:MenuViewTypeSettTerms];
                return;
            }

            UIViewController *viewController = [menuDict objectForKey:@"viewController"];
            viewController.title = [menuDict objectForKey:@"title"];
            
            controllers = [NSArray arrayWithObject:viewController];
        }
    }

    //
    if (controllers != nil)
    {
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        navigationController.viewControllers = controllers;
        
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
}

/// 내 정보설정 뷰 컨트롤러
- (void)showMyInfoViewController
{
    MyInfoViewController *vc = [[MyInfoViewController alloc] init];
    NSArray *controllers = [NSArray arrayWithObject:vc];

    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    navigationController.viewControllers = controllers;

//    for (NSDictionary *dict in self.settMenuList) {
//        if ([dict[@"viewController"] isEqual:[MyInfoViewController class]]) {
//            NSLog(@"vc = %@", dict[@"viewController"]);
//            UIViewController *viewController = dict[@"viewController"];
//            viewController.title = dict[@"title"];
//            
//            NSArray *controllers = [NSArray arrayWithObject:viewController];
//            
//            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
//            navigationController.viewControllers = controllers;
//            
//            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
//
//            break;
//        }
//    }
}

//- (UIViewController *)showMyInfoViewController
//{
//    MyInfoViewController *myInfoViewController = [[MyInfoViewController alloc] init];
//
//    NSDictionary *myInfoSettDic = @{@"title":LocalizedString(@"my_info_setting", @"내 정보설정"), @"icon":@"help_icon", @"viewController":myInfoViewController};
//
//    return (UIViewController *)myInfoViewController;
//}


#pragma mark - 

/// 세로 모드 네비게이션바 세팅
- (UINavigationController *)navigationController:(UIViewController *)viewController {
    return [[PortraitNavigationController alloc] initWithRootViewController:viewController];
}

/// 네비게이션 뷰 컨트롤러
- (UINavigationController *)menuNavigationController:(MenuViewType)menuType
{
    UINavigationController *nav = nil;
    NSArray *controllers = nil;
    
    switch (menuType)
    {
        case MenuViewTypeAddrFaculty:
        {
            CourseClassViewController *viewController = [[CourseClassViewController alloc] init];
//            nav = [[PortraitNavigationController alloc] initWithRootViewController:viewController];
            controllers = @[viewController];
            self.menuContainerViewController.centerViewController = [self navigationController:viewController];
        }
            break;

        case MenuViewTypeAddrTotalStudent:
            {
                CourseTotalViewController *totalVC = [[CourseTotalViewController alloc] init];
                controllers = @[totalVC];
                self.menuContainerViewController.centerViewController = [self navigationController:totalVC];
            }
            break;

        case MenuViewTypeSettMyInfo:
            {
                MyInfoViewController *myInfoVC = [[MyInfoViewController alloc] init];
//                controllers = @[myInfoVC];
                
                self.menuContainerViewController.centerViewController = [self navigationController:myInfoVC];

            }
            break;
            
        case MenuViewTypeSettFavorite:
            {
                FavoriteSettingViewController *favoriteVC = [[FavoriteSettingViewController alloc] init];
                controllers = @[favoriteVC];
                
                self.menuContainerViewController.centerViewController = [self navigationController:favoriteVC];
            }
            break;
            
        case MenuViewTypeSettTerms:
            {
                TermsViewController *termsVC = [[TermsViewController alloc] init];
                termsVC.isByMenu = YES;
                
                controllers = @[termsVC];
                self.menuContainerViewController.centerViewController = [self navigationController:termsVC];
            }
            break;

        case MenuViewTypeSettHelp:
            {
                HelpViewController *helpVC = [[HelpViewController alloc] init];
                controllers = @[helpVC];
                self.menuContainerViewController.centerViewController = [self navigationController:helpVC];
            }
            break;

        default:    // 즐겨찾기 화면
//        {
//            FavoriteViewController *vc = [[FavoriteViewController alloc] init];
//            nav = [[PortraitNavigationController alloc] initWithRootViewController:vc];
//        }
            break;
    }
    
//    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
//    navigationController.viewControllers = controllers;
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

    return nil;
}

@end
