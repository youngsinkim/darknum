//
//  SmsViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "SmsViewController.h"
#import "Student.h"

@interface SmsViewController ()

@property (strong, nonatomic) UITableView *smsTableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchDisplay;

@end

@implementation SmsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _members = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithInfo:(NSMutableArray *)items
{
    self = [super init];
    if (self) {
        
        _members = [[NSMutableArray alloc] initWithArray:items];
        NSLog(@"학생 정보 : %@", _members);
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self smsUI];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(100, 300, 100, 30);
    [btn addTarget:self action:@selector(onClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)smsUI
{
    CGRect rect = CGRectMake(0.0f, 44.0f, 320.0f, self.view.bounds.size.height - 44.0f - 44.0f);
    _smsTableView = [[UITableView alloc] initWithFrame:rect];
    _smsTableView.dataSource = self;
    _smsTableView.delegate = self;
    
    [self.view addSubview:_smsTableView];

    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 44.0f)];
    _searchBar.tintColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    _searchBar.delegate = self;
    _searchBar.barStyle = UIBarStyleBlackTranslucent;
    
//    _searchBar.prompt = @"타이틀";
    _searchBar.placeholder = @"대상자를 선택해주세요.";
    _searchBar.keyboardType = UIKeyboardTypeAlphabet;

    [self.view addSubview:_searchBar];
    
    
    _searchDisplay = [[UISearchDisplayController alloc]
                               initWithSearchBar:_searchBar contentsController:self];
    _searchDisplay.delegate = self;
    _searchDisplay.searchResultsDataSource = self;
    _searchDisplay.searchResultsDelegate = self;
}

- (void)setMembers:(NSMutableArray *)members
{
    [_members setArray:members];
    
    [_smsTableView reloadData];
}


#pragma mark - UITableView DataSources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([_members count] > 0)? [_members count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([_members count] > 0)? 40.0f : self.view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_members count] == 0)
    {
        static NSString *identifier = @"NoSmsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"SmsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        //        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([_members count] > 0)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if (![_members[indexPath.row] isKindOfClass:[NSDictionary class]]) {
            Student *student = _members[indexPath.row];
         
            // ( NSDictionary <- NSManagedObject )
            NSArray *keys = [[[student entity] attributesByName] allKeys];
            [dict setDictionary:[student dictionaryWithValuesForKeys:keys]];

        } else {
            dict = _members[indexPath.row];
        }
//        Staff *staff = _staffs[indexPath.row];
//        NSDictionary *info = @{@"photourl":staff.photourl, @"name":staff.name, @"email":staff.email};
//        
//        [cell setCellInfo:info];
    
        cell.textLabel.text = dict[@"name"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"선택한 셀 => (%i / %i)", indexPath.row, indexPath.section);
    
//    Staff *staff = _staffs[indexPath.row];
//    if (staff)
//        {
//        DetailViewController *detailViewController = [[DetailViewController alloc] init];
//        detailViewController.contacts = _staffs;
//        //    [detailViewController.contacts setArray:_contacts];
//        
//        [self.navigationController pushViewController:detailViewController animated:YES];
//        }
}


#pragma mark - UISearchBar delegate

/// 검색바의 텍스트 영역 클릭 시 
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidBeginEditing");
    [_searchBar setShowsCancelButton:YES];
//    [sBar setCloseButtonTitle:@"Done" forState:UIControlStateNormal];
}

/// 검색바의 cancel 버튼 노출된 상태에서 cancel 버튼 선택 시
-(void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    NSLog(@"searchBarCancelButtonClicked");
}

/// 키보드 표시된 상태에서 search버튼 선택 시
-(void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    NSLog(@"searchBarSearchButtonClicked");
}

/// 입력창에 값이 변경될 때 마다 호출됨
-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText
{
    NSLog(@"textDidChange");

}


#pragma mark - UISearchDisplayController

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    NSLog(@"searchDisplayControllerWillBeginSearch");

    [_searchBar setShowsCancelButton:YES animated:YES];
    for (UIView *subView in _searchBar.subviews){
        if ([subView isKindOfClass:UIButton.class]){
            [(UIButton*)subView setTitle:@"취소" forState:UIControlStateNormal];
        }
    }
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"shouldReloadTableForSearchString");

    for (UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setText:@"결과 없음"];
        }
    }
    
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSLog(@"shouldReloadTableForSearchScope");

    return YES;
}

#pragma mark - 

///
- (void)onClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
