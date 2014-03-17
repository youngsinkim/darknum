//
//  SearchResultViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 8..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "SearchResultViewController.h"
#import "StudentAddressCell.h"
#import "Course.h"
#import "Student.h"

#import "PortraitNavigationController.h"
#import "ToolViewController.h"
#import "SmsViewController.h"

#import "TSLanguageManager.h"
#import "NSString+MD5.h"
#import "DetailViewController.h"

@interface SearchResultViewController ()
{
    LoadingStatus _loadingStatus;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) StudentToolView *footerToolView;
@property (strong, nonatomic) UITableView *resultTableView;
@property (strong, nonatomic) NSMutableArray *results;
@property (strong, nonatomic) NSDictionary *info;

@end

@implementation SearchResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = LocalizedString(@"Search Result", @"검색 결과");
        _loadingStatus = LoadingStatusBefore;

    }
    return self;
}

- (id)initWithInfo:(NSDictionary *)searchInfo
{
    self = [super init];
    if (self)
    {
        self.navigationItem.title = LocalizedString(@"Search Result", @"검색 결과");
        
        _info = searchInfo;
        NSLog(@"검색 조건 : %@", _info);
        
        _results = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    self.view.backgroundColor = UIColorFromRGB(0xf0f0f0);
    
    // CoreData 컨텍스트 지정
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (self.managedObjectContext == nil)
    {
        self.managedObjectContext = [appDelegate managedObjectContext];
        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
    }

    // 검색 결과 화면
    [self setupSearchResultUI];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([_info[@"islocal"] boolValue] == YES)
    {
        // db에서 검색
        [_results setArray:[self searchLocalDB]];
        NSLog(@"가져온 것 : %@", _results);
        
        if ([_results count] > 0) {
            [_resultTableView reloadData];
        }
    } else {
        // 서버에서 검색
        [self requestAPIStudents];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 검색 결과 화면
- (void)setupSearchResultUI
{
    CGRect rect = self.view.frame;
    rect.size.height -= kStudentToolH;
    
    if (IS_LESS_THEN_IOS7) {
        rect.size.height -= 44.0f;
    } else {
        rect.size.height -= 64.0f;
    }
    
    // 검색결과 테이블 뷰
    _resultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height)];
    _resultTableView.backgroundColor = [UIColor whiteColor];
    _resultTableView.dataSource = self;
    _resultTableView.delegate = self;
    
    [self.view addSubview:_resultTableView];
    
    if (!IS_LESS_THEN_IOS7) {
        UIEdgeInsets edges;
        edges.left = 0;
        _resultTableView.separatorInset = edges;
    }

    
    // 툴바
    _footerToolView = [[StudentToolView alloc] initWithFrame:CGRectMake(0.0f, rect.size.height, rect.size.width, kStudentToolH)];
    _footerToolView.delegate = self;
    
    [self.view addSubview:_footerToolView];
}


#pragma mark - DB methods

/// DB에서 검색
- (NSArray *)searchLocalDB
{
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // * (column)
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setRelationshipKeyPathsForPrefetching:@[@"course"]];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSDictionary *properties = [entity propertiesByName];
    NSMutableArray *propertiesToFetch = [NSMutableArray arrayWithArray:[properties allValues]];// arrayWithObject:[properties allValues], @"major.title", nil];
    [propertiesToFetch addObject:@"course.course"];
    [fetchRequest setPropertiesToFetch:[propertiesToFetch mutableCopy]];
    
    NSLog(@"찾을 기수 : %@", _info);
    NSPredicate *predicate = nil;
    if ([_info[@"name"] length] > 0 && [_info[@"courseclass"] length] > 0) {
        if ([[UserContext shared].language isEqualToString:kLMKorean]) {
            predicate = [NSPredicate predicateWithFormat:@"classtitle contains[cd] %@ AND name contains[cd] %@", _info[@"courseclass"], _info[@"name"]];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"classtitle_en contains[c] %@ AND name_en contains[c] %@", _info[@"courseclass"], _info[@"name"]];
        }
    } else if ([_info[@"courseclass"] length] > 0) {
        if ([[UserContext shared].language isEqualToString:kLMKorean]) {
            predicate = [NSPredicate predicateWithFormat:@"classtitle contains[cd] %@", _info[@"courseclass"]];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"classtitle_en contains[cd] %@", _info[@"courseclass"]];
        }
    } if ([_info[@"name"] length] > 0 && [_info[@"course"] length] > 0) {
        if ([[UserContext shared].language isEqualToString:kLMKorean]) {
            predicate = [NSPredicate predicateWithFormat:@"course.course contains[cd] %@ AND name contains[cd] %@", _info[@"course"], _info[@"name"]];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"course.course contains[c] %@ AND name_en contains[c] %@", _info[@"course"], _info[@"name"]];
        }
    } else if ([_info[@"course"] length] > 0) {
            predicate = [NSPredicate predicateWithFormat:@"course.course contains[cd] %@", _info[@"course"]];
    } else if ([_info[@"name"] length] > 0) {
        if ([[UserContext shared].language isEqualToString:kLMKorean]) {
            predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", _info[@"name"]];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"name_en contains[c] %@", _info[@"name"]];
        }
    }
    [fetchRequest setPredicate:predicate];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);

    _loadingStatus = LoadingStatusLoaded;
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
        for (NSDictionary *info in fetchedObjects) {
            NSLog(@"DB에서 읽은 학생 정보 : %@", info);
        }

        // 검색된 학생 목록 저장
        return fetchedObjects;
    }
    return nil;
}


#pragma mark - Network API
/// 해당 기수의 학생 목록 요청
- (void)requestAPIStudents
{
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    
    NSString *lang = [UserContext shared].language;
    
    //    param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo, @"lang":lang, @"course":_info[@"course"], @"class":_info[@"courseclass"], @"name":_info[@"name"]};
    NSMutableDictionary *param = [[NSMutableArray alloc] init];
    param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo, @"lang":lang, @"name":_info[@"name"]};
    if (_info[@"course"]) {
        [param setObject:_info[@"course"] forKey:@"course"];
    }
    if (_info[@"courseclass"]) {
        [param setObject:_info[@"courseclass"] forKey:@"class"];
    }

    NSLog(@"(/fb/students) Request Parameter : %@", param);
    
    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
    
    // 과정별 기수 목록
    [[SMNetworkClient sharedClient] postStudents:param
                                           block:^(NSMutableArray *result, NSError *error) {
                                               
                                               [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                                               
                                               NSLog(@"결과 : %@", result);

                                               if (error) {
                                                   [[SMNetworkClient sharedClient] showNetworkError:error];
                                               }
                                               else
                                               {
                                                   // 기수 학생 목록
                                                   [_results setArray:result];
                                                   
                                                   NSLog(@"(%@)기수 학생 수 : %d", _info[@"courseclass"], [_results count]);
                                               }
                                               
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   //                                                      [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
                                                   _loadingStatus = LoadingStatusLoaded;

                                                   [_resultTableView reloadData];
                                               });

                                               
                                           }];
}


#pragma mark - UITableView DataSources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([_results count] > 0)? [_results count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([_results count] > 0)? kStudAddressCellH : self.view.frame.size.height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2) {
        [cell setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    }
    else {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    
    // selected cell background color
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = UIColorFromRGB(0xcfd4e4);
    
    [cell setSelectedBackgroundView:bgColorView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_results count] == 0)
    {
        if (_loadingStatus == LoadingStatusLoaded)
        {
            static NSString *identifier = @"NotResultCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.contentView.backgroundColor = UIColorFromRGB(0xf0f0f0);
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIImageView *noDataImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_search_no"]];
                noDataImageView.tag = 600;
                noDataImageView.center = CGPointMake(320.0f / 2, 200.0f / 2);
                
                [cell.contentView addSubview:noDataImageView];
                
                
                // 검색 결과가 없습니다.
                UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, noDataImageView.frame.origin.y + noDataImageView.frame.size.height + 10.0f, 320.0f, 20.0f)];
                noDataImageView.tag = 601;
                [noDataLabel setTextColor:UIColorFromRGB(0x555555)];
                [noDataLabel setBackgroundColor:[UIColor clearColor]];
                [noDataLabel setFont:[UIFont systemFontOfSize:13.0f]];
                [noDataLabel setTextAlignment:NSTextAlignmentCenter];
                [noDataLabel setText:LocalizedString(@"Search Result Not Founded", "검색된 결과가 없습니다.")];

                [cell.contentView addSubview:noDataLabel];
            }
            
//            UIImageView *imgaeView = (UIImageView *)[cell.contentView viewWithTag:600];
//            if (imgaeView != nil) {
//                imgaeView.center = CGPointMake(320.0f / 2, 200.0f / 2);
//            }
            
            tableView.scrollEnabled = NO;
            return cell;
        }
        else
        {
            static NSString *identifier = @"NoResultCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.contentView.backgroundColor = UIColorFromRGB(0xf0f0f0);
            }
            
            return cell;
        }
    }
    
    static NSString *identifier = @"ResultCell";
    StudentAddressCell *cell = (StudentAddressCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[StudentAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([_results count] > 0)
    {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        
//        if ([_students[indexPath.row] isKindOfClass:[NSDictionary class]])
//        {
//            // 서버에서 받아온 데이터는 NSDictionary.
//            [dict setDictionary:_students[indexPath.row]];
//        }
//        else
//        {
//            // DB에서 읽으면 NSManagedObject
//            Student *student = _students[indexPath.row];
//            
//            // ( NSDictionary <- NSManagedObject )
//            NSArray *keys = [[[student entity] attributesByName] allKeys];
//            [dict setDictionary:[student dictionaryWithValuesForKeys:keys]];
//        }
        NSLog(@"학생 목록 셀 정보 : %@", _results[indexPath.row]);
        
        [cell setCellInfo:_results[indexPath.row]];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"선택한 셀 => (%i / %i)", indexPath.row, indexPath.section);
 
    if ([_results count] > 0)
    {
        self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
        
        DetailViewController *viewController = [[DetailViewController alloc] initWithType:MemberTypeStudent];
        viewController.currentIdx = indexPath.row;
        viewController.contacts = [_results mutableCopy];
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    //    Student *student = _students[indexPath.row];
    
//    StudentDetailViewController *viewController = [[StudentDetailViewController alloc] initWithInfo:[_students mutableCopy]];
//    [self.navigationController pushViewController:viewController animated:YES];
    
    //    NSDictionary *majorInfo = [_students[indexPath.row] mutableCopy];
    //    if ([majorInfo isKindOfClass:[NSDictionary class]])
    {
        //        NSLog(@"선택된 셀 정보 : %@", majorInfo);
        
        // 전공에 해당하는 교수 목록 화면으로, (type = faculty, dict = 전공 정보)
        
        //        FacultyAddressViewController *facultyAddressVC = [[FacultyAddressViewController alloc] init];
        //        AddressViewController *addressVC = [[AddressViewController alloc] initWithType:MemberTypeFaculty info:majorInfo];
        //        [self.navigationController pushViewController:addressVC animated:YES];
    }
}


#pragma mark - Callback methods
// 학생 주소록 하단 툴 버튼
- (void)didSelectedToolTag:(NSNumber *)type
{
    switch ([type intValue])
    {
        case 0: // sms
            [self onSmsViewController];
            break;
            
        case 1: // email
            [self onEmailViewController];
            break;
            
        case 2: // address book
            [self onAddressViewController];
            break;
            
        default:
            break;
    }
    
}

- (void)onSmsViewController
{
    ToolViewController *toolVC = [[ToolViewController alloc] initWithInfo:_results viewType:ToolViewTypeSms memberType:MemberTypeStudent];
    toolVC.navigationItem.title = self.navigationItem.title;
    
    PortraitNavigationController *nav = [[PortraitNavigationController alloc] initWithRootViewController:toolVC];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];

//    SmsViewController *smsVC = [[SmsViewController alloc] init];
//    smsVC.navigationItem.title = _info[@"title"];
//    smsVC.view.backgroundColor = [UIColor whiteColor];
//    [smsVC setMembers:_results];
//    
//    PortraitNavigationController *nav = [[PortraitNavigationController alloc] initWithRootViewController:smsVC];
//    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)onEmailViewController
{
    ToolViewController *toolVC = [[ToolViewController alloc] initWithInfo:_results viewType:ToolViewTypeEmail memberType:MemberTypeStudent];
    toolVC.navigationItem.title = self.navigationItem.title;
    
    PortraitNavigationController *nav = [[PortraitNavigationController alloc] initWithRootViewController:toolVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)onAddressViewController
{
    
}

@end
