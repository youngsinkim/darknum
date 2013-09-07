//
//  SearchResultViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 8..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "SearchResultViewController.h"

@interface SearchResultViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *resultTableView;
@property (strong, nonatomic) NSMutableArray *results;
@property (strong, nonatomic) NSDictionary *searchInfo;

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
        
        _searchInfo = searchInfo;
        NSLog(@"검색 조건 : %@", _searchInfo);
        
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
    rect.size.height -= (44 + 60);
    
    // 검색결과 테이블 뷰
    _resultTableView = [[UITableView alloc] initWithFrame:rect];
    _resultTableView.dataSource = self;
    _resultTableView.delegate = self;
    
    [self.view addSubview:_resultTableView];
    
    
    // 툴바
//    _footerToolView = [[StudentToolView alloc] initWithFrame:CGRectMake(0.0f, rect.size.height, rect.size.width, kStudentToolH)];
//    _footerToolView.delegate = self;
//    _footerToolView.backgroundColor = [UIColor blueColor];
//    
//    [self.view addSubview:_footerToolView];
}


#pragma mark - UITableView DataSources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([_results count] > 0)? [_results count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([_results count] > 0)? 50.0f : self.view.frame.size.height;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
//        NSLog(@"학생 목록 셀 정보 : %@", dict);
//        
//        [cell setCellInfo:dict];
        
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


@end
