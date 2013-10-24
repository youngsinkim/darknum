//
//  AllFacultyAddressViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 10. 24..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "AllFacultyAddressViewController.h"
#import "DetailViewController.h"
#import "AddressCell.h"
#import "Faculty.h"

@interface AllFacultyAddressViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *addressTableView;    //< 주소록 테이블 뷰
@property (strong, nonatomic) NSMutableArray *faculties;        //< 주소록 목록

@end

@implementation AllFacultyAddressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _faculties = [[NSMutableArray alloc] init];
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
    [_faculties setArray:[DBMethod loadDBAllFaculties]];
    
    [_addressTableView reloadData];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.menuContainerViewController.panMode = MFSideMenuPanModeDefault;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 주소록 화면 구성
- (void)setupAddressUI
{
    CGRect viewRect = self.view.bounds;
    
    if (IS_LESS_THEN_IOS7) {
        viewRect.size.height -= 44.0f;
    }
    
    _addressTableView = [[UITableView alloc] initWithFrame:viewRect];
    _addressTableView.dataSource = self;
    _addressTableView.delegate = self;
    
    [self.view addSubview:_addressTableView];

    
    if (!IS_LESS_THEN_IOS7)
    {
        UIEdgeInsets edges;
        edges.left = 0;
        _addressTableView.separatorInset = edges;
    }
}


#pragma mark - DB methods


#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([_faculties count] > 0)? [_faculties count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = kAddressCellH;
    
    return ([_faculties count] > 0)? cellHeight : self.view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_faculties count] == 0)
    {
        static NSString *identifier = @"NoFacultyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"FacultyCell";
    AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[AddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([_faculties count] > 0)
    {
        NSDictionary *info = _faculties[indexPath.row];
        NSLog(@"교수 : %@", info);
        
        cell.memType = MemberTypeFaculty;
        
        [cell setCellInfo:info];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    
    DetailViewController *viewController = [[DetailViewController alloc] initWithType:MemberTypeFaculty];
    viewController.currentIdx = indexPath.row;
    viewController.contacts = [_faculties mutableCopy];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
