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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
    // 하단 버튼 툴바
    FavoriteToolViewController *footerToolbar = [[FavoriteToolViewController alloc] init];
    footerToolbar.view.frame = CGRectMake(0.0f, 416.0f - 80.0f, 320.0f, 80.0f);
    
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
    if (self.managedObjectContext == nil)
    {
        self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
    }
    
    for (NSDictionary *dict in classList)
    {
        Course *class = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
        NSLog(@"class info : %@", dict);

        class.course = dict[@"course"];
        class.courseclass = dict[@"courseclass"];
        class.title = dict[@"title"];
        class.title_en = dict[@"title_en"];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"error : %@", [error localizedDescription]);
    }
    else    {
        NSLog(@"insert success..");
    }

    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Classes" inManagedObjectContext:[appDelegate managedObjectContext]];

//    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
//    NSManagedObjectContext *context = [appDelegate managedObjectContext];
//    NSManagedObjectModel *managedObjectModel = [[context persistentStoreCoordinator] managedObjectModel];
//    NSEntityDescription *classesEntity = [[managedObjectModel entitiesByName] objectForKey:@"Classes"];
//    NSEntityDescription *classesEntity = [NSEntityDescription entityForName:@"Classes" inManagedObjectContext:context];

    for (NSDictionary *dict in classList)
    {
        NSLog(@"class info : %@", dict);
//        Course *cs = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:context];
        
        
//        AUTHOR *author = (AUTHOR *)[NSEntityDescription insertNewObjectForEntityForName:@"AUTHOR" inManagedObjectContext:[appDelegate managedObjectContext]];
//        author.userid = [sessionInfo objectForKey:@"AUTHOR_USERNAME"];
//        author.name = [sessionInfo objectForKey:@"AUTHOR"];
//        author.email = [sessionInfo objectForKey:@"AUTHOR_EMAIL"];
//        author.department = [sessionInfo objectForKey:@"AUTHOR_DEPARTMENT"];
//        author.photo = [sessionInfo objectForKey:@"AUTHOR_PICTURE"];
//        author.twitter = [sessionInfo objectForKey:@"AUTHOR_TWITTER"];
//        author.facebook = [sessionInfo objectForKey:@"AUTHOR_FACEBOOK"];
//        author.bio = [sessionInfo objectForKey:@"AUTHOR_BIO"];

    }
    
}
@end
