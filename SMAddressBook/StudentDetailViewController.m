//
//  StudentDetailViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "StudentDetailViewController.h"
#import "StudentDetailToolView.h"

@interface StudentDetailViewController ()

@property (strong, nonatomic) StudentDetailToolView *footerView;        // 하단 툴바 
@property (strong, nonatomic) MMHorizontalListView *contactListView;    //< 세로 테이블 뷰
@property (strong, nonatomic) NSMutableArray *contacts;                 //< 주소록 목록

@end

@implementation StudentDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithInfo:(NSArray *)items
{
    self = [super init];
    if (self) {

        _contacts = [[NSMutableArray alloc] initWithArray:items];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // 세로 테이블 뷰
    [self setupContactTableView];

    [_contactListView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 주소록 테이블 뷰
- (void)setupContactTableView
{
    CGRect rect = self.view.bounds;
    
    // 세로 테이블 뷰
    _contactListView = [[MMHorizontalListView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, rect.size.height - 44.0f - kStudentDetailToolH)];
    _contactListView.dataSource = self;
    _contactListView.delegate = self;
    _contactListView.cellSpacing = 0;
    _contactListView.pagingEnabled = YES;
    
    _contactListView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
//    _horListView.alpha = 1;
//    _horListView.opaque = YES;
    _contactListView.showsHorizontalScrollIndicator = NO;
    _contactListView.contentSize = CGSizeMake(_contactListView.frame.size.width * _contacts.count, _contactListView.frame.size.height);
    
//    _contactListView.pageControl.currentPage = 0;
//    _contactListView.pageControl.numberOfPages = _contacts.count;
    
//    [UIView roundedLayer:_horContactTableView radius:5.0f shadow:YES];
    
    [self.view addSubview:_contactListView];
    
    
    // 기능 툴바
    _footerView = [[StudentDetailToolView alloc] initWithFrame:CGRectMake(0.0, rect.size.height - 44.0f - kStudentDetailToolH, rect.size.width, kStudentDetailToolH)];
    _footerView.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:_footerView];
}

#pragma mark - UIBarButtonItem Callbacks
///// 네비게이션 [이전] 버튼 선택
//- (void)backButtonClicked:(id)sender
//{
//    self.menuContainerViewController.panMode = MFSideMenuPanModeDefault;
//}


#pragma mark - MMHorizontalListViewDatasource methods

- (NSInteger)MMHorizontalListViewNumberOfCells:(MMHorizontalListView *)horizontalListView
{
    NSInteger count = ([_contacts count] > 0)? [_contacts count] : 1;
    return count;
}

- (CGFloat)MMHorizontalListView:(MMHorizontalListView *)horizontalListView widthForCellAtIndex:(NSInteger)index
{
    return 320;
}

- (MMHorizontalListViewCell*)MMHorizontalListView:(MMHorizontalListView *)horizontalListView cellAtIndex:(NSInteger)index
{
    // dequeue cell for reusability
    MMHorizontalListViewCell *cell = [horizontalListView dequeueCellWithReusableIdentifier:@"StudentDetailCell"];
    
    if (!cell) {
        CGRect rect = self.view.bounds;
        cell = [[MMHorizontalListViewCell alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - 50.0f)];
        cell.reusableIdentifier = @"StudentDetailCell";  // assign the cell identifier for reusability
    }
    
    [cell setBackgroundColor:[UIColor colorWithRed:(arc4random() % 255)/255.0 green:(arc4random() % 255)/255.0 blue:(arc4random() % 255)/255.0 alpha:0.5]];
    
#if (0)
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 300)];
    Faculty *faculty = _contacts[index];
    
    nameLabel.text = faculty.name;
    [cell addSubview:nameLabel];
#endif
    return cell;
}

#pragma mark - MMHorizontalListViewDelegate methods

- (void)MMHorizontalListView:(MMHorizontalListView*)horizontalListView didSelectCellAtIndex:(NSInteger)index
{
    //do something when a cell is selected
    NSLog(@"selected cell %d", index);
}

- (void)MMHorizontalListView:(MMHorizontalListView *)horizontalListView didDeselectCellAtIndex:(NSInteger)index
{
    // do something when a cell is deselected
    NSLog(@"deselected cell %d", index);
}

@end
