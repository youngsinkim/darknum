//
//  ToolViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "ToolViewController.h"
#import "ToolViewCell.h"
#import "Student.h"
#import <QuartzCore/QuartzCore.h>

#define kSearchBarH     44.0f
#define kTableHeaderH   30.0f
#define MAX_LENGTH      10

@interface ToolViewController ()

@property (strong, nonatomic) UISearchDisplayController *searchDisplay;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *memberTableView;
@property (strong, nonatomic) UIButton *allSelectedBtn;
@property (strong, nonatomic) NSMutableArray *members;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableArray *selectArray;
@property (assign) ToolViewType viewType;
@property (assign) BOOL isSearching;

@end

@implementation ToolViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        _members = [[NSMutableArray alloc] init];
//        _selectArray = [[NSMutableArray alloc] init];
//        _searchResults = [[NSMutableArray alloc] init];
    }
    return self;
}


- (id)initWithInfo:(NSMutableArray *)items viewType:(ToolViewType)type
{
    self = [super init];
    if (self)
    {
        _members = [[NSMutableArray alloc] initWithArray:items];
        _selectArray = [[NSMutableArray alloc] init];
        _searchResults = [[NSMutableArray alloc] init];
        _viewType = type;
        _isSearching = NO;
        NSLog(@"학생 정보 : %@", _members);
        
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onClose)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onSend)];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    [self setupToolUI];
    
    [_searchBar becomeFirstResponder];
//    [_searchBar resignFirstResponder];
    [_searchResults setArray:_members];
    [_memberTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupToolUI
{
    CGRect rect = self.view.bounds; // CGRectMake(0.0f, 40.0f, 320.0f, self.view.bounds.size);
    rect.size.height -= (kSearchBarH + 44.0f);
    CGFloat yOffset = 0.0f;
    
    if (IS_LESS_THEN_IOS7) {
//        rect.size.height -= 44.0f;
    } else {
        rect.size.height -= 20.f;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // 검색 바
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, yOffset, 320.0f, kSearchBarH)];
//    _searchBar.tintColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    _searchBar.delegate = self;
//    _searchBar.barStyle = UIBarStyleBlackTranslucent;
    _searchBar.placeholder = @"대상자를 선택해주세요.";
//    _searchBar.keyboardType = UIKeyboardTypeDefault;
//    _searchBar.showsCancelButton = YES;
//    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
//    _searchBar.selectedScopeButtonIndex = 0;
//    _searchBar.searchBarStyle = UISearchBarStyleDefault;
//    _searchBar.searchBarStyle = UISearchBarIconBookmark;
//    _searchBar.clipsToBounds = YES;
    
    [self.view addSubview:_searchBar];
    yOffset += kSearchBarH;
    
    
    _searchDisplay = [[UISearchDisplayController alloc]
                      initWithSearchBar:_searchBar contentsController:self];
    _searchDisplay.delegate = self;
    _searchDisplay.searchResultsDataSource = self;
    _searchDisplay.searchResultsDelegate = self;
    
    
    // 수신자 목록 테이블 뷰
    _memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, yOffset, rect.size.width, rect.size.height)];
    _memberTableView.dataSource = self;
    _memberTableView.delegate = self;
    
    [self.view addSubview:_memberTableView];
    
    if (!IS_LESS_THEN_IOS7) {
        UIEdgeInsets edges;
        edges.left = 0;
        _memberTableView.separatorInset = edges;
    }

    // 툴바
/*
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, yOffset, rect.size.width, kTableHeaderH)];
    headerView.backgroundColor = [UIColor yellowColor];
    [headerView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3f].CGColor];
    [headerView.layer setBorderWidth:1.0f];

    _memberTableView.tableHeaderView = headerView;

    
    _allSelectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _allSelectedBtn.frame = CGRectMake(20.0f, yOffset, 110.0f, 30.0f);
    [_allSelectedBtn setTitle:LocalizedString(@"전체 선택", @"전체 선택") forState:UIControlStateNormal];
    [_allSelectedBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _allSelectedBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _allSelectedBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_allSelectedBtn setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    [_allSelectedBtn setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateSelected];
    [_allSelectedBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_allSelectedBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [_allSelectedBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [_allSelectedBtn addTarget:self action:@selector(onAllSelectedBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:_allSelectedBtn];
    
//    [headerView bringSubviewToFront:_allSelectedBtn];
*/
    
}

- (void)onClose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSend
{
    NSLog(@"보내기");
    
    if (_viewType == ToolViewTypeSms) {
        [self sendSms];
    } else if (_viewType == ToolViewTypeEmail) {
        [self sendEmail];
    }
}

- (void)sendSms
{
    if (![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }

//    NSString *recipients = [NSString stringWithFormat:@""];
//    NSInteger index = 0;
//    
//    for (NSDictionary *info in _selectArray) {
//        recipients = [recipients stringByAppendingString:info[@"mobile"]];
//        index++;
//        
//        if (index < [_selectArray count]) {
//            recipients = [recipients stringByAppendingString:@","];
//        }
//    }

//    NSLog(@"SMS 발송 : %@", recipients);
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:recipients]];
    

    MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
    messageComposer.messageComposeDelegate = self;
    messageComposer.recipients = _selectArray;
    NSString *message = @"";
    [messageComposer setBody:message];
    [self presentViewController:messageComposer animated:YES completion:nil];
    
}

- (void)sendEmail
{
    NSString *recipients = [NSString stringWithFormat:@"mailto://"];
    NSInteger index = 0;
    
    for (NSDictionary *info in _selectArray) {
        recipients = [recipients stringByAppendingString:info[@"email"]];
        index++;
        
        if (index < [_selectArray count]) {
            recipients = [recipients stringByAppendingString:@","];
        }
    }
    
    NSLog(@"이메일 발송 : %@", recipients);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:recipients]];
}

// 전체 선택 버튼
- (void)onAllSelectedBtnClicked:(UIButton *)sender
{
    UIButton *btnSection = sender;
    
    if(btnSection.tag == 0)
    {
//        NSLog(@"버튼 값 : %d", sender.selected);
//        sender.selected = !sender.selected;
        [sender setSelected:![sender isSelected]];
        BOOL isAllSelected = sender.selected;
        NSLog(@"전체 선택 : %d", isAllSelected);

        if (isAllSelected == YES) {
            [_selectArray setArray:_members];
        } else {
            [_selectArray removeAllObjects];
        }
    }
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    dispatch_async(dispatch_get_main_queue(), ^{
//    [self performSelector:@selector(updateTablewView) withObject:nil];
        [self.memberTableView reloadData];
//    });
}

- (void)updateTablewView
{
    [_memberTableView reloadData];
}

//- (void)onCheckTouched:(id)sender
//{
//    NSLog(@"체크박스 선택");
//    
//    if ([sender isKindOfClass:[ToolViewCell class]])
//    {
//        ToolViewCell *cell =  (ToolViewCell *)sender;
//        NSIndexPath *indexPath = [_memberTableView indexPathForCell:cell];
//        
//        NSMutableArray *array = [[NSMutableArray alloc] init];
//        if (_bSearchMode) {
//            [array setArray:_searchResults];
//        } else {
//            [array setArray:_members];
//        }
////        NSArray *list = _memberTableView[indexPath.section];
//        NSLog(@"section(%d), row(%d)", indexPath.section, indexPath.row);
//        
//        // 셀 정보
//        NSDictionary *info = [array objectAtIndex:indexPath.row];
//        NSLog(@"selected Data : %@", info);
//        
//        if ([_selectArray containsObject:[array objectAtIndex:indexPath.row]]) {
//            [_selectArray removeObject:[array objectAtIndex:indexPath.row]];
//        }
//        else {
//            [_selectArray addObject:[array objectAtIndex:indexPath.row]];
//        }
//        NSLog(@"선택 항목 : %@", _selectArray);
////        [_memberTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationFade];
//
//    }
//    [_memberTableView reloadData];
//}

#pragma mark - UISearchBar delegate
/*
/// 검색바의 텍스트 영역 클릭 시
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidBeginEditing");
    _isSearching = YES;
    [searchBar setShowsCancelButton:YES animated:YES];
//    _memberTableView.allowsSelection = NO;
//    _memberTableView.scrollEnabled = NO;
    
//    [_searchResults removeAllObjects];
//    [_searchResults addObjectsFromArray:_members];
}

/// 검색바의 cancel 버튼 노출된 상태에서 cancel 버튼 선택 시
-(void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    NSLog(@"searchBarCancelButtonClicked");
    _searchBar.text = @"";
    
//    [_searchBar setShowsCancelButton:NO animated:YES];
//    [_searchBar resignFirstResponder];
//    
//    _memberTableView.allowsSelection = YES;
//    _memberTableView.scrollEnabled = YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarShouldEndEditingr");
    _bSearchMode = NO;
    [_memberTableView reloadData];
    return YES;
}

/// 키보드 표시된 상태에서 search버튼 선택 시
-(void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    NSLog(@"searchBarSearchButtonClicked");

//    NSArray *results = [SomeService doSearch:_searchBar.text];
//	
//    [_searchBar setShowsCancelButton:NO animated:YES];
//    [_searchBar resignFirstResponder];
//    
//    _memberTableView.allowsSelection = YES;
//    _memberTableView.scrollEnabled = YES;
//	
//    [_searchResults removeAllObjects];
//    [_searchResults addObjectsFromArray:results];
//    [_memberTableView reloadData];
    
//    int len = [ [_searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
//    
//    if (len > 2)
//    {
//        [self searchTableView];
//    }
//    else
//    {
//        [_searchBar resignFirstResponder];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                        message:@"Search term needs to be at least 3 characters in length."
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//        
//    }
}

- (void) searchTableView
{
    NSString *searchText = _searchBar.text;
    
    if ([searchText length] > 0)
    {
        // do the actual search....
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidEndEditing");
    [_searchBar setShowsCancelButton:NO animated:YES];
}

/// 입력창에 값이 변경될 때 마다 호출됨
#define MAX_LENGTH  10
-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText
{
    NSLog(@"textDidChange");
    
    
    if ([searchText length] > 0) {
        
        if ([searchText length] > MAX_LENGTH) {
            searchText = [searchText substringToIndex:MAX_LENGTH];
            searchBar.text = searchText;
        }
        
        NSString *firststr = [searchText substringToIndex:1];
        
        [_searchResults removeAllObjects]; // First clear the filtered array.

        for (NSDictionary *dict in _members)
        {
            NSLog(@"찾기(%@ == %@)", dict[@"name"], searchText);
//            NSComparisonResult result = [dict[@"name"] compare:searchText options:0 range:NSMakeRange(0, [searchText length])];
            NSRange rSearch = [dict[@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
//            if (result == NSOrderedSame)
            if (rSearch.location != NSNotFound)
            {
                [_searchResults addObject:dict];
                NSLog(@"찾기 : %@", _searchResults);
            }
        }
    }
    else {
        _searchResults = [_members mutableCopy];
    }
    
    [_memberTableView reloadData];
    
//    [_memberTableView reloadData];
//    [_searchResults removeAllObjects];    // clear the filtered array first
//    
//    // search the table content for cell titles that match "searchText"
//    // if found add to the mutable array and force the table to reload
//    //
//    NSString *cellTitle;
//    for (NSDictionary *dict in _members)
//    {
//        cellTitle = dict[@"name"];
//
//        NSComparisonResult result = [cellTitle compare:searchText options:NSCaseInsensitiveSearch
//                                                 range:NSMakeRange(0, [searchText length])];
//        if (result == NSOrderedSame)
//        {
//            [_searchResults addObject:cellTitle];
//        }
//    }
//    [self reloadDataMyTable];
}
*/

#pragma mark - UISearchDisplayControllerDelegate
/// 검색모드 시작
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    NSLog(@"검색 display 시작.");
    _isSearching = YES;
    
//    _searchBar.showsCancelButton = YES;
//    //Iterate the searchbar sub views
//    for (UIView *subView in _searchBar.subviews) {
//        //Find the button
//        if([subView isKindOfClass:[UIButton class]])
//        {
//            //Change its properties
//            UIButton *cancelButton = (UIButton *)[_searchBar.subviews lastObject];
//            cancelButton.titleLabel.text = @"Changed";
//            cancelButton.titleLabel.textColor = [UIColor blueColor];
//        }
//    }
    
    // Search for Cancel button in searchbar, enable it and add key-value observer.
//    for (id subview in [self.searchBar subviews]) {
//        if ([subview isKindOfClass:[UIButton class]]) {
//            [subview setEnabled:YES];
//            [subview addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
//        }
//    }
//    return;
    
    [_searchBar setShowsCancelButton:YES animated:YES];
//    for (UIView *subView in controller.searchBar.subviews){
//        if ([subView isKindOfClass:UIButton.class]){
//            [(UIButton*)subView setTitle:@"취소1" forState:UIControlStateNormal];
//        }
//    }
    
    [self enableCancelButton:_searchBar];
}

- (void)enableCancelButton:(UISearchBar *)searchBar
{
    for (UIView *view in searchBar.subviews)
    {
        for (id subview in view.subviews)
        {
            if ( [subview isKindOfClass:[UIButton class]] )
            {
                [subview setEnabled:YES];
                NSLog(@"enableCancelButton");
                return;
            }
        }
    }
}

/// 검색모드 종료
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    NSLog(@"검색 display 종료");
    _isSearching = NO;
    [_searchBar setShowsCancelButton:NO animated:YES];

    [_memberTableView reloadData];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    
//    [_searchResults removeAllObjects];
    [_searchResults setArray:[_members filteredArrayUsingPredicate:resultPredicate]];
    NSLog(@"검색 결과: %@", _searchResults);
}

- (void)filterListForSearchText:(NSString *)searchText
{
    
    if ([searchText length] > 0) {
        
        if ([searchText length] > MAX_LENGTH) {
            searchText = [searchText substringToIndex:MAX_LENGTH];
            _searchDisplay.searchBar.text = searchText;
        }
        
        [_searchResults removeAllObjects]; // First clear the filtered array.
        
        for (NSDictionary *dict in _members)
        {
//            NSLog(@"찾기(%@ == %@)", dict[@"name"], searchText);
            //            NSComparisonResult result = [dict[@"name"] compare:searchText options:0 range:NSMakeRange(0, [searchText length])];
            NSRange rSearch = [dict[@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            //            if (result == NSOrderedSame)
            if (rSearch.location != NSNotFound)
            {
                [_searchResults addObject:dict];
//                NSLog(@"찾기 : %@", _searchResults);
            }
        }
    }
    else {
        _searchResults = [_members mutableCopy];
    }
}

/// 검색 문자열 업데이트
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"검색 문자열 찾기 : %@", searchString);
    [self filterListForSearchText:searchString]; // The method we made in step 7
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
    
//    [self filterContentForSearchText:searchString
//                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
//                                      objectAtIndex:[self.searchDisplayController.searchBar
//                                                     selectedScopeButtonIndex]]];
    
//    NSArray *results = [SomeService doSearch:_searchBar.text];
	
//    [_searchBar setShowsCancelButton:NO animated:YES];
//    [_searchBar resignFirstResponder];
    
//    _memberTableView.allowsSelection = YES;
//    _memberTableView.scrollEnabled = YES;
	
//    [_searchResults removeAllObjects];
//    [_searchResults addObjectsFromArray:results];
//    [_memberTableView reloadData];

    
    return YES;
    
//    for (UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) {
//        if ([subview isKindOfClass:[UILabel class]]) {
//            [(UILabel*)subview setText:@"결과 없음"];
//        }
//    }
//    
//    return NO;
}

/// 검색옵션 업데이트
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterListForSearchText:[_searchDisplay.searchBar text]]; // The method we made in step 7
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


#pragma mark - 

///
- (void)onClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableView DataSources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _searchDisplay.searchResultsTableView)
//    if (_isSearching)
    {
        return ([_searchResults count] > 0)? [_searchResults count] : 1;
    } else {
        return ([_members count] > 0)? [_members count] : 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect tableFrame = tableView.frame;
    UIView *headerView = nil;
    
    if (tableView != _searchDisplay.searchResultsTableView) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableFrame.size.width, kTableHeaderH)];
        headerView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
        [headerView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3f].CGColor];
        [headerView.layer setBorderWidth:1.0f];
        
        
        CGFloat yOffset = 0.0f;

        UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, yOffset, 100, kTableHeaderH)];
        sectionTitleLabel.textColor = [UIColor darkGrayColor];
        sectionTitleLabel.backgroundColor = [UIColor clearColor];
        [sectionTitleLabel setFont:[UIFont systemFontOfSize:14.0f]];
//        [sectionTitleLabel setText:@"메일 수신자 선택"];
        
        if (_viewType == ToolViewTypeSms) {
            sectionTitleLabel.text = NSLocalizedString(@"문자 수신자 선택", nil);
        } else if (_viewType == ToolViewTypeEmail) {
            sectionTitleLabel.text = NSLocalizedString(@"메일 수신자 선택", nil);
        }

        [headerView addSubview:sectionTitleLabel];
        
        if (!_allSelectedBtn)
        {
            _allSelectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _allSelectedBtn.frame = CGRectMake(tableFrame.size.width - 120.0f, yOffset, 100.0f, 30.0f);
            [_allSelectedBtn setTitle:LocalizedString(@"전체 선택", @"전체 선택") forState:UIControlStateNormal];
            [_allSelectedBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            _allSelectedBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            _allSelectedBtn.titleLabel.textAlignment = NSTextAlignmentRight;
            [_allSelectedBtn setImage:[UIImage imageNamed:@"join_agreebox"] forState:UIControlStateNormal];
            [_allSelectedBtn setImage:[UIImage imageNamed:@"join_agreebox_ch"] forState:UIControlStateSelected];
            [_allSelectedBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            [_allSelectedBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 80, 0, 0)];
            [_allSelectedBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 26)];
            [_allSelectedBtn addTarget:self action:@selector(onAllSelectedBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            _allSelectedBtn.tag = section;
            
        }
        [headerView addSubview:_allSelectedBtn];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if ([tableView headerViewForSection:section] != nil)
    if (tableView == _searchDisplay.searchResultsTableView) {
        return 0.0f;
    }
    return kTableHeaderH;
//    CGFloat height = ([tableView headerViewForSection:section] != nil)? kTableHeaderH : 0.0f;
//    NSLog(@"섹션 높이 : %f", height);
//    return height;
//    return ([tableView headerViewForSection:section] != nil)? kTableHeaderH : 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([_members count] > 0)? ToolViewCellH : self.view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger row = indexPath.row;

//    if (_isSearching)
    if (tableView == _searchDisplay.searchResultsTableView)
    {
        [array setArray:_searchResults];
        
//        static NSString *MyIdentifier = @"SearchResult";
//        ToolViewCell *cell = (ToolViewCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
//        
//        if (cell == nil) {
//            cell = [[ToolViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
//        }
//        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCellChecking:)];
//        [cell.checkBtn addGestureRecognizer:tap];
//        
//        NSInteger row = indexPath.row;
//        if ([array count] > 0)
//        {
//            NSDictionary *data = [array objectAtIndex:row];
//            NSLog(@"data : %@", data);
//            
//            //        cell.textLabel.text = data.name;
//            if ([_selectArray containsObject:data]) {
//                [cell.checkBtn setSelected:YES];
//            }
//            else {
//                [cell.checkBtn setSelected:YES];
//            }
//            
//            NSLog(@"cell dict : %@", data);
//            cell.info = [data mutableCopy];
//            
//        }
//        return cell;
    }
    else {
        [array setArray:_members];
    }
    
    if ([array count] == 0)
    {
        NSLog(@"빈 셀");
        static NSString *identifier = @"NoToolViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"ToolViewCell";
    ToolViewCell *cell = (ToolViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        NSLog(@"셀 생성");
        cell = [[ToolViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        //        cell.delegate = self;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCellChecking:)];
        [cell.checkBtn addGestureRecognizer:tap];

    }

    if (array && [array count] > 0 && row < [array count])
    {
        NSLog(@"셀 개수 : %d", [array count]);

//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:array[row]];
        //        if (![array[indexPath.row] isKindOfClass:[NSDictionary class]]) {
        //            Student *student = array[indexPath.row];
        //
        //            // ( NSDictionary <- NSManagedObject )
        //            NSArray *keys = [[[student entity] attributesByName] allKeys];
        //            [dict setDictionary:[student dictionaryWithValuesForKeys:keys]];
        //
        //        } else {
        
//        dict = array[row];
        //        }
        //        Staff *staff = _staffs[indexPath.row];
        //        NSDictionary *info = @{@"photourl":staff.photourl, @"name":staff.name, @"email":staff.email};
        //
        //        [cell setCellInfo:info];
        NSLog(@"cell dict : %@", dict);
        cell.info = [dict mutableCopy];
        
        if ([_selectArray containsObject:dict]) {
            [cell.checkBtn setSelected:YES];
        }
        else {
            [cell.checkBtn setSelected:NO];
        }
        
        //        cell.textLabel.text = dict[@"name"];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"선택한 셀 => (%i / %i)", indexPath.row, indexPath.section);
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    // 각 세션의 헤더가 스크롤시 고정되있는 현상을 수정하기 위해 위치를 재조정하는 코드 추가
//    CGFloat sectionHeaderHeight = kTableHeaderH;// _memberTableView.sectionHeaderHeight;
//    
//    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
//    {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    }
//    else if (scrollView.contentOffset.y >= sectionHeaderHeight)
//    {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
//}

#pragma mark - UITapGestureRecognizer

- (void)handleCellChecking:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint tapLocation = CGPointZero;
    NSIndexPath *tappedIndexPath = nil;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (_isSearching) {
        tapLocation = [tapRecognizer locationInView:_searchDisplay.searchResultsTableView];
        tappedIndexPath = [_searchDisplay.searchResultsTableView indexPathForRowAtPoint:tapLocation];
        
        [array setArray:_searchResults];
    }
    else {
        tapLocation = [tapRecognizer locationInView:_memberTableView];
        tappedIndexPath = [_memberTableView indexPathForRowAtPoint:tapLocation];

        [array setArray:_members];
    }
    
    NSInteger row = tappedIndexPath.row;

    if ([_selectArray containsObject:[array objectAtIndex:row]]) {
        [_selectArray removeObject:[array objectAtIndex:row]];
    }
    else {
        [_selectArray addObject:[array objectAtIndex:row]];
    }
    NSLog(@"선택 항목 : %@", _selectArray);
    
    
    // 선택 항목 수에 따라 [전체 선택] 버튼 상태 변경.
    if (_selectArray.count == _members.count) {
        _allSelectedBtn.selected = YES;
    } else {
        _allSelectedBtn.selected = NO;
    }
    
    
    // 보내기 버튼은 선택된 항목이 있을 때만 활성화 시키기.
    if ([_selectArray count] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    
    if (_isSearching) {
        [_searchDisplay.searchResultsTableView  reloadRowsAtIndexPaths:[NSArray arrayWithObject:tappedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [_searchDisplay.searchResultsTableView reloadData];
    } else {
        [_memberTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:tappedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
//    [_memberTableView reloadData];
}

- (void)onSectionAllCheckTapped:(UITapGestureRecognizer *)tapRecognizer
{
    BOOL isAllSelected = ![_allSelectedBtn isSelected];
    _allSelectedBtn.selected = isAllSelected;
    NSLog(@"전체 선택 : %d", isAllSelected);
    
    if (isAllSelected == YES) {
        [_selectArray setArray:_members];
    } else {
        [_selectArray removeAllObjects];
        _selectArray = nil;
    }
    
    [_memberTableView beginUpdates];
    [_memberTableView endUpdates];
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //    [self performSelector:@selector(updateTablewView) withObject:nil];
//        [_memberTableView reloadData];
    //    });
    
}

#pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:LocalizedString(@"Ok:", @"확인") otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
