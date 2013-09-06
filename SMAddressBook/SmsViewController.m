//
//  SmsViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "SmsViewController.h"

@interface SmsViewController ()

@property (strong, nonatomic) UISearchBar *searchBar;
@end

@implementation SmsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 44.0f)];
    _searchBar.tintColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    _searchBar.delegate = self;
    _searchBar.barStyle = UIBarStyleBlackTranslucent;
    
//    _searchBar.prompt = @"타이틀";
    _searchBar.placeholder = @"검색어를 입력해주세용";
    _searchBar.keyboardType = UIKeyboardTypeAlphabet;

    [self.view addSubview:_searchBar];
    
    
    _searchDisplay = [[UISearchDisplayController alloc]
                               initWithSearchBar:_searchBar contentsController:self];
    _searchDisplay.delegate = self;
    _searchDisplay.searchResultsDataSource = self;
    _searchDisplay.searchResultsDelegate = self;
}

#pragma mark - 
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

#pragma mark -
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
