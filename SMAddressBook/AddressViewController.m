//
//  AddressViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "AddressViewController.h"
#import "AppDelegate.h"
#import "AddressCell.h"
#import "StudentAddressCell.h"
#import "DetailViewController.h"    // imsi
#import "Faculty.h"
#import "Staff.h"
#import "Student.h"

@interface AddressViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *addressTableView;    //< 주소록 테이블 뷰
@property (strong, nonatomic) NSMutableArray *addresses;        //< 주소록 목록
@property (strong, nonatomic) NSDictionary *info;        //< 셀 구성을 위한 정보
@property (assign) MemberType memType;      //< 멤버 타입(에 따라 셀 종류를 변경하기 위해서 관리)

@end

@implementation AddressViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (id)initWithType:(MemberType)memType info:(NSDictionary *)info
{
    self = [super init];
    if (self)
    {
        _addresses = [[NSMutableArray alloc] init];
        
        _memType = memType;
        _info = [[NSDictionary alloc] initWithDictionary:info];
        NSLog(@"info 정보 : %@", _info);
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

    // 주소록 화면 구성
    [self setupAddressUI];
    
    // db에서 멤버 타입에 따른 주소록 목록 가져오기
    [_addresses setArray:[self loadDBAddress:_memType]];
    
    [_addressTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 주소록 화면 구성
- (void)setupAddressUI
{
    _addressTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _addressTableView.dataSource = self;
    _addressTableView.delegate = self;
//    _addressTableView = UITableViewCellSeparatorStyleNone;
    _addressTableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    
    [self.view addSubview:_addressTableView];

}

#pragma mark - DB methods

/// 멤머 타입별 목록 db에서 가져오기
- (NSArray *)loadDBAddress:(MemberType)type
{
    NSError *error = nil;
    
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = nil;
    NSPredicate *predicate = nil;
    
    switch (type)
    {
        case MemberTypeFaculty: // 교수는 해당 전공(major) 목록 가져오기
            {
                NSLog(@"info 정보 : %@", _info);
                NSString *majorValue = _info[@"major"];
                NSLog(@"교수 검색 전공 : %@", majorValue);
                entity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:self.managedObjectContext];
                predicate = [NSPredicate predicateWithFormat:@"(major.major == %@)", majorValue];
            }
            break;
            
        case MemberTypeStaff:   // 교직원은 전체 목록 가져오기
//            predicate = [NSPredicate predicateWithFormat:@"(course == 'GMBA')"];
            break;
            
        case MemberTypeStudent: // 학생은 해당 기수(courseclasse) 목록 가져오기
            {
                NSString *class = _info[@"courseclass"];
                NSLog(@"학생 검색 기수 : %@", class);
                predicate = [NSPredicate predicateWithFormat:@"(courseclass == %@)", class];
            }
            break;
            
        default:
            break;
    }
    
    if (entity == nil) {
        return nil;
    }
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
        return fetchedObjects;
    }
    return nil;
}


#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([_addresses count] > 0)? [_addresses count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = kAddressCellH;
    
    if (_memType == MemberTypeStudent) {
        cellHeight = kStudAddressCellH;
    }
    
    return ([_addresses count] > 0)? cellHeight : self.view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_addresses count] == 0)
    {
        static NSString *identifier = @"NoAddressCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"AddressCell";
    UITableViewCell *cell;

    if (_memType == MemberTypeStudent)
    {
        cell = (StudentAddressCell *)[self.addressTableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = (StudentAddressCell *)[[AddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        if ([_addresses count] > 0)
        {
            Student *student = _addresses[indexPath.row];
            NSString *desc = [NSString stringWithFormat:@"[%@] %@ | %@", student.status, student.company, student.department];
            NSDictionary *info = @{@"photourl":student.photourl, @"name":student.name, @"desc":desc, @"mobile":student.mobile, @"email":student.email};
            [(AddressCell *)cell setCellInfo:info];
        }
    }
    else
    {
        cell = (AddressCell *)[self.addressTableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = (AddressCell *)[[AddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        if ([_addresses count] > 0)
        {
            if (_memType == MemberTypeFaculty)
            {
                Faculty *faculty = _addresses[indexPath.row];
                NSDictionary *info = @{@"photourl":faculty.photourl, @"name":faculty.name, @"email":faculty.email};
                [(AddressCell *)cell setCellInfo:info];
            }
            else
            {
                Staff *staff = _addresses[indexPath.row];
                NSDictionary *info = @{@"photourl":staff.photourl, @"name":staff.name, @"email":staff.email};
                [(AddressCell *)cell setCellInfo:info];
            }
        }
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
    
    //    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    
    // 세로형 뷰로 넘어갈 때 타입도 넘겨야 함. 
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.contacts = _addresses;
    //    [detailViewController.contacts setArray:_contacts];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
