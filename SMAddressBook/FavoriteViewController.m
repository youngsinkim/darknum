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

@interface FavoriteViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation FavoriteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        self.navigationItem.title = LocalizedString(@"login_title", @"로그인");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // 왼쪽 메뉴 설정
    MenuTableViewController *menuVC = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
//    menuVC.addrMenuList = nil;

    // 즐겨찾기 화면 구성
    [self setupFavoriteUI];
    
    // 과정 기수 목록 가져오기
    [self requestAPIClasses];
    
    // 기수 목록 중 즐겨찾기 목록 구성
    
    // 업데이트 목록 구성
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View mothods
- (void)setupFavoriteUI
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    
    // 하단 버튼 툴바
    FavoriteToolViewController *footerToolbar = [[FavoriteToolViewController alloc] init];
    footerToolbar.view.frame = CGRectMake(0.0f, rect.size.height - 44.0f - kFvToolH, 320.0f, kFvToolH);
    
    [self addChildViewController:footerToolbar];
    [self.view addSubview:footerToolbar.view];
    [footerToolbar didMoveToParentViewController:self];
}

#pragma mark - Network API
- (void)requestAPIClasses
{
    //    NSDictionary *param = @{@"scode"=5684825a51beb9d2fa05e4675d91253c&userid=ztest01&certno=m9kebjkakte1tvrqfg90i9fh84};
    NSString *mobileNo = @"01023873856";
    NSString *userId = @"ztest01";
    NSString *certNo = @"m9kebjkakte1tvrqfg90i9fh84";
    
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

- (void)onDBUpdate:(NSArray *)classList
{

    // 컨텍스트 지정
    if (self.managedObjectContext == nil)
    {
        self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
    }
    
    NSError *error;
    BOOL isSaved = NO; 

    // DB에 없는 항목은 추가하기
    for (NSDictionary *dict in classList)
    {
        BOOL isExistDB = YES;
        NSLog(@"class info : %@", dict);
        
        // 기존 DB에 저장된 데이터 읽어오기
        if ([dict[@"course"] isEqualToString:@"FACULTY"] || [dict[@"course"] isEqualToString:@"STAFF"]) {
            isExistDB = [self isFetchCourse:dict[@"course"]];
        } else {
            isExistDB = [self isFetchCourse:dict[@"courseclass"]];
        }
        
        // 기존 DB에 없으면 추가
        if (isExistDB == NO)
        {
            Course *class = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
            NSLog(@"class info : %@", dict);

            class.course = dict[@"course"];
            class.courseclass = dict[@"courseclass"];
            class.title = dict[@"title"];
            class.title_en = dict[@"title_en"];
            
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
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            
            // order by
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

            NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            NSLog(@"DB data count : %d", [fetchedObjects count]);
            for (NSManagedObject *info in fetchedObjects)
            {
                NSLog(@"DB Dict : %@", [info valueForKey:@"title"]);
    //            NSLog(@"Name: %@", [info valueForKey:@"name"]);
    //            NSManagedObject *details = [info valueForKey:@"details"];
    //            NSLog(@"Zip: %@", [details valueForKey:@"zip"]);
            }
        
            MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
            menu.addrMenuList = [fetchedObjects mutableCopy];            
        }
    }
}

- (BOOL)isFetchCourse:(NSString *)course
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    // select Table
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // where
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course==%@", course];
    [fetchRequest setPredicate:predicate];
    
    // order by
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
        return YES;
    }
    
    return NO;
//    return fetchedObjects; //fetchedObjects will always exist although it may be empty
}

- (BOOL)isFetchClass:(NSString *)class
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // select Table
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // where
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"courseclass==%@", class];
    [fetchRequest setPredicate:predicate];
    
    // order by
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
        return YES;
    }
    
    return NO;
    //    return fetchedObjects; //fetchedObjects will always exist although it may be empty
}
@end
