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


@property (strong, nonatomic) UILabel *personalInfoLabel;
@property (strong, nonatomic) UILabel *idLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *mobileLabel;
@property (strong, nonatomic) UILabel *emailLabel;
@property (strong, nonatomic) UILabel *officeKoLabel;
@property (strong, nonatomic) UILabel *officeEnLabel;

@property (strong, nonatomic) UILabel *otherInfoLabel;
@property (strong, nonatomic) UILabel *loginLabel;
@property (strong, nonatomic) UILabel *languageLabel;
//@property (strong, nonatomic) UILabel *idLabel;
//@property (strong, nonatomic) UILabel *idLabel;
//@property (strong, nonatomic) UILabel *idLabel;

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

    [self setupMyInfoUI];
    
    // 내 (프로필)정보 가져오기
//    [self loadMyInfo];
    [self requestAPIMyInfo];

    
    // MARK: 프로필 유무 설정하여 최초 실행 이후에 프로필 화면으로 이동하지 않도록 처리.
    [UserContext shared].isExistProfile = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 내 정보 화면 구성
- (void)setupMyInfoUI
{
    UIView *studentView = [[UIView alloc] initWithFrame:self.view.bounds];
    studentView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    
    CGRect frame = studentView.frame;
    CGFloat xOffset = 5.0f;
//    CGFloat labelOffsetX  = 10.0f
    
    {
    
        // 개인정보 text
        self.personalInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, frame.origin.y + 10.0f, 90.0f, 14.0f)];
        [self.personalInfoLabel setTextColor:[UIColor blackColor]];
        [self.personalInfoLabel setBackgroundColor:[UIColor yellowColor]];
        [self.personalInfoLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [self.personalInfoLabel setTextAlignment:NSTextAlignmentLeft];
        [self.personalInfoLabel setText:@"개인정보"];
    
        [studentView addSubview:self.personalInfoLabel];
    
        {
            // 아이디 text 
            self.idLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, frame.origin.y + 30.0f, 90.0f, 20.0f)];
            [self.idLabel setTextColor:[UIColor blackColor]];
            [self.idLabel setBackgroundColor:[UIColor yellowColor]];
            [self.idLabel setFont:[UIFont systemFontOfSize:14.0f]];
            [self.idLabel setTextAlignment:NSTextAlignmentCenter];
            [self.idLabel setText:@"아이디"];
            
            [studentView addSubview:self.idLabel];
        
            // 이름 text
            self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, frame.origin.y + 55.0f, 90.0f, 20.0f)];
            [self.nameLabel setTextColor:[UIColor blackColor]];
            [self.nameLabel setBackgroundColor:[UIColor yellowColor]];
            [self.nameLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
            [self.nameLabel setText:@"이름"];
            
            [studentView addSubview:self.nameLabel];

            
            // Mobile text
            self.mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, frame.origin.y + 80.0f, 90.0f, 20.0f)];
            [self.mobileLabel setTextColor:[UIColor blackColor]];
            [self.mobileLabel setBackgroundColor:[UIColor yellowColor]];
            [self.mobileLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [self.mobileLabel setTextAlignment:NSTextAlignmentCenter];
            [self.mobileLabel setText:@"Mobile"];
            
            [studentView addSubview:self.mobileLabel];

            
            // Email text
            self.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, frame.origin.y + 105.0f, 90.0f, 20.0f)];
            [self.emailLabel setTextColor:[UIColor blackColor]];
            [self.emailLabel setBackgroundColor:[UIColor yellowColor]];
            [self.emailLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [self.emailLabel setTextAlignment:NSTextAlignmentCenter];
            [self.emailLabel setText:@"Email"];
            
            [studentView addSubview:self.emailLabel];

            
            // 직장(국문) text
            self.officeKoLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, frame.origin.y + 130.0f, 90.0f, 80.0f)];
            [self.officeKoLabel setTextColor:[UIColor blackColor]];
            [self.officeKoLabel setBackgroundColor:[UIColor yellowColor]];
            [self.officeKoLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [self.officeKoLabel setTextAlignment:NSTextAlignmentCenter];
            [self.officeKoLabel setText:@"직장 (국문)"];
            
            [studentView addSubview:self.officeKoLabel];

            
            // 직장(영문) text
            self.officeEnLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, frame.origin.y + 215.0f, 90.0f, 14.0f)];
            [self.officeEnLabel setTextColor:[UIColor blackColor]];
            [self.officeEnLabel setBackgroundColor:[UIColor yellowColor]];
            [self.officeEnLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [self.officeEnLabel setTextAlignment:NSTextAlignmentCenter];
            [self.officeEnLabel setText:@"직장(영문)"];
            
            [studentView addSubview:self.officeEnLabel];

            
        }
        //        // 이름
//        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 5.0f, 200.0f, 14.0f)];
//        _nameLabel.textColor = [UIColor blackColor];
//        _nameLabel.backgroundColor = [UIColor clearColor];
//        [_nameLabel setFont:[UIFont systemFontOfSize:12.0f]];
//        
//        [studentView addSubview:_nameLabel];
//    
//    
//    // 소속
//    _memberLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 21.0f, 200.0f, 14.0f)];
//    _memberLabel.textColor = [UIColor lightGrayColor];
//    _memberLabel.backgroundColor = [UIColor clearColor];
//    [_memberLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    
//    [self.contentView addSubview:_memberLabel];
//    
//    // 모바일
//    UILabel *fixLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 35.0f, 50.f, 14.0f)];
//    fixLabel1.textColor = [UIColor grayColor];
//    [fixLabel1 setFont:[UIFont systemFontOfSize:12.0f]];
//    
//    [self.contentView addSubview:fixLabel1];
//    
//    
//    _mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.0f, 35.0f, 145.0f, 14.0f)];
//    _mobileLabel.textColor = [UIColor lightGrayColor];
//    [_mobileLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    
//    [self.contentView addSubview:_mobileLabel];
//    
//    
//    // 이메일
//    UILabel *fixLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 51.0f, 50.f, 14.0f)];
//    fixLabel2.textColor = [UIColor grayColor];
//    [fixLabel2 setFont:[UIFont systemFontOfSize:12.0f]];
//    
//    [self.contentView addSubview:fixLabel2];
//    
//    
//    _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.0f, 51.0f, 145.0f, 14.0f)];
//    _emailLabel.textColor = [UIColor lightGrayColor];
//    [_emailLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    
//    [self.contentView addSubview:_emailLabel];
//    
//    
//    // 라인
//    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 65 - 1, self.contentView.frame.size.width, 1.0f)];
//    line.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
//
//    
//    // 로그인 버튼
//    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _loginBtn.frame = CGRectMake(xOffset + _idTextField.frame.size.width + 10.0f, startY, 70.0f, 56.0f);
//    [_loginBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:14] forState:UIControlStateNormal];
//    [_loginBtn setTitle:LocalizedString(@"login_title", @"로그인") forState:UIControlStateNormal];
//    [_loginBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
//    _loginBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [_loginBtn addTarget:self action:@selector(onLoginClicked) forControlEvents:UIControlEventTouchUpInside];
//    
//    [bgView addSubview:_loginBtn];

    }
    [self.view addSubview:studentView];
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
    NSString *userId = @"ztest01";
    NSString *certNo = loginInfo[@"certno"];
    
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
