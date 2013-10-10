//
//  StaffAddressViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "StaffAddressViewController.h"
#import "DetailViewController.h"
#import "UIViewController+LoadingProgress.h"
#import "NSString+MD5.h"
#import "AddressCell.h"
#import "Staff.h"


@interface StaffAddressViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *staffTableView;  // 교직원 테이블
@property (strong, nonatomic) NSMutableArray *staffs;       // 교직원 목록

@end

@implementation StaffAddressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = LocalizedString(@"faculty_member_text", @"교직원");
        
        _staffs = [[NSMutableArray alloc] init];

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
    
    // 교직원 화면 구성
    [self setupStaffUI];
    
    // 교지원 db 가져오기
    [_staffs setArray:[self loadDBStaffs]];
    
    [_staffTableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 교직원 목록 화면 구성
- (void)setupStaffUI
{
    CGRect viewRect = self.view.bounds;
    
    if (IS_LESS_THEN_IOS7) {
        viewRect.size.height -= 44.0f;
    }

    _staffTableView = [[UITableView alloc] initWithFrame:viewRect];
    _staffTableView.dataSource = self;
    _staffTableView.delegate = self;
    
    [self.view addSubview:_staffTableView];
    
    if (!IS_LESS_THEN_IOS7) {
        UIEdgeInsets edges;
        edges.left = 0;
        _staffTableView.separatorInset = edges;
    }
}


#pragma mark - DB methods

/// 교직원 목록 db에서 가져오기
- (NSArray *)loadDBStaffs
{
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Staff" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setResultType:NSDictionaryResultType];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
//    if (fetchedObjects && [fetchedObjects count] > 0) {
        return fetchedObjects;
//    }
//    return nil;
}


#pragma mark - UITableView DataSources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([_staffs count] > 0)? [_staffs count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([_staffs count] > 0)? kAddressCellH : self.view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_staffs count] == 0)
    {
        static NSString *identifier = @"NoStaffCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"StaffCell";
    AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[AddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([_staffs count] > 0)
    {
//        Staff *staff = _staffs[indexPath.row];
//        NSDictionary *info = @{@"photourl":staff.photourl, @"name":staff.name, @"email":staff.email};
        NSDictionary *info = _staffs[indexPath.row];
        NSLog(@"교직원 : %@", info);
    
        [cell setCellInfo:info];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"선택한 셀 => (%i / %i)", indexPath.row, indexPath.section);
    
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    
    DetailViewController *viewController = [[DetailViewController alloc] initWithType:MemberTypeStaff];
    viewController.currentIdx = indexPath.row;
    viewController.contacts = [_staffs mutableCopy];
    
    [self.navigationController pushViewController:viewController animated:YES];

}

@end
