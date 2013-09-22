//
//  StudentAddressViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "StudentAddressViewController.h"
#import "StudentAddressCell.h"

#import "DetailViewController.h"
#import "DetailInfoViewController.h"
#import "StudentDetailViewController.h"
#import "Course.h"
#import "Student.h"

#import "PortraitNavigationController.h"
#import "SmsViewController.h"
#import "ToolViewController.h"

#import "TSLanguageManager.h"
#import "NSString+MD5.h"


@interface StudentAddressViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) StudentToolView *footerToolView;
@property (strong, nonatomic) UITableView *studentTableView;    //< 학생 테이블
@property (strong, nonatomic) NSMutableArray *students;         //< 기수 학생 목록
@property (strong, nonatomic) NSDictionary *info;               //< db 조회를 위해 넘겨받은 해당 기수 정보

@end

@implementation StudentAddressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self)
    {
        _info = [NSDictionary dictionaryWithDictionary:info];
        NSLog(@"학생 정보 : %@", _info);

        self.navigationItem.title = _info[@"title"];

        _students = [[NSMutableArray alloc] init];
    
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
    
    // 기수 학생목록 화면 구성
    [self setupStudentAddressUI];
    
    // 학생 목록 DB에서 가져오기
    [_students setArray:[self loadDBFilteredStudents]];
    
    if ([_students count] == 0) {
        // 전체보기에서 들어올 경우는 즐겨찾기로 저장된 기수가 아니면 db에 목록이 존재하지 않으므로 서버로 요청한다...
        [self requestAPIStudents];
    }
    else {
        [_studentTableView reloadData];
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.menuContainerViewController.panMode = MFSideMenuPanModeDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 해당 기수별 학생 목록 화면
- (void)setupStudentAddressUI
{
    CGRect rect = self.view.bounds;
    rect.size.height -= kStudentToolH;
    
    if (IS_LESS_THEN_IOS7) {
        rect.size.height -= 44.0f;
    }
    
    // 학생 테이블 뷰
    _studentTableView = [[UITableView alloc] initWithFrame:rect];
//    _studentTableView = [UIColor greenColor];
    _studentTableView.dataSource = self;
    _studentTableView.delegate = self;
    
    [self.view addSubview:_studentTableView];
    
    if (!IS_LESS_THEN_IOS7) {
        UIEdgeInsets edges;
        edges.left = 0;
        _studentTableView.separatorInset = edges;
    }

    
    // 툴바
    _footerToolView = [[StudentToolView alloc] initWithFrame:CGRectMake(0.0f, rect.size.height, rect.size.width, kStudentToolH)];
    _footerToolView.delegate = self;
//    _footerToolView.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:_footerToolView];
}

#pragma mark - DB methods

/// 동일 기수의 학생 목록 DB에서 가져오기.
- (NSArray *)loadDBFilteredStudents
{
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // * (column)
//    NSAttributeDescription *type = [entity.attributesByName objectForKey:@"course"];
//    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:type, nil]];
//    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:type]];
//    [fetchRequest setResultType:NSDictionaryResultType];

    NSLog(@"찾을 기수 : %@", _info[@"courseclass"]);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"courseclass == %@", _info[@"courseclass"]];
    [fetchRequest setPredicate:predicate];
    
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
//        for (Course *info in fetchedObjects) {
//            NSLog(@"Name: %@", info.courseclass);
//            Student * = info.students;
//            NSLog(@"Zip: %@", details.zip);
//        }
        
//        NSLog(@"가져온 것 : %@", fetchedObjects[0]);
//        NSDictionary *dict = fetchedObjects[0];
//        NSLog(@"기수 학생 : %@\n%@", dict, dict[@"students"]);
//        return dict[@"students"];
        
        Course *class = fetchedObjects[0];
        if (class)
        {
//            for (NSManagedObject *info in fetchedObjects) {
//                NSLog(@"Name: %@", [info valueForKey:@"name"]);
//            NSDictionary *classInfo = [class valueForKey:@"student"];
//            NSLog(@"class info : %@", classInfo);
            
            NSMutableArray *classStudents = [[NSMutableArray alloc] init];
            NSArray *list = (NSArray *)class.students;
            
            for (Student *student in list)
            {
                // DB에서 읽으면 NSManagedObject
//                Student *student = _students[indexPath.row];
                
                // ( NSDictionary <- NSManagedObject )
                NSArray *keys = [[[student entity] attributesByName] allKeys];
//                [dict setDictionary:[student dictionaryWithValuesForKeys:keys]];
                NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[student dictionaryWithValuesForKeys:keys]];
                NSLog(@"dict : %@", dict);
                [classStudents addObject:dict];
            }
            
//            NSMutableArray *classStudents = [[class.students allObjects] mutableCopy];
            NSLog(@"student count : %d, %d", [class.students count], [classStudents count]);

            return classStudents;
        }
//        return fetchedObjects;
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
    
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo, @"lang":lang, @"courseclass":_info[@"courseclass"]};
    NSLog(@"(/fb/students) Request Parameter : %@", param);
    
    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
    
    // 과정별 기수 목록
    [[SMNetworkClient sharedClient] postStudents:param
                                           block:^(NSMutableArray *result, NSError *error) {
                                               
                                               [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                                               
                                               if (error) {
                                                   [[SMNetworkClient sharedClient] showNetworkError:error];
                                               }
                                               else
                                               {
                                                   // 기수 학생 목록
                                                   [_students setArray:[result mutableCopy]];
                                                   NSLog(@"(%@)기수 학생 수 : %d", _info[@"courseclass"], [_students count]);
                                               
                                                   dispatch_async(dispatch_get_main_queue(), ^{
//                                                      [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
                                                       [_studentTableView reloadData];
                                                   });
                                                 
                                               }
                                             
                                           }];
}


#pragma mark - UITableView DataSources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([_students count] > 0)? [_students count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([_students count] > 0)? kStudAddressCellH : self.view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_students count] == 0)
    {
        static NSString *identifier = @"NoStudentCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"StudentCell";
    StudentAddressCell *cell = (StudentAddressCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[StudentAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([_students count] > 0)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
        if ([_students[indexPath.row] isKindOfClass:[NSDictionary class]])
        {
            // 서버에서 받아온 데이터는 NSDictionary.
            [dict setDictionary:_students[indexPath.row]];
        }
        else
        {
            // DB에서 읽으면 NSManagedObject
            Student *student = _students[indexPath.row];
        
            // ( NSDictionary <- NSManagedObject )
            NSArray *keys = [[[student entity] attributesByName] allKeys];
            [dict setDictionary:[student dictionaryWithValuesForKeys:keys]];
        }
        NSLog(@"학생 목록 셀 정보 : %@", dict);
    
        [cell setCellInfo:dict];

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"선택한 셀 => (%i / %i)", indexPath.row, indexPath.section);
    
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
//    Student *student = _students[indexPath.row];
    
//    StudentDetailViewController *viewController = [[StudentDetailViewController alloc] initWithInfo:[_students mutableCopy]];
    DetailViewController *viewController = [[DetailViewController alloc] initWithType:MemberTypeStudent];
//    DetailInfoViewController *viewController = [[DetailInfoViewController alloc] initWithType:MemberTypeStudent];
    viewController.currentIdx = indexPath.row;
    viewController.contacts = [_students mutableCopy];
    
    [self.navigationController pushViewController:viewController animated:YES];

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
//        Student *mo = _contacts[_currentIdx];
//        NSLog(@"선택된 셀 : %d, %@", _currentIdx, mo.name_en);
//
//        // ( NSDictionary <- NSManagedObject )
//        NSArray *keys = [[[mo entity] attributesByName] allKeys];
//        NSDictionary *info = [mo dictionaryWithValuesForKeys:keys];
    
//    NSDictionary *info = _students[_currentIdx];
//    NSLog(@"선택된 셀 정보 (%d) : %@", _currentIdx, info);
    
    switch ([type intValue])
    {
        case 0: // sms
            [self onSmsViewController];
            break;
            
        case 1: // email
            [self onEmailViewController];
            break;
            
//        case 2: // address book
//            [self onAddressViewController];
//            break;
            
        default:
            break;
    }

}

/// SMS 발송 버튼
- (void)onTouchedSmsBtn:(id)sender
{
    SmsViewController *smsVC = [[SmsViewController alloc] init];
    smsVC.navigationItem.title = _info[@"title"];
    smsVC.view.backgroundColor = [UIColor whiteColor];
    [smsVC setMembers:_students];
    
    PortraitNavigationController *nav = [[PortraitNavigationController alloc] initWithRootViewController:smsVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)onSmsViewController
{
    ToolViewController *toolVC = [[ToolViewController alloc] initWithInfo:_students viewType:ToolViewTypeSms];
    toolVC.navigationItem.title = self.navigationItem.title;
    
    PortraitNavigationController *nav = [[PortraitNavigationController alloc] initWithRootViewController:toolVC];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];

//    SmsViewController *smsVC = [[SmsViewController alloc] init];
//    smsVC.navigationItem.title = _info[@"title"];
//    smsVC.view.backgroundColor = [UIColor whiteColor];
//    [smsVC setMembers:_students];
//    
//    PortraitNavigationController *nav = [[PortraitNavigationController alloc] initWithRootViewController:smsVC];
//    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)onEmailViewController
{
    ToolViewController *toolVC = [[ToolViewController alloc] initWithInfo:_students viewType:ToolViewTypeEmail];
    toolVC.navigationItem.title = self.navigationItem.title;
    
    PortraitNavigationController *nav = [[PortraitNavigationController alloc] initWithRootViewController:toolVC];

    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)onNaviBarBtnClose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onAddressViewController
{
    
}
@end
