//
//  FacultyMajorViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FacultyMajorViewController.h"
#import "AddressViewController.h"
#import "MajorCell.h"
#import "Major.h"
#import "FacultyAddressViewController.h"
#import "NSString+MD5.h"
#import "UIViewController+LoadingProgress.h"

@interface FacultyMajorViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *majorTableView;  // 전공 테이블
@property (strong, nonatomic) NSMutableArray *majors;       // 전공 목록

@end


@implementation FacultyMajorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = LocalizedString(@"faculty_text", @"교수진");
        _majors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // CoreData 컨텍스트 지정
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (self.managedObjectContext == nil) {
        self.managedObjectContext = [appDelegate managedObjectContext];
        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
    }

    // 교수진 전공 화면 구성
    [self setupMajorUI];

#if (0)
    // 교수진 전공 목록 서버에서 가져오기
    [self requestAPIMajors];
#else
    // 교수진 목록은 초기에 즐겨찾기 업데이트를 통해 모두 가져오므로 전공 목록은 DB에서 가져오면 됨.
    [_majors setArray:[self loadDBMajors]];
#endif
    [_majorTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 교수 전공 목록 화면 구성
- (void)setupMajorUI
{
    _majorTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
//    _majorTableView.backgroundColor = [UIColor greenColor];
    _majorTableView.dataSource = self;
    _majorTableView.delegate = self;
    
    [self.view addSubview:_majorTableView];
    
    if (!IS_LESS_THEN_IOS7) {
        UIEdgeInsets edges;
        edges.left = 0;
        _majorTableView.separatorInset = edges;
    }
}


#pragma mark - DB methods

/// 교수진 전공 목록 db에서 가져오기
- (NSArray *)loadDBMajors
{
    NSError *error = nil;
    
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Major" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setResultType:NSDictionaryResultType];

//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(major.major == %@)", majorValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title != ''"];
    [fetchRequest setPredicate:predicate];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
//    if (fetchedObjects && [fetchedObjects count] > 0)
//    {
        return fetchedObjects;
//    }
//    return nil;
}


#pragma mark - UITableView DataSources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([_majors count] > 0)? [_majors count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([_majors count] > 0)? kMajorCellH : self.view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_majors count] == 0)
    {
        static NSString *identifier = @"NoMajorCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"MajorCell";
    MajorCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[MajorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    if ([_majors count] > 0)
    {
#if (1)
        NSDictionary *majorInfo = _majors[indexPath.row];

//        cell.titleLabel.text = major.title;
//        [cell setMemType:[course.type integerValue] WidhCount:[course.count integerValue]];
        cell.textLabel.text = majorInfo[@"title"];
#else
        // db에서 가져오면 managedObject로 받음
        Major *major = _majors[indexPath.row];
    NSLog(@"major (%d) : %@, %@", indexPath.row, major.title, major);
        cell.textLabel.text = major.title;
#endif
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"선택한 셀 => (%i / %i)", indexPath.row, indexPath.section);
    
    NSDictionary *majorInfo = [_majors[indexPath.row] mutableCopy];
    if ([majorInfo isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"선택된 셀 정보 : %@", majorInfo);
        
        // 전공에 해당하는 교수 목록 화면으로, (type = faculty, dict = 전공 정보)
        
        FacultyAddressViewController *viewController = [[FacultyAddressViewController alloc] initWithInfo:majorInfo];
//        AddressViewController *viewController = [[AddressViewController alloc] initWithType:MemberTypeFaculty info:majorInfo];
        viewController.navigationItem.title = majorInfo[@"title"];
    
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - Network API

/// 과정별 기수 목록 가져오기
- (void)requestAPIMajors
{
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }

    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};
    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
    
    // 과정별 기수 목록
    [[SMNetworkClient sharedClient] postMajors:param
                                         block:^(NSArray *result, NSError *error) {
                                             
                                              [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
        
                                              if (error)
                                              {
                                                  [[SMNetworkClient sharedClient] showNetworkError:error];
                                              }
                                              else
                                              {
                                                  // 전공 목록은 db 저장 없이 tableview만 업데이트
//                                                  NSArray *majorList = [result mutableCopy];
//                                                  [_majors setArray:majorList];
                                                  [_majors setArray:result];
                                                  NSLog(@"전공 목록 (%d) : %@", [_majors count], _majors);
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
//                                                      [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
                                                      [self.majorTableView reloadData];
                                                  });
                                                  
                                              }
                                          }];
}

@end
