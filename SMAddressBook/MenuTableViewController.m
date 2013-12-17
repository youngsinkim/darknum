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
#import "FacultyMajorViewController.h"      //< 교수 전공 뷰 컨트롤러
#import "StaffAddressViewController.h"      //< 교직원 주소록 뷰 컨트롤러
#import "StudentAddressViewController.h"    //< 과정 기수(학생) 주소록 뷰 컨트롤러
//#import "CourseClassViewController.h"       //< 과정 기수 뷰 컨트롤러
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

#define kHeaderH        70.0f
#define kSectionH       40.0f


@interface MenuTableViewController ()

@property (strong, nonatomic) UIImageView *profileImgView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *classLabel;

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
    
//    self.view.backgroundColor = [UIColor colorWithRed:43.0f/255.0f green:46.0f/255.0f blue:49.0f/255.0f alpha:1.0f];
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
    CGFloat yOffset = 14.0f;
    CGFloat xOffset = 10.0f;
    CGFloat headerCY = kHeaderH;
    
    if (!IS_LESS_THEN_IOS7) {
        yOffset += 20.0f;
        headerCY += 20.0f;

        UIEdgeInsets edges;
        edges.left = 0;
        self.tableView.separatorInset = edges;
    }
    
    self.tableView.backgroundColor = UIColorFromRGB(0x2b2e31);
    
    // TODO: 내 프로필 정보에서 헤더 구성 데이터 가져오기
    NSDictionary *profileDict = @{@"name":@"", @"class":@"", @"photourl":@""};

    // 내 정보 해더 구성
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, headerCY)];
//    headerView.backgroundColor = UIColorFromRGB(0xffffff);
    
    self.tableView.tableHeaderView = headerView;

    {
        // 내 프로필 사진
        _profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, yOffset, 40.0f, 40.0f)];
        _profileImgView.image = [UIImage imageNamed:@"ic_noimg_mypage"];
//        [_profileImgView setImageWithURL:[NSURL URLWithString:profileDict[@"photourl"]] placeholderImage:[UIImage imageNamed:@"ic_noimg_mypage"]];
        
        [headerView addSubview:_profileImgView];
        xOffset += (_profileImgView.frame.size.width + 15.0f);
        yOffset += 3.0f;
        
        
        // 내 이름
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 150.0f, 17.0f)];
//        _nameLabel.text = profileDict[@"name"];
        _nameLabel.text = @"";
        _nameLabel.textColor = [UIColor whiteColor];
        [_nameLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        _nameLabel.backgroundColor = [UIColor clearColor];
        
        [headerView addSubview:_nameLabel];
        yOffset += (_nameLabel.frame.size.height + 2.0f);
        
        
        // 내 기수
        _classLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 150.0f, 14.0f)];
        _classLabel.text = profileDict[@"class"];
        _classLabel.textColor = [UIColor colorWithRed:170.0f/255.0f green:102.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
        [_classLabel setFont:[UIFont systemFontOfSize:12.0f]];
        _classLabel.backgroundColor = [UIColor clearColor];
        
        [headerView addSubview:_classLabel];
        
        
        // 설정 button
        UIImage *setImage = [UIImage imageNamed:@"ic_mf_setting"];
        UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        settingBtn.frame = CGRectMake(270.0f - 15.0f - setImage.size.width, _nameLabel.frame.origin.y + 4.0f, setImage.size.width, setImage.size.height);
        [settingBtn setImage:setImage forState:UIControlStateNormal];
//        [settingBtn setImage:[UIImage imageNamed:@"menu_img"] forState:UIControlStateHighlighted];
        [settingBtn addTarget:self action:@selector(onMyInfoSettingClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [headerView addSubview:settingBtn];
        
        // 라인
        UILabel *lineUp = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, headerView.frame.size.height - 2, headerView.frame.size.width, 1.0f)];
        lineUp.backgroundColor = UIColorFromRGB(0x1e2022);
        [self.view addSubview:lineUp];
        UILabel *lineDown = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, headerView.frame.size.height - 1, headerView.frame.size.width, 1.0f)];
        lineDown.backgroundColor = UIColorFromRGB(0x383c40);
        [self.view addSubview:lineDown];

    }
    
    
    // 주소록 목록 섹션 구성
    _addrMenuList = [@[[self classTotalViewController]] mutableCopy];
    
    // 설정 목록 섹션 구성
    MyInfoViewController *myInfoVC = [[MyInfoViewController alloc] init];
    FavoriteSettingViewController *fvSettingVC = [[FavoriteSettingViewController alloc] init];
    TermsViewController *termsVC = [[TermsViewController alloc] init];
    HelpViewController *helpVC = [[HelpViewController alloc] init];

    _settMenuList = @[@{@"type":[NSNumber numberWithInt:MenuViewTypeSettMyInfo], @"title":LocalizedString(@"My Page", @"내 정보설정"), @"icon":@"ic_mf_mypage", @"viewController":myInfoVC, @"color":@"0xffffff"},
                      @{@"type":[NSNumber numberWithInt:MenuViewTypeSettFavorite], @"title":LocalizedString(@"Favorite Settings", @"즐겨찾기 설정"), @"icon":@"ic_mf_bm", @"viewController":fvSettingVC, @"color":@"0xffffff"},
                      @{@"type":[NSNumber numberWithInt:MenuViewTypeSettTerms], @"title":LocalizedString(@"terms_text", @"약관 및 정책"), @"icon":@"ic_mf_terms", @"viewController":termsVC, @"color":@"0xffffff"},
                      @{@"type":[NSNumber numberWithInt:MenuViewTypeSettHelp], @"title":LocalizedString(@"Help", @"도움말"), @"icon":@"ic_mf_help", @"viewController":helpVC, @"color":@"0xffffff"}];
    

}

- (void)setAddrMenuList:(NSMutableArray *)addrMenuList
{
    NSLog(@"이전(주소록) 메뉴 목록 : %d", _addrMenuList.count);

    if (![addrMenuList isEqual:[NSNull null]])
    {
//        _addrMenuList = addrMenuList;
        [_addrMenuList setArray:addrMenuList];
        
        [_addrMenuList addObject:[self classTotalViewController]];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
//        });
        NSLog(@"update - 6");

    }
}


/// 주소록 전체보기 뷰 컨트롤러
- (NSDictionary *)classTotalViewController
{
    CourseTotalViewController *courseTotalVC = [[CourseTotalViewController alloc] init];
    
    NSDictionary *courseDict = @{@"type":[NSNumber numberWithInt:MenuViewTypeAddrTotalStudent], @"title":LocalizedString(@"Member List", @"전체보기"), @"icon":@"ic_mf_all", @"viewController":courseTotalVC, @"color":@"0xffffff"};
    
    return courseDict;
}


/// 메뉴 테이블 헤더 정보 업데이트
- (void)updateHeaderInfo
{
    NSDictionary *myInfo = [[UserContext shared] profileInfo];
    if ([myInfo[@"photourl"] length] > 0) {
        [_profileImgView setImageWithURL:[NSURL URLWithString:myInfo[@"photourl"]] placeholderImage:[UIImage imageNamed:@"ic_noimg_mypage"]];
    } else {
        [_profileImgView setImage:[UIImage imageNamed:@"ic_noimg_mypage"]];
    }
    
    if ([[UserContext shared].language isEqualToString:kLMKorean]) {
        if ([myInfo[@"name"] length] > 0) {
            _nameLabel.text = myInfo[@"name"];
        }
    } else {
        if ([myInfo[@"name_en"] length] > 0) {
            _nameLabel.text = myInfo[@"name_en"];
        }
    }
    
    
//    if ([myInfo[@"courseclass"] length] > 0) {
//        _classLabel.text = myInfo[@"courseclass"];
//    }
    NSString *class = [UserContext shared].myClass;
    if ([class length] > 0)
    {
        NSArray *findClasses = [DBMethod findCourseClass:class];
        if ([findClasses count] > 0)
        {
            NSDictionary *info = findClasses[0];
            NSLog(@"내 정보 : %@", info);
            
            if ([[UserContext shared].language isEqualToString:kLMKorean]) {
                _classLabel.text = info[@"title"];
            } else {
                _classLabel.text = info[@"title_en"];
            }
            
            // 로그인 유저 타입
            MemberType myType = (MemberType)[[[UserContext shared] memberType] integerValue];
            
            if (myType == MemberTypeFaculty) {
                [_classLabel setTextColor:UIColorFromRGB(0x3b5996)];
            } else if (myType == MemberTypeStaff) {
                [_classLabel setTextColor:UIColorFromRGB(0xaa66cc)];
            } else {
                // 로그인 교육 과정
                NSString *myCourseStr = [[UserContext shared] myCourse];
                if ([myCourseStr isEqualToString:@"EMBA"]) {
                    [_classLabel setTextColor:UIColorFromRGB(0x603913)];
                } else if ([myCourseStr isEqualToString:@"GMBA"]) {
                    [_classLabel setTextColor:UIColorFromRGB(0x669900)];
                } else if ([myCourseStr isEqualToString:@"SMBA"]) {
                    [_classLabel setTextColor:UIColorFromRGB(0x0099cc)];
                }
            }
        }
    }
}

- (void)updateHeaderImage:(UIImage *)image
{
    _profileImgView.image = image;
//    NSDictionary *myInfo = [[UserContext shared] profileInfo];
//    if ([myInfo[@"photourl"] length] > 0) {
//        [_profileImgView setImageWithURL:[NSURL URLWithString:myInfo[@"photourl"]] placeholderImage:[UIImage imageNamed:@"ic_noimg_mypage"]];
//    }
}

#pragma mark - UI Control Callbacks

/// 메뉴 설정 버튼 (내 정보 설정 화면)
- (void)onMyInfoSettingClicked
{
    [self menuNavigationController:MenuViewTypeSettMyInfo withMenuInfo:nil];
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
        sectionTitle = LocalizedString(@"address_title", @"즐겨찾기 주소록");
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
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
//    cell.textLabel.text = [NSString stringWithFormat:@"Item %d", indexPath.row];
    if (indexPath.section == 0)
    {
        if (indexPath.row == (_addrMenuList.count - 1)) {
            // (1)섹션의 마지막 메뉴는 전체보기 항목
            NSDictionary *dict = _addrMenuList[indexPath.row];
            NSLog(@"주소록 목록 : %@", [dict description]);
            
            if (![dict isEqual:[NSNull null]]) {
                cell.menuLabel.text = dict[@"title"];
                cell.iconName = dict[@"icon"];
                cell.rgbColor = UIColorFromRGB(0xcd5734);
            }
        } else {
            Course *course = _addrMenuList[indexPath.row];
            if ([[UserContext shared].language isEqualToString:kLMKorean]) {
                cell.menuLabel.text = course.title;
            } else {
                cell.menuLabel.text = course.title_en;
            }
            
            if ([course.type isEqualToString:@"2"]) {
                cell.iconName = @"ic_mf_prof";
            } else if ([course.type isEqualToString:@"3"]) {
                cell.iconName = @"ic_mf_staff";
            } else {
                if ([course.course isEqualToString:@"EMBA"]) {
                    cell.iconName = @"ic_mf_emba";
                }
                else if ([course.course isEqualToString:@"GMBA"]) {
                    cell.iconName = @"ic_mf_gmba";
                }
                else {
                    cell.iconName = @"ic_mf_smba";
                }

            }
            cell.rgbColor = UIColorFromRGB(0xaaaaaa);

        }
    
    } else {
        NSDictionary *dict = _settMenuList[indexPath.row];
        
        if (![dict isEqual:[NSNull null]]) {
            cell.menuLabel.text = dict[@"title"];
            cell.iconName = dict[@"icon"];
            cell.rgbColor = UIColorFromRGB(0xaaaaaa);
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
    sectionImageView.backgroundColor = UIColorFromRGB(0x232629);
//    sectionImageView.image = [[UIImage imageNamed:@"section_background"] stretchableImageWithLeftCapWidth:0.0f topCapHeight:0.0f];
    
    // 섹션 타이틀
    UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectInset(sectionImageView.frame, 10.0f, 0.0f)];
    sectionTitleLabel.font = [UIFont systemFontOfSize:13.0f];
    sectionTitleLabel.textAlignment = NSTextAlignmentLeft;;
    sectionTitleLabel.textColor = UIColorFromRGB(0xaaaaaa);
//    sectionTitleLabel.shadowColor = [UIColor colorWithRed:40.0f/255.0f green:45.0f/255.0f blue:57.0f/255.0f alpha:1.0f];
//    sectionTitleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    sectionTitleLabel.backgroundColor = [UIColor clearColor];
    sectionTitleLabel.text = titleString;
    
    [sectionImageView addSubview:sectionTitleLabel];
    
    
    // 라인
    UILabel *lineUp = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, sectionImageView.frame.size.height - 2, sectionImageView.frame.size.width, 1.0f)];
    lineUp.backgroundColor = UIColorFromRGB(0x1e2022);
    [sectionImageView addSubview:lineUp];
    UILabel *lineDown = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, sectionImageView.frame.size.height - 1, sectionImageView.frame.size.width, 1.0f)];
    lineDown.backgroundColor = UIColorFromRGB(0x383c40);
    [sectionImageView addSubview:lineDown];

    return sectionImageView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rect = cell.frame;
    
    [cell setBackgroundColor:UIColorFromRGB(0x2b2e31)];
    
    // selected cell background color
//    UIView *bgColorView = [[UIView alloc] init];
//    bgColorView.backgroundColor = UIColorFromRGB(0xcfd4e4);
//    
//    [cell setSelectedBackgroundView:bgColorView];

    
    // 라인
    UILabel *lineUp = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, rect.size.height - 2, rect.size.width, 1.0f)];
    lineUp.backgroundColor = UIColorFromRGB(0x1e2022);
    [cell addSubview:lineUp];
    UILabel *lineDown = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, rect.size.height - 1, rect.size.width, 1.0f)];
    lineDown.backgroundColor = UIColorFromRGB(0x383c40);
    [cell addSubview:lineDown];

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
            // 전체보기
            UIViewController *viewController = [menuDict objectForKey:@"viewController"];
            viewController.title = [menuDict objectForKey:@"title"];
            
            controllers = [NSArray arrayWithObject:viewController];
        }
        else
        {
            // 교수, 교직원, 과정 기수
//            Course *course = _addrMenuList[indexPath.row];
//            CourseClassViewController *courseClassVC = [[CourseClassViewController alloc] init];
//            courseClassVC.title = course.title;
//            
//            controllers = [NSArray arrayWithObject:courseClassVC];
            
            Course *courseClass = _addrMenuList[indexPath.row];
            
            if (courseClass)
            {
                NSLog(@"선택된 주소록 셀 : %@", courseClass);
                switch ([courseClass.type integerValue])
                {
                    case MemberTypeFaculty: // 교수진
                        {
                            [self menuNavigationController:MenuViewTypeAddrFaculty withMenuInfo:nil];
                            return;
                        }
                        break;
                        
                    case MemberTypeStaff:   // 교직원
                        {
                            [self menuNavigationController:MenuViewTypeAddrStaff withMenuInfo:nil];
                            return;
                        }
                        break;
                        
                    case MemberTypeStudent: // 학생  
                        {
                            // ( NSDictionary <- NSManagedObject )
                            NSArray *keys = [[[courseClass entity] attributesByName] allKeys];
                            NSDictionary *info = [courseClass dictionaryWithValuesForKeys:keys];
                            NSLog(@"메뉴의 학생 정보 : %@", info);

                            [self menuNavigationController:MenuViewTypeAddrStudent withMenuInfo:info];
                            return;
                        }
                        break;
                        
                    default:
                        NSLog(@"CourseClass Type unknown.");
                        break;
                }
            }
        }
    }
    else
    {
        menuDict = _settMenuList[indexPath.row];
        
        if (![menuDict isEqual:[NSNull null]])
        {
            if ([menuDict[@"type"] intValue] == MenuViewTypeSettMyInfo)
            {
                [self menuNavigationController:MenuViewTypeSettMyInfo withMenuInfo:nil];
                return;
            }
            else if ([menuDict[@"type"] intValue] == MenuViewTypeSettTerms)
            {
                [self menuNavigationController:MenuViewTypeSettTerms withMenuInfo:nil];
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
- (UINavigationController *)menuNavigationController:(MenuViewType)menuType withMenuInfo:(NSDictionary *)info
{
//    UINavigationController *nav = nil;
    NSArray *controllers = nil;
    
    switch (menuType)
    {
        case MenuViewTypeAddrFaculty:   //< 교수진 전공 목록 화면으로 이동
            {
    //            CourseClassViewController *viewController = [[CourseClassViewController alloc] init];
    ////            nav = [[PortraitNavigationController alloc] initWithRootViewController:viewController];
    //            controllers = @[viewController];
                
                FacultyMajorViewController *viewController = [[FacultyMajorViewController alloc] init];
                
                self.menuContainerViewController.centerViewController = [self navigationController:viewController];
            }
            break;
            
        case MenuViewTypeAddrStaff:     //< 교직원 목록 화면으로 이동
            {
                StaffAddressViewController *viewController = [[StaffAddressViewController alloc] init];
                
                self.menuContainerViewController.centerViewController = [self navigationController:viewController];
            }
            break;
            
        case MenuViewTypeAddrStudent:   //< 해당 기수의 학생 목록 화면으로 이동
            {
                StudentAddressViewController *viewController = [[StudentAddressViewController alloc] initWithInfo:info];
                
                self.menuContainerViewController.centerViewController = [self navigationController:viewController];

//                CourseTotalViewController *totalVC = [[CourseTotalViewController alloc] init];
//                controllers = @[totalVC];
//                self.menuContainerViewController.centerViewController = [self navigationController:totalVC];
            }
            break;

        case MenuViewTypeSettMyInfo:    //< 내 정보 설정 화면으로 이동
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
