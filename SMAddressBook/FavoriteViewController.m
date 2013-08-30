//
//  FavoriteViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 23..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "AppDelegate.h"
#import "FavoriteViewController.h"
#import "FavoriteToolViewController.h"
#import "MenuTableViewController.h"
#import "NSString+MD5.h"
#import "Course.h"
#import "Staff.h"
#import "Faculty.h"
#import "Student.h"
#import "Major.h"
#import "LoginViewController.h"
#import "FavoriteCell.h"


@interface FavoriteViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *favoriteTableView;   // 즐겨찾기 테이블 뷰
@property (strong, nonatomic) NSMutableArray *favorites;        // 즐겨찾기 목록

@end


@implementation FavoriteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = LocalizedString(@"favorite_title", @"즐겨찾기");
        self.favorites = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    // CoreData 컨텍스트 지정
    if (self.managedObjectContext == nil)
    {
        self.managedObjectContext = [appDelegate managedObjectContext];
        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
    }

    
    // 즐겨찾기 화면 구성
    [self setupFavoriteUI];

    
    NSDictionary *loginInfo = (NSDictionary *)[[UserContext shared] loginInfo];
    NSLog(@"LOGIN INFO : %@", loginInfo);

    // 로그인 전이면 화면 구성 중단.
    if ([UserContext shared].isLogined == NO)
    {
        NSLog(@"로그인 전이네요.... -.- -.- -.-");
//        if (!loginInfo[@"certno"])
//    {
//        // MARK: 로그인 되지 않은 상태이면 로그인 화면 노출.
//        UIViewController *loginViewController = [appDelegate loginViewController];
//    
//        [self.navigationController presentViewController:loginViewController animated:NO completion:nil];
//    }
//    else if (![[UserContext shared] isAcceptTerms])
//    {
//        // MARK: 약관 동의를 하지 않았으면 약관동의 화면 노출.
//        UIViewController *termsViewController = [appDelegate termsViewController];
//        
//        [self.navigationController presentViewController:termsViewController animated:NO completion:nil];
//    }
//    else if (![[UserContext shared] isExistProfile])
//        {
        // MARK:
//        }
    }
    else
    {
        // 1. 로그인 후, 로컬 DB에서 즐겨찾기(CourseClass) 목록 가져오기
        [self.favorites setArray:[self loadDBFavoriteCourse]];
        NSLog(@"After Favorites : %@", self.favorites);

        if ([self.favorites count] > 0)
        {
            // 즐겨찾기 목록 테이블 뷰 적용
            [self.favoriteTableView reloadData];
        
            // 즐겨찾기 목록 메뉴 적용
            MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
            [menu setAddrMenuList:self.favorites];
        }

        // 2. update count 값에 따라 서버 API 연동 및 업데이트 받기
        NSDictionary *loginInfo = (NSDictionary *)[[UserContext shared] loginInfo];
        NSLog(@"LOGIN INFO : %@", loginInfo);
        if (loginInfo[@"updatecount"] > 0 || [self.favorites count] == 0)
        {
            // 즐겨찾기 목록이 DB에 없는 경우, 서버로 과정 기수 목록 요청하기  (과정 기수 목록에 즐겨찾기 포함되어 있음)
            // 과정 기수 목록 가져오기
            [self requestAPIClasses];
        }
        // 3. 로컬 DB 저장
        // 4. 메뉴 구성 업데이트
    
    
    
        {
        

        }
        
    }
    
    [_favoriteTableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - View mothods
// 즐겨찾기 화면 구성 
- (void)setupFavoriteUI
{
//    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    CGRect rect = self.view.frame;
    
    // 즐겨찾기 테이블 뷰
    _favoriteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f-100) style:UITableViewStylePlain];
    _favoriteTableView.dataSource = self;
    _favoriteTableView.delegate = self;
    [_favoriteTableView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5]];
    
    [self.view addSubview:_favoriteTableView];
    
    
    // 하단 버튼 툴바
    FavoriteToolViewController *footerToolVC = [[FavoriteToolViewController alloc] init];
//    footerToolVC.view.frame = CGRectMake(0.0f, rect.size.height - 44.0f - kFvToolH, 320.0f, kFvToolH);
    
    [self addChildViewController:footerToolVC];
    [self.view addSubview:footerToolVC.view];
    [footerToolVC didMoveToParentViewController:self];
}


#pragma mark - UITableView DataSources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([_favorites count] > 0)? [_favorites count] : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_favorites count] == 0)
    {
        static NSString *identifier = @"NoFavoriteCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"FavoriteCell";
    FavoriteCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[FavoriteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        tableView.separatorColor = [UIColor lightGrayColor];
    }

    if ([_favorites count] > 0) {
        Course *course = _favorites[indexPath.row];
        cell.textLabel.text = course.title;
    }
    
    return cell;

}

#pragma mark - Network API

- (void)requestAPIClasses
{
//    NSDictionary *param = @{@"scode"=5684825a51beb9d2fa05e4675d91253c&userid=ztest01&certno=m9kebjkakte1tvrqfg90i9fh84};
    NSDictionary *loginInfo = [[[UserContext shared] loginInfo] mutableCopy];
    NSLog(@"LOGIN INFO : %@", loginInfo);
    NSString *mobileNo = @"01023873856";
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
    NSString *certNo = [[NSUserDefaults standardUserDefaults] objectForKey:kUserCertNo];
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};
    
    // 과정별 기수 목록
    [[SMNetworkClient sharedClient] postClasses:param
                                          block:^(NSMutableDictionary *result, NSError *error){
                                              if (error) {
                                                  [[SMNetworkClient sharedClient] showNetworkError:error];
                                              } else {
                                                  // 과정 기수 목록을 DB에 저장하고 tableView 업데이트
                                                  NSArray *classes = [result valueForKeyPath:@"data"];
                                                  NSLog(@"목록 : %@", classes);
                                                  
//                                                  if (self.managedObjectContext == nil)
//                                                  {
//                                                      self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
//                                                      NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
//                                                  }
//
//                                                  Course *class = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
//                                                  Student *student = (Student *)[NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.managedObjectContext];
//                                                  Staff *staff = (Staff *)[NSEntityDescription insertNewObjectForEntityForName:@"Staff" inManagedObjectContext:self.managedObjectContext];
//
//                                                  Major *major = (Major *)[NSEntityDescription insertNewObjectForEntityForName:@"Major" inManagedObjectContext:self.managedObjectContext];
//
//                                                  Faculty *faculty = (Faculty *)[NSEntityDescription insertNewObjectForEntityForName:@"Faculty" inManagedObjectContext:self.managedObjectContext];
                                                  
                                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [self onDBUpdate:classes];
                                                  });
                                              }
                                          }];
}


#pragma mark - CoreData methods

/// 즐겨찾기 DB 목록 가져오기
- (NSArray *)loadDBFavoriteCourse
{
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
//    NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
//    if (error) {
//        return nil;
//    }

    // select
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // where ((ZCOURSE="FACULTY" OR ZCOURSE="STAFF") OR ZFAVYN="y")
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(course == 'FACULTY') OR (course == 'STAFF') OR (favyn == 'y')"];
    [fetchRequest setPredicate:predicate];
    
    // order by (ZCOURSECLASS, ZCOURSE)
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    for (Course *class in fetchedObjects) {
        NSLog(@"title : %@", class.title);
    }
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
        return fetchedObjects;
    }
    return nil;
}

/// course classes DB 추가 및 업데이트
- (void)onDBUpdate:(NSArray *)classList
{
    NSError *error;
    BOOL isSaved = NO; 

    // DB에 없는 항목은 추가하기
    for (NSDictionary *dict in classList)
    {
        BOOL isExistDB = NO;
        
        NSLog(@"class info : %@", dict);
        
        
        // 기존 DB에 저장된 데이터 읽어오기
//        if ([dict[@"course"] isEqualToString:@"FACULTY"] || [dict[@"course"] isEqualToString:@"STAFF"]) {
//            isExistDB = [self isFetchCourse:dict[@"course"]];
//        } else {
//            isExistDB = [self isFetchCourse:dict[@"courseclass"]];
//        }
        NSLog(@"뭐 찾을까?\n COURSE : %@\n COURSECLASS : %@", dict[@"course"], dict[@"courseclass"]);
        
//        NSArray *filtered = [self.favorites filteredArrayUsingPredicate:
//                             [NSPredicate predicateWithFormat:@"(course == %@) AND (courseclass == %@)", dict[@"course"], dict[@"courseclass"]]];
        NSArray *filtered = [self filteredObject:dict];
        
//        for (NSDictionary *info in filtered) {
//            NSLog(@"찾았니? %@", info);
//        }
        
//        if (isExistDB == NO)
        if ([filtered count] > 0)
        {
            // 기존 목록에 존재하면 업데이트 (UPDATE)
            Course *favorite = [filtered objectAtIndex:0];
            favorite.course = dict[@"course"];
            favorite.courseclass = dict[@"courseclass"];
            favorite.title = dict[@"title"];
            favorite.title_en = dict[@"title_en"];
            favorite.favyn = dict[@"favyn"];
            favorite.count = dict[@"count"];
        }
        else
        {
            // 기존 목록에 없으면 추가 (INSERT)

            Course *class = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
            NSLog(@"class info : %@", dict);

            class.course = dict[@"course"];
            class.courseclass = dict[@"courseclass"];
            class.title = dict[@"title"];
            class.title_en = dict[@"title_en"];
//            if ([dict objectForKey:@"favyn"]) {
                class.favyn = dict[@"favyn"];
//            }
//            if ([dict objectForKey:@"count"]) {
                class.count = dict[@"count"];
//            }
            
            isSaved = YES;
        }

    }
    
    if (isSaved == YES)
    {
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"error : %@", [error localizedDescription]);
        }
        else    {
            NSLog(@"insert success..");
            
            // 즐겨찾기 목록 로컬 DB에서 갱신.
            [self loadDBFavoriteCourse];
            
//            // 기수 목록을 모두 저장한 후, 즐겨찾기 목록 가져오기
//            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//
//            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
//            [fetchRequest setEntity:entity];
//            
//            // order by
//            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
//            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//
//            NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//            NSLog(@"DB data count : %d", [fetchedObjects count]);
//            for (NSManagedObject *info in fetchedObjects)
//            {
//                NSLog(@"DB Dict : %@", [info valueForKey:@"title"]);
//    //            NSLog(@"Name: %@", [info valueForKey:@"name"]);
//    //            NSManagedObject *details = [info valueForKey:@"details"];
//    //            NSLog(@"Zip: %@", [details valueForKey:@"zip"]);
//            }
        
            // 갱신된 즐겨찾기 목록 메뉴 업데이트.
            MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
            [menu setAddrMenuList:_favorites];
        }
    }
}


/// 기존 DB에 새로운 dict와 같은 값이 있는지 조사.
- (NSArray *)filteredObject:(NSDictionary *)newDict
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // select Table
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // where
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course==%@", course];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(course == %@) AND (courseclass == %@)", newDict[@"course"], newDict[@"courseclass"]];
    [fetchRequest setPredicate:predicate];
    
    // order by
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *filtered = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Filtered DB count : %d", [filtered count]);

    return filtered;
}


//- (BOOL)isFetchCourse:(NSString *)course
//{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//
//    // select Table
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    // where
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course==%@", course];
//    [fetchRequest setPredicate:predicate];
//    
//    // order by
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//
//    NSError *error = nil;
//    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSLog(@"DB data count : %d", [fetchedObjects count]);
//    
//    if (fetchedObjects && [fetchedObjects count] > 0)
//    {
//        return YES;
//    }
//    
//    return NO;
////    return fetchedObjects; //fetchedObjects will always exist although it may be empty
//}
//
//- (BOOL)isFetchClass:(NSString *)class
//{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    // select Table
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    // where
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"courseclass==%@", class];
//    [fetchRequest setPredicate:predicate];
//    
//    // order by
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//    
//    NSError *error = nil;
//    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSLog(@"DB data count : %d", [fetchedObjects count]);
//    
//    if (fetchedObjects && [fetchedObjects count] > 0)
//    {
//        return YES;
//    }
//    
//    return NO;
//    //    return fetchedObjects; //fetchedObjects will always exist although it may be empty
//}
@end
