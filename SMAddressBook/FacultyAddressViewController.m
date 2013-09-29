//
//  FacultyAddressViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FacultyAddressViewController.h"
#import "DetailViewController.h"
#import "AddressCell.h"
#import "Major.h"
#import "Faculty.h"

@interface FacultyAddressViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *addressTableView;    //< 주소록 테이블 뷰
@property (strong, nonatomic) NSMutableArray *faculties;        //< 주소록 목록
@property (strong, nonatomic) NSDictionary *majorInfo;          //< 셀 구성을 위한 정보

@end

@implementation FacultyAddressViewController

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
    if (self) {
        
//        self.navigationItem.title = LocalizedString(@"faculty_text", @"교수진");

        _majorInfo = [NSDictionary dictionaryWithDictionary:info];
        NSLog(@"교수의 전공 정보 : %@", _majorInfo);

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
    [_faculties setArray:[self loadDBFaculties]];
    
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
    _addressTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _addressTableView.dataSource = self;
    _addressTableView.delegate = self;
    //    _addressTableView = UITableViewCellSeparatorStyleNone;
//    _addressTableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    
    [self.view addSubview:_addressTableView];
    
    if (!IS_LESS_THEN_IOS7) {
        UIEdgeInsets edges;
        edges.left = 0;
        _addressTableView.separatorInset = edges;
    }
}

#pragma mark - DB methods

/// 전공에 해당하는 교수 목록 가져오기
- (NSArray *)loadDBFaculties
{
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setRelationshipKeyPathsForPrefetching:@[@"major"]];
    NSDictionary *properties = [entity propertiesByName];
    NSMutableArray *propertiesToFetch = [NSMutableArray arrayWithArray:[properties allValues]];// arrayWithObject:[properties allValues], @"major.title", nil];
    [propertiesToFetch addObject:@"major.title"];
    [fetchRequest setPropertiesToFetch:[propertiesToFetch mutableCopy]];
//    [fetchRequest setPropertiesToFetch:@[@"major.title", @"email", @"memberidx", @"name", @"mobile", @"name_en", @"office", @"office_en", @"photourl", @"tel", @"viewphotourl"]];
//    [fetchRequest setPropertiesToFetch:@[@"majortitle", @"major.title"]];
    [fetchRequest setReturnsObjectsAsFaults:NO];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(major.major == %@)", _majorInfo[@"major"]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d, %@", [fetchedObjects count], fetchedObjects);

    if ([fetchedObjects count] > 0)
    {
        NSLog(@"(%@)전공 교수 목록 : %@", _majorInfo[@"major"], fetchedObjects[0][@"major.title"]);
        return fetchedObjects;
//        Major *major = fetchedObjects[0];
//        if (major)
//        {
//            NSArray *faculties = [NSArray arrayWithArray:[major.facultys allObjects]];
//            NSLog(@"faculty count : %d, %d", [major.facultys count], [faculties count]);
//            
//            return faculties;
//        }
    }

    return nil;
}



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
//        Faculty *faculty = _faculties[indexPath.row];
//        NSDictionary *info = @{@"photourl":faculty.photourl, @"name":faculty.name, @"email":faculty.email};
        NSDictionary *info = _faculties[indexPath.row];
        NSLog(@"교수 : %@", info);
        
        [cell setCellInfo:info];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"선택한 셀 => (%i / %i)", indexPath.row, indexPath.section);
    
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    
    DetailViewController *viewController = [[DetailViewController alloc] initWithType:MemberTypeFaculty];
    viewController.currentIdx = indexPath.row;
    viewController.contacts = [_faculties mutableCopy];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
