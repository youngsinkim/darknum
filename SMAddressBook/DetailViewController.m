//
//  DetailViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 26..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "DetailViewController.h"
#import "UIView+Shadow.h"
#import "Faculty.h"

@interface DetailViewController ()

@property (strong, nonatomic) UITableView *contactTableView;
@property (strong, nonatomic) MMHorizontalListView *horListView;    //< 세로 주소록 테이블 뷰

@end

@implementation DetailViewController

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
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    // 세로 테이블 뷰
    [self setupContactTableView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 주소록 테이블 뷰
- (void)setupContactTableView
{
    //    _contactTableView = [[ContactTableView alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 200.0f, 200.0f) style:UITableViewStylePlain];
    //    _contactTableView.dataSource = self;
    //    _contactTableView.delegate = self;
    //    _contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //
    //    [parentView addSubview:_contactTableView];
    
    _horListView = [[MMHorizontalListView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 300.0f)];
    _horListView.backgroundColor = [UIColor orangeColor];
//    _horContactTableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    //    _horListView.alpha = 1;
    //    _horListView.opaque = YES;
    _horListView.dataSource = self;
    _horListView.delegate = self;
    _horListView.cellSpacing = 1;
    _horListView.pagingEnabled = YES;
//    _horListView.showsHorizontalScrollIndicator = NO;
    _horListView.contentSize = CGSizeMake(_horListView.frame.size.width * _contacts.count, _horListView.frame.size.height);
    
//    _horListView.pageControl.currentPage = 0;
//    _horListView.pageControl.numberOfPages = _contacts.count;
    
    
//    [UIView roundedLayer:_horContactTableView radius:5.0f shadow:YES];
    
    [self.view addSubview:_horListView];
    
    [self.horListView reloadData];
    
    //    UILabel *label = [[UILabel alloc] init];
    //    label.text = @"Modal View";
    //    label.textColor = [UIColor whiteColor];
    //    label.backgroundColor = [UIColor blackColor];
    //    label.opaque = YES;
    //    [label setFrame:_horListView.frame];
    //    [_horListView addSubview:label];
}

- (void)setContacts:(NSMutableArray *)contacts
{
    _contacts = contacts;
    
    [self.horListView reloadData];
}


#pragma mark - MMHorizontalListViewDatasource methods

- (NSInteger)MMHorizontalListViewNumberOfCells:(MMHorizontalListView *)horizontalListView
{
    NSInteger count = ([_contacts count] > 0)? [_contacts count] : 1;
    return count;
}

- (CGFloat)MMHorizontalListView:(MMHorizontalListView *)horizontalListView widthForCellAtIndex:(NSInteger)index
{
    return 319;
}

- (MMHorizontalListViewCell*)MMHorizontalListView:(MMHorizontalListView *)horizontalListView cellAtIndex:(NSInteger)index
{
    // dequeue cell for reusability
    MMHorizontalListViewCell *cell = [horizontalListView dequeueCellWithReusableIdentifier:@"test"];

    if (!cell) {
        cell = [[MMHorizontalListViewCell alloc] initWithFrame:CGRectMake(0, 0, 319.0f, 300.0f)];
        cell.reusableIdentifier = @"test";  // assign the cell identifier for reusability
    }

    [cell setBackgroundColor:[UIColor colorWithRed:(arc4random() % 255)/255.0 green:(arc4random() % 255)/255.0 blue:(arc4random() % 255)/255.0 alpha:0.5]];
    
#if (1)
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
