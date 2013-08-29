//
//  MyInfoViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "MyInfoViewController.h"
#import "NSString+MD5.h"

@interface MyInfoViewController ()

@property (strong, nonatomic) UIImageView *profileImageView;

@property (strong, nonatomic) UILabel *personalInfoLabel;

@property (strong, nonatomic) UILabel *idLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *mobileLabel;
@property (strong, nonatomic) UILabel *emailLabel;
@property (strong, nonatomic) UILabel *officeKoLabel;
@property (strong, nonatomic) UILabel *officeEnLabel;

@property (strong, nonatomic) UILabel *idValueLabel;
@property (strong, nonatomic) UILabel *nameValeLabel;
@property (strong, nonatomic) UILabel *mobileValueLabel;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextField *workKoTextField;
@property (strong, nonatomic) UITextField *departmentKoTextField;
@property (strong, nonatomic) UITextField *positionKoTextField;
@property (strong, nonatomic) UITextField *workEnTextField;
@property (strong, nonatomic) UITextField *departmentEnTextField;
@property (strong, nonatomic) UITextField *positionEnTextField;
@property (strong, nonatomic) UIButton *shareMobileBtn;
@property (strong, nonatomic) UIButton *shareEmailBtn;
@property (strong, nonatomic) UIButton *shareOfficeBtn;


@property (strong, nonatomic) UILabel *otherInfoLabel;

@property (strong, nonatomic) UILabel *loginLabel;
@property (strong, nonatomic) UILabel *languageLabel;

//@property (strong, nonatomic) UILabel *idLabel;
//@property (strong, nonatomic) UILabel *idLabel;
//@property (strong, nonatomic) UILabel *idLabel;

@property (strong, nonatomic) UIButton *chIdSaveBtn;
@property (strong, nonatomic) UIButton *chAutoLoginBtn;
@property (strong, nonatomic) UIButton *langKoBtn;
@property (strong, nonatomic) UIButton *langEnBtn;

@end

@implementation MyInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.mType = MemberTypeStudent;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // 내 정보 화면 구성
    [self setupMyInfoUI];
    
    // DB(myInfo) 데이터 가져오기
//    [self loadMyInfo];
    
    // 서버로 내 정보 요청 
    [self requestAPIMyInfo];

    
    // MARK: 프로필 유무 설정하여 최초 실행 이후에 프로필 화면으로 이동하지 않도록 처리.
//    [UserContext shared].isExistProfile = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 내 정보 화면 구성
- (void)setupMyInfoUI
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
//    if ([[UIScreen mainScreen] bounds].size.height == 568)
    
    // 배경 스크롤 뷰
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, rect.size.height - 44.0f - 0.0f)];
    scrollView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1f];
    scrollView.contentSize = CGSizeMake(300.0f, 396.0f + 400.0f);
    
    [self.view addSubview:scrollView];

    
    // 프로필 사진
    self.profileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nocontents_img6"]];
    self.profileImageView.frame = CGRectMake(90.0f, 0.0f, 128.0f, 128.0f);
    self.profileImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    
    [scrollView addSubview:self.profileImageView];

    
    CGFloat xOffset = 1.0f;
    CGFloat yOffset = 5.0f;

    // 개인 프로필 뷰
    self.personalInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 140.0f, 90.0f, 14.0f)];
    [self.personalInfoLabel setTextColor:[UIColor blackColor]];
    [self.personalInfoLabel setBackgroundColor:[UIColor clearColor]];
    [self.personalInfoLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [self.personalInfoLabel setTextAlignment:NSTextAlignmentLeft];
    [self.personalInfoLabel setText:@"개인정보"];
    
    [scrollView addSubview:self.personalInfoLabel];
    
    // 학생 배경 뷰
    UIView *studentView = [[UIView alloc] initWithFrame:CGRectMake(5.0f, 160.0f, 310.0f, 327.0f)];
    studentView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];

    [scrollView addSubview:studentView];
    

    yOffset = 1.0f;
    {
        // 아이디 text 
        self.idLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 90.0f, 20.0f)];
        [self.idLabel setTextColor:[UIColor blackColor]];
        [self.idLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.idLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.idLabel setTextAlignment:NSTextAlignmentCenter];
        [self.idLabel setText:@"아이디"];
        
        [studentView addSubview:self.idLabel];
        yOffset += 21.0f;
        
    
        // 이름 text
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 90.0f, 20.0f)];
        [self.nameLabel setTextColor:[UIColor blackColor]];
        [self.nameLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.nameLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.nameLabel setText:@"이름"];
        
        [studentView addSubview:self.nameLabel];
        yOffset += 21.0f;
        
        
        // Mobile text
        self.mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 90.0f, 20.0f)];
        [self.mobileLabel setTextColor:[UIColor blackColor]];
        [self.mobileLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.mobileLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.mobileLabel setTextAlignment:NSTextAlignmentCenter];
        [self.mobileLabel setText:@"Mobile"];
        
        [studentView addSubview:self.mobileLabel];
        yOffset += 21.0f;

        
        // Email text
        self.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 90.0f, 20.0f)];
        [self.emailLabel setTextColor:[UIColor blackColor]];
        [self.emailLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.emailLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.emailLabel setTextAlignment:NSTextAlignmentCenter];
        [self.emailLabel setText:@"Email"];
        
        [studentView addSubview:self.emailLabel];
        yOffset += 21.0f;

        
        // 직장(국문) text
        self.officeKoLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 90.0f, 120.0f)];
        [self.officeKoLabel setTextColor:[UIColor blackColor]];
        [self.officeKoLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.officeKoLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.officeKoLabel setTextAlignment:NSTextAlignmentCenter];
        [self.officeKoLabel setText:@"직장 (국문)"];
        
        [studentView addSubview:self.officeKoLabel];
        yOffset += 121.0f;

        
        // 직장(영문) text
        self.officeEnLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 90.0f, 120.0f)];
        [self.officeEnLabel setTextColor:[UIColor blackColor]];
        [self.officeEnLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.officeEnLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.officeEnLabel setTextAlignment:NSTextAlignmentCenter];
        [self.officeEnLabel setText:@"직장(영문)"];
        
        [studentView addSubview:self.officeEnLabel];
        yOffset += 131.0f;
        
    }

//
//    // 라인
//    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 65 - 1, self.contentView.frame.size.width, 1.0f)];
//    line.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];

    
    // 기타설정 뷰
    self.personalInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, studentView.frame.origin.y + studentView.frame.size.height + 10, 90.0f, 14.0f)];
    [self.personalInfoLabel setTextColor:[UIColor blackColor]];
    [self.personalInfoLabel setBackgroundColor:[UIColor clearColor]];
    [self.personalInfoLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [self.personalInfoLabel setTextAlignment:NSTextAlignmentLeft];
    [self.personalInfoLabel setText:@"기타설정"];
    
    [scrollView addSubview:self.personalInfoLabel];

    
    // 기타설정 배경 뷰
    UIView *otherView = [[UIView alloc] initWithFrame:CGRectMake(5.0f, studentView.frame.origin.y + studentView.frame.size.height + 30, 310.0f, 50.0f)];
    otherView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    
    [scrollView addSubview:otherView];
    
    
    yOffset = 1.0f;
    {
        // 로그인 text
        self.loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 90.0f, 20.0f)];
        [self.loginLabel setTextColor:[UIColor blackColor]];
        [self.loginLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.loginLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.loginLabel setTextAlignment:NSTextAlignmentCenter];
        [self.loginLabel setText:@"로그인"];
        
        [otherView addSubview:self.loginLabel];
        yOffset += 21.0f;
        
        
        // 언어설정 text
        self.languageLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 90.0f, 20.0f)];
        [self.languageLabel setTextColor:[UIColor blackColor]];
        [self.languageLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.languageLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.languageLabel setTextAlignment:NSTextAlignmentCenter];
        [self.languageLabel setText:@"언어설정"];
        
        [otherView addSubview:self.languageLabel];
        yOffset += 21.0f;

    }

}


#pragma mark - Assets
- (NSDictionary *)loadMyInfo
{
    // TODO: 내 정보 데이터 (imsi)
    NSDictionary *myInfoDict = @{@"name":@"테스터01",
                                @"name_en":@"Tester 01",
                                @"mobile":@"010-2387-3856",
                                @"email":@"hwa@zenda.co.kr",
                                @"company":@"",
                                @"department":@"",
                                @"title":@"",
                                @"company_en":@"",
                                @"department_en":@"",
                                @"title_en":@"",
                                @"share_mobile":@"n",
                                @"share_email":@"y",
                                @"share_company":@"y",
                                @"photourl":@"/memberphoto/fd8dd0420f0ac6b5364a42c20aaea359.gif"
    };
    
    return myInfoDict;
}

#pragma mark - Network API

- (void)requestAPIMyInfo
{
//    path    /fb/myinfo
//    param   scode=5684825a51beb9d2fa05e4675d91253c&userid=ztest01&certno=m9kebjkakte1tvrqfg90i9fh84
    
    NSDictionary *loginInfo = [[UserContext shared] loginInfo];
    NSString *mobileNo = @"01023873856";
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
    NSString *certNo = [[NSUserDefaults standardUserDefaults] objectForKey:kUserCertNo];
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};
    
    // 내 (프로필)정보
    [[SMNetworkClient sharedClient] postMyInfo:param
                                         block:^(NSMutableDictionary *result, NSError *error) {
                                             if (error) {
                                                 [[SMNetworkClient sharedClient] showNetworkError:error];
                                             } else {
                                                 // 과정 기수 목록을 DB에 저장하고 tableView 업데이트
                                                 //NSArray *classes = [result valueForKeyPath:@"data"];
                                                 NSLog(@"내 정보 : %@", result);
                                                 
//                                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                                  dispatch_async(dispatch_get_main_queue(), ^{
//                                                      [self onDBUpdate:(NSDictionary *)result];
//                                                  });
                                              }
                                          }];
}

///// myInfo DB 추가 및 업데이트
//- (void)onDBUpdate:(NSDictionary *)myInfo
//{
//    
//    //    // 컨텍스트 지정
//    //    if (self.managedObjectContext == nil)
//    //    {
//    //        self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
//    //        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
//    //    }
//    
//    NSError *error;
//    BOOL isSaved = NO;
//    
//    // DB에 없는 항목은 추가하기
//    for (NSDictionary *dict in classList)
//    {
//        BOOL isExistDB = YES;
//        NSLog(@"class info : %@", dict);
//        
//        // 기존 DB에 저장된 데이터 읽어오기
//        if ([dict[@"course"] isEqualToString:@"FACULTY"] || [dict[@"course"] isEqualToString:@"STAFF"]) {
//            isExistDB = [self isFetchCourse:dict[@"course"]];
//        } else {
//            isExistDB = [self isFetchCourse:dict[@"courseclass"]];
//        }
//        
//        // 기존 DB에 없으면 추가
//        if (isExistDB == NO)
//        {
//            Course *class = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
//            NSLog(@"class info : %@", dict);
//            
//            class.course = dict[@"course"];
//            class.courseclass = dict[@"courseclass"];
//            class.title = dict[@"title"];
//            class.title_en = dict[@"title_en"];
//            
//            isSaved = YES;
//        }
//    }
//    
//    if (isSaved == YES)
//    {
//        if (![self.managedObjectContext save:&error]) {
//            NSLog(@"error : %@", [error localizedDescription]);
//        }
//        else    {
//            NSLog(@"insert success..");
//            
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
//                //            NSLog(@"Name: %@", [info valueForKey:@"name"]);
//                //            NSManagedObject *details = [info valueForKey:@"details"];
//                //            NSLog(@"Zip: %@", [details valueForKey:@"zip"]);
//            }
//            
//            MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
//            menu.addrMenuList = [fetchedObjects mutableCopy];            
//        }
//    }
//}

@end
