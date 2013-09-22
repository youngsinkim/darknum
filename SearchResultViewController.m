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


@interface SearchResultViewController ()

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
        self.navigationItem.title = @"검색 결과";
        
    }
    return self;
}

- (id)initWithInfo:(NSDictionary *)searchInfo
{
    self = [super init];
    if (self)
    {
        self.navigationItem.title = @"검색 결과";
        
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
    
    // CoreData 컨텍스트 지정
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (self.managedObjectContext == nil)
    {
        self.managedObjectContext = [appDelegate managedObjectContext];
        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
    }

    // 검색 결과 화면
    [self setupSearchResultUI];

    
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
    CGRect rect = self.view.bounds;
    rect.size.height -= kStudentToolH;
    
    if (IS_LESS_THEN_IOS7) {
        rect.size.height -= 44.0f;
    }
    
    // 검색결과 테이블 뷰
    _resultTableView = [[UITableView alloc] initWithFrame:rect];
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
    //    NSAttributeDescription *type = [entity.attributesByName objectForKey:@"course"];
    //    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:type, nil]];
    //    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:type]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    [fetchRequest setRelationshipKeyPathsForPrefetching:@[@"class_info"]];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSLog(@"찾을 기수 : %@", _info[@"courseclass"]);
    NSPredicate *predicate = nil;
    if ([_info[@"name"] length] > 0) {
        predicate = [NSPredicate predicateWithFormat:@"class_info.courseclass == %@ AND name == %@", _info[@"courseclass"], _info[@"name"]];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"class_info.courseclass == %@", _info[@"courseclass"]];
    }
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
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
    
    NSString *lang = [TSLanguageManager selectedLanguage];
    
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo, @"lang":lang, @"course":_info[@"course"], @"courseclass":_info[@"courseclass"], @"name":_info[@"name"]};
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
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       //                                                      [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
                                                       [_resultTableView reloadData];
                                                   });
                                                   
                                               }
                                               
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_results count] == 0)
    {
        static NSString *identifier = @"NoResultCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
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
    
//    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
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
    ToolViewController *toolVC = [[ToolViewController alloc] initWithInfo:_results viewType:ToolViewTypeSms];
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
    ToolViewController *toolVC = [[ToolViewController alloc] initWithInfo:_results viewType:ToolViewTypeEmail];
    toolVC.navigationItem.title = self.navigationItem.title;
    
    PortraitNavigationController *nav = [[PortraitNavigationController alloc] initWithRootViewController:toolVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)onAddressViewController
{
    
}

@end
