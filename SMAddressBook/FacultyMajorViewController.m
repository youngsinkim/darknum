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
//#import "Major.h"
//#import "FacultyAddressViewController.h"
#import "NSString+MD5.h"

@interface FacultyMajorViewController ()

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
    
    // 교수진 전공 화면 구성
    [self setupMajorUI];
    
    // 교수진 전공 목록 서버에서 가져오기
    [self requestAPIMajor];
    
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
        NSDictionary *majorInfo = _majors[indexPath.row];

//        cell.titleLabel.text = major.title;
//        [cell setMemType:[course.type integerValue] WidhCount:[course.count integerValue]];
        cell.textLabel.text = majorInfo[@"title"];
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
        
//        FacultyAddressViewController *facultyAddressVC = [[FacultyAddressViewController alloc] init];
        AddressViewController *addressVC = [[AddressViewController alloc] initWithType:MemberTypeFaculty info:majorInfo];
        
        [self.navigationController pushViewController:addressVC animated:YES];
    }
}

#pragma mark - Network API

/// 과정별 기수 목록 가져오기
- (void)requestAPIMajor
{
    NSString *mobileNo = @"01023873856";
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
    NSString *certNo = [[NSUserDefaults standardUserDefaults] objectForKey:kUserCertNo];
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    
    // background Dimmed
    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
    
    // 과정별 기수 목록
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};
    [[SMNetworkClient sharedClient] postMajors:param
                                         block:^(NSMutableArray *result, NSError *error) {
                                             
                                              [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
        
                                              if (error) {
                                                  [[SMNetworkClient sharedClient] showNetworkError:error];
                                              }
                                              else {
                                                  // 전공 목록은 db 저장 없이 tableview만 업데이트
                                                  NSArray *majorList = [result mutableCopy];
                                                  [_majors setArray:majorList];
                                                  NSLog(@"전공 개수 : %d, %@", [_majors count], majorList);
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
//                                                      [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
                                                      [self.majorTableView reloadData];
                                                  });
                                                  
                                              }
                                             
                                          }];
}

@end
