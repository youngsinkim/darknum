//
//  CourseClassViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "CourseClassViewController.h"
#import "DetailViewController.h"
#import "ContactCell.h"

@interface CourseClassViewController ()

@property (strong, nonatomic) UITableView *contactTableView;    //< 주소록 테이블 뷰
@property (strong, nonatomic) NSMutableArray *contacts;         //< 주소록 목록

@end

@implementation CourseClassViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _contacts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // imsi
    [self setAssets];
    
    // 주소록 테이블 뷰
    [self setupTableView];
    
    // 주소록 하단 툴바 뷰
//    [self setupFooterView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 주소록 테이블 뷰
- (void)setupTableView
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    
    _contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height - 44.0f - 50.0f) style:UITableViewStylePlain];
    _contactTableView.dataSource = self;
    _contactTableView.delegate = self;
//    _contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contactTableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    
    [self.view addSubview:_contactTableView];
    
}

/// 주소록 하단 툴바 뷰
//- (void)setupFooterView
//{
//    _addressToolbarVC = [[AddressToolbarViewController alloc] init];
//    _addressToolbarVC.view.frame = CGRectMake(0.0f, self.view.bounds.size.height - 100.0f, 320.0f, 100.0f);
//    
//    [self addChildViewController:_addressToolbarVC];
//    [self.view addSubview:_addressToolbarVC.view];
//    
//    [_addressToolbarVC didMoveToParentViewController:self];
//    
//}

/// 주소록 테스트 데이터
- (void)setAssets
{
    // type => 0:교수 1:교직원 2:학생
    _contacts = [@[
                 @{@"name":LocalizedString(@"홍길동", nil), @"type":@"0", @"desc":@"(주)젠다소프트 소프트웨어 사업부", @"mobile":@"010-0000-0000", @"email":@"smba@snu.ac.kr"},
                 @{@"name":LocalizedString(@"김철수", nil), @"type":@"0", @"desc":@"[재학] 젠다소프트 | 소프트웨어사업부 팀장", @"mobile":@"010-0000-0000", @"email":@"smba@snu.ac.kr"},
                 @{@"name":LocalizedString(@"홍길동", nil), @"type":@"0", @"desc":@"[재학] 젠다소프트 | 소프트웨어사업부 팀장", @"mobile":@"010-0000-0000", @"email":@"smba@snu.ac.kr"},
                 @{@"name":LocalizedString(@"홍길동", nil), @"type":@"0", @"desc":@"[재학] 젠다소프트 | 소프트웨어사업부 팀장", @"mobile":@"010-0000-0000", @"email":@"smba@snu.ac.kr"}] mutableCopy];
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([_contacts count] > 0)? [_contacts count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([_contacts count] > 0)? kContactCellH : self.view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_contacts count] == 0)
    {
        static NSString *identifier = @"NoAddressCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"AddressCell";
    ContactCell *cell = [self.contactTableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([_contacts count] > 0)
    {
        // 주소록 셀 정보
        NSDictionary *cellInfo = [_contacts objectAtIndex:indexPath.row];
        NSLog(@"즐겨찾기 셀(%d) : %@", indexPath.row, [cellInfo description]);
        
        //        cell.textLabel.text = cellInfo[@"name"];
        cell.cellInfo = cellInfo;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"선택한 셀 => (%i / %i)", indexPath.row, indexPath.section);
    
    //    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    
    /* 연락처 상세 보기 */
//    [self showContact];
    
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.contacts = _contacts;
//    [detailViewController.contacts setArray:_contacts];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
