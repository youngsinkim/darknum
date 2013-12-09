//
//  FacultyMajorViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FacultyMajorViewController.h"
#import "MajorCell.h"
#import "Major.h"
#import "AllFacultyAddressViewController.h"
#import "FacultyAddressViewController.h"
#import "NSString+MD5.h"
#import "UIViewController+LoadingProgress.h"

@interface FacultyMajorViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *majorTableView;  // 전공 테이블
@property (strong, nonatomic) NSMutableArray *majors;       // 전공 목록
@end


@implementation FacultyMajorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = LocalizedString(@"faculty_text", @"교수진");
        _majors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // CoreData 컨텍스트 지정
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (self.managedObjectContext == nil) {
        self.managedObjectContext = [appDelegate managedObjectContext];
        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
    }

    
    // 교수진 전공 화면 구성
    [self setupMajorUI];

#if (0)
    // 교수진 전공 목록 서버에서 가져오기
    [self requestAPIMajors];
#else
    // 교수진 목록은 초기에 즐겨찾기 업데이트를 통해 모두 가져오므로 전공 목록은 DB에서 가져오면 됨.
    [_majors setArray:[self loadDBMajors]];
#endif
    [_majorTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 교수 전공 목록 화면 구성
- (void)setupMajorUI
{
    CGRect viewRect = self.view.frame;
        
    _majorTableView = [[UITableView alloc] initWithFrame:viewRect];
//    _majorTableView.backgroundColor = [UIColor greenColor];
    _majorTableView.dataSource = self;
    _majorTableView.delegate = self;
    
    [self.view addSubview:_majorTableView];
    
    if (!IS_LESS_THEN_IOS7) {
        UIEdgeInsets edges;
        edges.left = 0;
        _majorTableView.separatorInset = edges;
    }
}


#pragma mark - DB methods

/// 교수진 전공 목록 db에서 가져오기
- (NSArray *)loadDBMajors
{
    NSError *error = nil;
    
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Major" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setResultType:NSDictionaryResultType];

//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(major.major == %@)", majorValue];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title != ''"];
//    [fetchRequest setPredicate:predicate];
//
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];

    NSPredicate *predicate;
    NSSortDescriptor *sortDescriptor;
    if ([[UserContext shared].language isEqualToString:kLMKorean]) {
        [NSPredicate predicateWithFormat:@"title != ''"];
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    } else {
        [NSPredicate predicateWithFormat:@"title_en != ''"];
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title_en" ascending:YES];
    }
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];

    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
//    if (fetchedObjects && [fetchedObjects count] > 0)
//    {
        return fetchedObjects;
//    }
//    return nil;
}


#pragma mark - UITableView DataSources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return ([_majors count] > 0)? [_majors count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([_majors count] > 0)? kMajorCellH : self.view.frame.size.height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [cell setBackgroundColor:UIColorFromRGB(0xffffff)];
    } else {
        if (indexPath.row % 2) {
            [cell setBackgroundColor:UIColorFromRGB(0xffffff)];
        } else {
            [cell setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
        }
    }
    
    // selected cell background color
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = UIColorFromRGB(0xcfd4e4);
    
    [cell setSelectedBackgroundView:bgColorView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *identifier = @"AllMajorCell";
        MajorCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

        if (!cell) {
            cell = [[MajorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            tableView.separatorColor = UIColorFromRGB(0xcccccc);
        }

//        NSDictionary *majorInfo = _majors[indexPath.row];
//        if ([[UserContext shared].language isEqualToString:kLMKorean]) {
//            cell.textLabel.text = majorInfo[@"title"];
//        } else {
//            cell.textLabel.text = majorInfo[@"title_en"];
//        }
//        cell.textLabel.text = LocalizedString(@"All faculties", @"전체 교수");
        cell.majorText = LocalizedString(@"All faculties", @"전체 교수");
        
        return cell;
    }
    else
    {
        if ([_majors count] == 0)
        {
            static NSString *identifier = @"NoMajorCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            
            return cell;
        }
        
        static NSString *identifier = @"MajorCell";
        MajorCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[MajorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    //        cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
        if ([_majors count] > 0)
        {
            NSDictionary *majorInfo = _majors[indexPath.row];

            if ([[UserContext shared].language isEqualToString:kLMKorean]) {
                cell.majorText = majorInfo[@"title"];
            } else {
                cell.majorText = majorInfo[@"title_en"];
            }
        }
        
        return cell;
        
    } // section

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"선택한 셀 => (%i / %i)", indexPath.row, indexPath.section);
    
    if (indexPath.section == 0)
    {
        AllFacultyAddressViewController *viewController = [[AllFacultyAddressViewController alloc] init];
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else
    {
        NSDictionary *majorInfo = [_majors[indexPath.row] mutableCopy];
        if ([majorInfo isKindOfClass:[NSDictionary class]])
        {
            NSLog(@"선택된 셀 정보 : %@", majorInfo);
            
            // 전공에 해당하는 교수 목록 화면으로, (type = faculty, dict = 전공 정보)
            
            FacultyAddressViewController *viewController = [[FacultyAddressViewController alloc] initWithInfo:majorInfo];
    //        AddressViewController *viewController = [[AddressViewController alloc] initWithType:MemberTypeFaculty info:majorInfo];
            if ([[UserContext shared].language isEqualToString:kLMKorean]) {
                viewController.navigationItem.title = majorInfo[@"title"];
            } else {
                viewController.navigationItem.title = majorInfo[@"title_en"];
            }
        
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

#pragma mark - Network API

/// 과정별 기수 목록 가져오기
- (void)requestAPIMajors
{
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }

    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};
    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
    
    // 과정별 기수 목록
    [[SMNetworkClient sharedClient] postMajors:param
                                         block:^(NSArray *result, NSError *error) {
                                             
                                              [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
        
                                              if (error)
                                              {
                                                  [[SMNetworkClient sharedClient] showNetworkError:error];
                                              }
                                              else
                                              {
                                                  // 전공 목록은 db 저장 없이 tableview만 업데이트
//                                                  NSArray *majorList = [result mutableCopy];
//                                                  [_majors setArray:majorList];
                                                  [_majors setArray:result];
                                                  NSLog(@"전공 목록 (%d) : %@", [_majors count], _majors);
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
//                                                      [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
                                                      [self.majorTableView reloadData];
                                                  });
                                                  
                                              }
                                          }];
}

@end
