//
//  MyInfoViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "MyInfoViewController.h"
#import "NSString+MD5.h"
#import "StudentProfileViewController.h"
#import "StaffProfileViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MyInfoViewController ()

@property (strong, nonatomic) NSMutableDictionary *myInfo;

@property (strong, nonatomic) UIImageView *profileImageView;

@property (strong, nonatomic) UILabel *personalInfoLabel;

@property (strong, nonatomic) UILabel *idLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *mobileLabel;
@property (strong, nonatomic) UILabel *emailLabel;
@property (strong, nonatomic) UILabel *officeKoLabel;
@property (strong, nonatomic) UILabel *officeEnLabel;

@property (strong, nonatomic) UILabel *idValueLabel;
@property (strong, nonatomic) UILabel *nameValueLabel;
@property (strong, nonatomic) UILabel *mobileValueLabel;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextField *workKoTextField;         // 직장명
@property (strong, nonatomic) UITextField *workEnTextField;
@property (strong, nonatomic) UITextField *departmentKoTextField;   // 부서명
@property (strong, nonatomic) UITextField *departmentEnTextField;
@property (strong, nonatomic) UITextField *positionKoTextField;     // 직위
@property (strong, nonatomic) UITextField *positionEnTextField;
@property (strong, nonatomic) UIButton *shareMobileBtn;
@property (strong, nonatomic) UIButton *shareEmailBtn;
@property (strong, nonatomic) UIButton *shareOfficeBtn;
@property (strong, nonatomic) UILabel *telLabel;
@property (strong, nonatomic) UITextField *telTextField;

@property (strong, nonatomic) UILabel *otherInfoLabel;

@property (strong, nonatomic) UILabel *loginLabel;
@property (strong, nonatomic) UILabel *languageLabel;
@property (strong, nonatomic) UIButton *chIdSaveBtn;
@property (strong, nonatomic) UIButton *chAutoLoginBtn;
//@property (strong, nonatomic) UIButton *langKoBtn;
//@property (strong, nonatomic) UIButton *langEnBtn;

@property (strong, nonatomic) UIButton *saveBtn;

@end


@implementation MyInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"내 정보 설정";
        
        _memType = MemberTypeUnknown;
        _myInfo = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

//- (id)initWithMemberType:(MemberType)type
//{
//    self = [super init];
//    if (self) {
//        self.mType = type;
//        self.myInfo = [[NSMutableDictionary alloc] init];
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    if (!IS_LESS_THEN_IOS7) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.navigationController.navigationBar.translucent = NO;
//    }

    _memType = (MemberType)[[[UserContext shared] memberType] integerValue];
    NSLog(@"내 멤버 타입 : %d", _memType);
    
//    if (memType == MemberTypeStudent)
//    {
//        // 학생이면, 학생 프로필 화면 구성
//        StudentProfileViewController *studentProfileVC = [[StudentProfileViewController alloc] init];
//        
//        [self addChildViewController:studentProfileVC];
//        [self.view addSubview:studentProfileVC.view];
//        [studentProfileVC didMoveToParentViewController:self];
//    }
//    else
//    {
//        // 교수/교직원이면, staff 프로필 화면 구성
//        StaffProfileViewController *staffProfileVC = [[StaffProfileViewController alloc] init];
//        
//        [self addChildViewController:staffProfileVC];
//        [self.view addSubview:staffProfileVC.view];
//        [staffProfileVC didMoveToParentViewController:self];
//    }
//    return;
    
    // 내 정보 화면 구성
    [self setupMyInfoUI];
    
    if (_memType != MemberTypeStudent) {
        _telLabel.hidden = NO;
        _telTextField.hidden = NO;
        
        _shareMobileBtn.hidden = YES;
        _shareEmailBtn.hidden = YES;
        _shareOfficeBtn.hidden = YES;
    }
    
//    // 로컬에서(DB) 데이터 가져오기
//    [_myInfo setDictionary:[self loadMyInfo]];
//    NSLog(@"로컬 저장된 내 정보 : %@", _myInfo);
//    [self updateMyInfo];
//    
//    // 서버로 내 정보 요청 
//    [self requestAPIMyInfo];

    
    // MARK: 프로필 유무 설정하여 최초 실행 이후에 프로필 화면으로 이동하지 않도록 처리.
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSetProfile];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    CGRect viewFrame = self.view.bounds;
    CGFloat yOffset = 0.0f;
    CGFloat scrolViewHeight = viewFrame.size.height;
    
    if (IS_LESS_THEN_IOS7) {
    }
    
    // 배경 스크롤 뷰
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10.0f, yOffset, viewFrame.size.width - 20.0f, scrolViewHeight)];
    //    scrollView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1f];
    //    scrollView.backgroundColor = [UIColor yellowColor];
    //    scrollView.contentSize = CGSizeMake(viewFrame.size.width - 20.0f, scrolViewHeight);
    if (_memType == MemberTypeStudent) {
        scrolViewHeight += 100.0f;
        scrollView.contentSize = CGSizeMake(viewFrame.size.width - 20.0f, scrolViewHeight);
    } else {
        scrolViewHeight -= 64.0f;
    }
    
    [self.view addSubview:scrollView];
    
    
    // 배경 이미지 뷰
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, scrollView.frame.size.width, scrolViewHeight - 20.0f)];
    bgView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2f]; //[UIColor greenColor];
    
    [scrollView addSubview:bgView];
    
    
    // 프로필 사진
    self.profileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder"]];
    self.profileImageView.frame = CGRectMake(0.0f, 5.0f, 120.0f, 120.0f);
    self.profileImageView.center = CGPointMake(viewFrame.size.width / 2, 65.0f);
    self.profileImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    self.profileImageView.userInteractionEnabled = YES;
    
    [bgView addSubview:self.profileImageView];

    // 프로필 사진 이벤트
    {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        [bgView addGestureRecognizer:singleTap];
//        [scrollView setMultipleTouchEnabled:YES];
//        [bgView setUserInteractionEnabled:YES];
//        [self.view addSubview:scrollView];
//        self.view.userInteractionEnabled=YES;
    }
    
    CGFloat xOffset = 5.0f;
    yOffset = 140.0f;

    // 개인정보 텍스트
    self.personalInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 60.0f, 16.0f)];
    [self.personalInfoLabel setTextColor:[UIColor blackColor]];
    [self.personalInfoLabel setBackgroundColor:[UIColor lightGrayColor]];
    [self.personalInfoLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.personalInfoLabel setTextAlignment:NSTextAlignmentLeft];
    [self.personalInfoLabel setText:@"개인정보"];
    
    [bgView addSubview:self.personalInfoLabel];
    yOffset += 18.0f;
    
//    // 학생 배경 뷰
//    UIView *studentView = [[UIView alloc] initWithFrame:CGRectMake(5.0f, 160.0f, 310.0f, 327.0f)];
//    studentView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
//
//    [scrollView addSubview:studentView];
//    
//
//    yOffset = 1.0f;
    {
        // 아이디 text
        self.idLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 80.0f, 18.0f)];
        [self.idLabel setTextColor:[UIColor blackColor]];
        [self.idLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.idLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.idLabel setTextAlignment:NSTextAlignmentCenter];
        [self.idLabel setText:@"아이디"];
        
        [bgView addSubview:self.idLabel];

        // 아이디 value
        self.idValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 200.0f, 18.0f)];
        [self.idValueLabel setTextColor:[UIColor darkGrayColor]];
        [self.idValueLabel setBackgroundColor:[UIColor whiteColor]];
        [self.idValueLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.idValueLabel setText:@"테스트 아이디"];
        
        [bgView addSubview:self.idValueLabel];
        yOffset += 22.0f;
        

        // 이름 text
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 80.0f, 18.0f)];
        [self.nameLabel setTextColor:[UIColor blackColor]];
        [self.nameLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.nameLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.nameLabel setText:@"이름"];
        
        [bgView addSubview:self.nameLabel];
        
        
        // 이름 value
        self.nameValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset+850, yOffset, 200.0f, 18.0f)];
        [self.nameValueLabel setTextColor:[UIColor darkGrayColor]];
        [self.nameValueLabel setBackgroundColor:[UIColor whiteColor]];
        [self.nameValueLabel setFont:[UIFont systemFontOfSize:14.0f]];
        
        [bgView addSubview:self.nameValueLabel];
        yOffset += 22.0f;
        
        
        // Mobile text
        self.mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 80.0f, 22.0f)];
        [self.mobileLabel setTextColor:[UIColor blackColor]];
        [self.mobileLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.mobileLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.mobileLabel setTextAlignment:NSTextAlignmentCenter];
        [self.mobileLabel setText:@"Mobile"];
        
        [bgView addSubview:self.mobileLabel];
        
        
        // Mobile value
        self.mobileValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 150.0f, 22.0f)];
        [self.mobileValueLabel setTextColor:[UIColor darkGrayColor]];
        [self.mobileValueLabel setBackgroundColor:[UIColor whiteColor]];
        [self.mobileValueLabel setFont:[UIFont systemFontOfSize:12.0f]];
        
        [bgView addSubview:self.mobileValueLabel];

        
        // mobile check button
        _shareMobileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareMobileBtn setFrame:CGRectMake(xOffset+240.0f, yOffset, 60.0f, 22.0f)];
        [_shareMobileBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"공개", @"공개 여부")] forState:UIControlStateNormal];
        [_shareMobileBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_shareMobileBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [_shareMobileBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_shareMobileBtn setImage:[UIImage imageNamed:@"join_agreebox"] forState:UIControlStateNormal];
        [_shareMobileBtn setImage:[UIImage imageNamed:@"join_agreebox_ch"] forState:UIControlStateSelected];
        [_shareMobileBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_shareMobileBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        [_shareMobileBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_shareMobileBtn addTarget:self action:@selector(onSharedMobileBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [bgView addSubview:_shareMobileBtn];
        yOffset += 24.0f;

        
        // Tel text
        self.telLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 80.0f, 22.0f)];
        [self.telLabel setTextColor:[UIColor blackColor]];
        [self.telLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.telLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.telLabel setTextAlignment:NSTextAlignmentCenter];
        [self.telLabel setText:@"Tel."];
        
        [bgView addSubview:self.telLabel];
        self.telLabel.hidden = YES;
        
        
        // Tel value
        self.telTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 150.0f, 22.0f)];
        self.telTextField.delegate = self;
        [self.telTextField setTextColor:[UIColor darkGrayColor]];
        [self.telTextField setBackgroundColor:[UIColor whiteColor]];
        [self.telTextField setFont:[UIFont systemFontOfSize:12.0f]];
        [self.telTextField setReturnKeyType:UIReturnKeyDone];
        [self.telTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.telTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.telTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [bgView addSubview:self.telTextField];
        self.telTextField.hidden = YES;
//        yOffset = 24.0f;


        // Email text
        self.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 80.0f, 22.0f)];
        [self.emailLabel setTextColor:[UIColor blackColor]];
        [self.emailLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.emailLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.emailLabel setTextAlignment:NSTextAlignmentCenter];
        [self.emailLabel setText:@"Email"];
        
        [bgView addSubview:self.emailLabel];
        
        
        // Email value
        self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 150.0f, 22.0f)];
        self.emailTextField.delegate = self;
        [self.emailTextField setTextColor:[UIColor darkGrayColor]];
        [self.emailTextField setBackgroundColor:[UIColor whiteColor]];
        [self.emailTextField setFont:[UIFont systemFontOfSize:12.0f]];
        [self.emailTextField setReturnKeyType:UIReturnKeyDone];
        [self.emailTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.emailTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [bgView addSubview:self.emailTextField];
        
        
        // Email check button
        _shareEmailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareEmailBtn setFrame:CGRectMake(xOffset+240.0f, yOffset, 60.0f, 22.0f)];
        [_shareEmailBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"공개", @"공개 여부")] forState:UIControlStateNormal];
        [_shareEmailBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_shareEmailBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [_shareEmailBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_shareEmailBtn setImage:[UIImage imageNamed:@"join_agreebox"] forState:UIControlStateNormal];
        [_shareEmailBtn setImage:[UIImage imageNamed:@"join_agreebox_ch"] forState:UIControlStateSelected];
        [_shareEmailBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_shareEmailBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        [_shareEmailBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_shareEmailBtn addTarget:self action:@selector(onSharedEmailBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [bgView addSubview:_shareEmailBtn];
        yOffset += 24.0f;


        // 직장(국문) text
        self.officeKoLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 80.0f, 100.0f)];
        [self.officeKoLabel setTextColor:[UIColor blackColor]];
        [self.officeKoLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.officeKoLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.officeKoLabel setTextAlignment:NSTextAlignmentCenter];
        [self.officeKoLabel setNumberOfLines:2];
        [self.officeKoLabel setText:@"직장\n(국문)"];
        
        [bgView addSubview:self.officeKoLabel];
        yOffset += 2.0f;
        
        // 직장명 value
        self.workKoTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 160.0f, 18.0f)];
        self.workKoTextField.delegate = self;
        [self.workKoTextField setTextColor:[UIColor darkGrayColor]];
        [self.workKoTextField setBackgroundColor:[UIColor whiteColor]];
        [self.workKoTextField setFont:[UIFont systemFontOfSize:14.0f]];
        [self.workKoTextField setReturnKeyType:UIReturnKeyDone];
        [self.workKoTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.workKoTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.workKoTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [bgView addSubview:self.workKoTextField];
        yOffset += 24.0f;

        
        // 부서명 value
        self.departmentKoTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 160.0f, 18.0f)];
        self.departmentKoTextField.delegate = self;
        [self.departmentKoTextField setTextColor:[UIColor darkGrayColor]];
        [self.departmentKoTextField setBackgroundColor:[UIColor whiteColor]];
        [self.departmentKoTextField setFont:[UIFont systemFontOfSize:14.0f]];
        [self.departmentKoTextField setReturnKeyType:UIReturnKeyDone];
        [self.departmentKoTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.departmentKoTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.departmentKoTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [bgView addSubview:self.departmentKoTextField];
        yOffset += 24.0f;

        
        // 소속 value
        self.positionKoTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 160.0f, 18.0f)];
        self.positionKoTextField.delegate = self;
        [self.positionKoTextField setTextColor:[UIColor darkGrayColor]];
        [self.positionKoTextField setBackgroundColor:[UIColor whiteColor]];
        [self.positionKoTextField setFont:[UIFont systemFontOfSize:14.0f]];
        [self.positionKoTextField setReturnKeyType:UIReturnKeyDone];
        [self.positionKoTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.positionKoTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.positionKoTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [bgView addSubview:self.positionKoTextField];
        yOffset += 24.0f;
        
        
        // 직장 공개 check button
        _shareOfficeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareOfficeBtn setFrame:CGRectMake(xOffset + 85.0f, yOffset, 60.0f, 22.0f)];
        [_shareOfficeBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"공개", @"공개 여부")] forState:UIControlStateNormal];
        [_shareOfficeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_shareOfficeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [_shareOfficeBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_shareOfficeBtn setImage:[UIImage imageNamed:@"join_agreebox"] forState:UIControlStateNormal];
        [_shareOfficeBtn setImage:[UIImage imageNamed:@"join_agreebox_ch"] forState:UIControlStateSelected];
        [_shareOfficeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_shareOfficeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        [_shareOfficeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_shareOfficeBtn addTarget:self action:@selector(onSharedOfficeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [bgView addSubview:_shareOfficeBtn];
        yOffset += 28.0f;
        
        
        // 직장(영문) text
        self.officeEnLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 80.0f, 80.0f)];
        [self.officeEnLabel setTextColor:[UIColor blackColor]];
        [self.officeEnLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.officeEnLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.officeEnLabel setTextAlignment:NSTextAlignmentCenter];
        [self.officeEnLabel setNumberOfLines:2];
        [self.officeEnLabel setText:@"직장\n(영문)"];
        
        [bgView addSubview:self.officeEnLabel];
        yOffset += 2.0f;
        
        
        // 직장명 value
        self.workEnTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 160.0f, 18.0f)];
        self.workEnTextField.delegate = self;
        [self.workEnTextField setTextColor:[UIColor darkGrayColor]];
        [self.workEnTextField setBackgroundColor:[UIColor whiteColor]];
        [self.workEnTextField setFont:[UIFont systemFontOfSize:14.0f]];
        [self.workEnTextField setReturnKeyType:UIReturnKeyDone];
        [self.workEnTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.workEnTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.workEnTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [bgView addSubview:self.workEnTextField];
        yOffset += 24.0f;
        
        
        // 부서명 value
        self.departmentEnTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 160.0f, 18.0f)];
        self.departmentEnTextField.delegate = self;
        [self.departmentEnTextField setTextColor:[UIColor darkGrayColor]];
        [self.departmentEnTextField setBackgroundColor:[UIColor whiteColor]];
        [self.departmentEnTextField setFont:[UIFont systemFontOfSize:14.0f]];
        [self.departmentEnTextField setReturnKeyType:UIReturnKeyDone];
        [self.departmentEnTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.departmentEnTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.departmentEnTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [bgView addSubview:self.departmentEnTextField];
        yOffset += 24.0f;
        
        
        // 소속 value
        self.positionEnTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 160.0f, 18.0f)];
        self.positionEnTextField.delegate = self;
        [self.positionEnTextField setTextColor:[UIColor darkGrayColor]];
        [self.positionEnTextField setBackgroundColor:[UIColor whiteColor]];
        [self.positionEnTextField setFont:[UIFont systemFontOfSize:14.0f]];
        [self.positionEnTextField setReturnKeyType:UIReturnKeyDone];
        [self.positionEnTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.positionEnTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.positionEnTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [bgView addSubview:self.positionEnTextField];
        yOffset += 24.0f;
        
    }
    yOffset += 30.0f;
    
    
    // 기타설정 텍스트
    self.otherInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 60.0f, 16.0f)];
    [self.otherInfoLabel setTextColor:[UIColor blackColor]];
    [self.otherInfoLabel setBackgroundColor:[UIColor lightGrayColor]];
    [self.otherInfoLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.otherInfoLabel setTextAlignment:NSTextAlignmentLeft];
    [self.otherInfoLabel setText:@"기타정보"];
    
    [bgView addSubview:self.otherInfoLabel];
    yOffset += 18.0f;

    {
        // 로그인 text
        self.loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 80.0f, 22.0f)];
        [self.loginLabel setTextColor:[UIColor blackColor]];
        [self.loginLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.loginLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.loginLabel setTextAlignment:NSTextAlignmentCenter];
        [self.loginLabel setText:@"로그인"];
        
        [bgView addSubview:self.loginLabel];
        

        // 아이디 저장 check button
        _chIdSaveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chIdSaveBtn setFrame:CGRectMake(xOffset + 85.0f, yOffset, 100.0f, 22.0f)];
        [_chIdSaveBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"아이디 저장", @"아이디 저장")] forState:UIControlStateNormal];
        [_chIdSaveBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_chIdSaveBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [_chIdSaveBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_chIdSaveBtn setImage:[UIImage imageNamed:@"join_agreebox"] forState:UIControlStateNormal];
        [_chIdSaveBtn setImage:[UIImage imageNamed:@"join_agreebox_ch"] forState:UIControlStateSelected];
        [_chIdSaveBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_chIdSaveBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        [_chIdSaveBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_chIdSaveBtn addTarget:self action:@selector(onIdSavedBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [bgView addSubview:_chIdSaveBtn];
        
        
        // 자동 로그인 check button
        _chAutoLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chAutoLoginBtn setFrame:CGRectMake(xOffset + 185.0f, yOffset, 100.0f, 22.0f)];
        [_chAutoLoginBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"자동로그인", @"자동로그인")] forState:UIControlStateNormal];
        [_chAutoLoginBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_chAutoLoginBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [_chAutoLoginBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_chAutoLoginBtn setImage:[UIImage imageNamed:@"join_agreebox"] forState:UIControlStateNormal];
        [_chAutoLoginBtn setImage:[UIImage imageNamed:@"join_agreebox_ch"] forState:UIControlStateSelected];
        [_chAutoLoginBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_chAutoLoginBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        [_chAutoLoginBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_chAutoLoginBtn addTarget:self action:@selector(onAutoLoginBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [bgView addSubview:_chAutoLoginBtn];
        yOffset += 28.0f;
    }
    yOffset += 20.0f;

    // 저장 버튼
    _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_saveBtn setFrame:CGRectMake(xOffset + 185.0f, yOffset, 100.0f, 22.0f)];
    [_saveBtn setCenter:CGPointMake(viewFrame.size.width / 2, yOffset + 10)];
    [_saveBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"저장", @"저장")] forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [_saveBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_saveBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:14] forState:UIControlStateNormal];
    [_saveBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
//    [_saveBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_saveBtn addTarget:self action:@selector(onSaveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [bgView addSubview:_saveBtn];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    NSLog(@"Touched!");
    
    if ([touch view] == _profileImageView){
        NSLog(@"이미지 클릭");
//        [self ShowAbout];
    }
    //your UIImageView has been touched :)
    
    //event -> "A UIEvent object representing the event to which the touches belong."
    
    //touches -> "A set of UITouch instances in the event represented by event that    represent the touches in the UITouchPhaseEnded phase."
    
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    UIView *tappedView = [gesture.view hitTest:[gesture locationInView:gesture.view] withEvent:nil];
    NSLog(@"Touch event on view: %@", [tappedView class]);

    if (tappedView == _profileImageView){
        NSLog(@"이미지 클릭");
        [self onProfileImageClicked];
    }
}

#pragma mark - UI Control Events

// 프로필 사진 선택 시 (사진 찍기 메뉴 표시)
- (void)onProfileImageClicked
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:LocalizedString(@"Cancel", @"Cancel")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:LocalizedString(@"Take a Photo", @"Take a Photo"),
                                                                      LocalizedString(@"Photo of Library", @"Photo of Library"), nil];
    [actionSheet showInView:self.view];
    
}

- (void)onSharedMobileBtnClicked:(UIButton *)sender
{
    [sender setSelected:![sender isSelected]];
}

- (void)onSharedEmailBtnClicked:(UIButton *)sender
{
    [sender setSelected:![sender isSelected]];
}

- (void)onSharedOfficeBtnClicked:(UIButton *)sender
{
    [sender setSelected:![sender isSelected]];
}

- (void)onIdSavedBtnClicked:(UIButton *)sender
{
    [sender setSelected:![sender isSelected]];
}

- (void)onAutoLoginBtnClicked:(UIButton *)sender
{
    [sender setSelected:![sender isSelected]];
}

/// 프로필 저장 버튼
- (void)onSaveBtnClicked
{
    
}

#pragma mark - UIActionSheet delegates
// 프로필 사진 설정(사진 및 앨범) 메뉴
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (buttonIndex == 0)       // Camera
    {
        [self showCamera];
    }
    else if (buttonIndex == 1)  // Album
    {
        [self showPhotoAlbum];
    }
    
//    Camera *mera = [[Camera alloc] init];
//    
//    // 카메라
//    if ([UIImagePickerController isSourceTypeAvailable:
//         UIImagePickerControllerSourceTypeCamera]) {
//        
//        if (buttonIndex == 1) { // 사진찍기
//            [self startCameraControllerFromViewController:self usingDelegate:mera];
//        } else if (buttonIndex == 2) { // 사진 앨범에서 불러오기
//            [self startMediaBrowserFromViewController:self usingDelegate:mera];
//        }
//    } else {
//        if (buttonIndex == 1) { // 사진 앨범에서 불러오기
//            [self startMediaBrowserFromViewController:self usingDelegate:mera];
//        }
//    }
}


#pragma mark - Camera methods

/// 카메라 띄우기
- (void)showCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        return;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    picker.showsCameraControls = YES;
    picker.navigationBarHidden = YES;
//    camera.toolbarHidden = YES;
    picker.wantsFullScreenLayout = NO;
//    camera.cameraOverlayView = overlay;
    
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

/// 사진 앨범 띄우기
- (void)showPhotoAlbum
{
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary] == NO)) {
        UIAlertView *alert = [[UIAlertView alloc ] initWithTitle:@"안내"
                                                         message:@"본 장치는 사진 앨범를 지원하지 않습니다."
                                                        delegate:self
                                               cancelButtonTitle:@"확인"
                                               otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerController delegate
/// 사진 촬영 or 앨범에서 사진 선택 시
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"info : %@", info);
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    // Do something with the image
    
    if ([info objectForKey:UIImagePickerControllerEditedImage])
    {
        
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filename = @"user_profile.jpg";
//        UIImage *resizedImage = [SnapStyleCommon resizeImage:[info objectForKey:UIImagePickerControllerEditedImage] size:460.0f];
//        [[NSFileManager defaultManager] createFileAtPath:[cachesPath stringByAppendingPathComponent:filename] contents:UIImageJPEGRepresentation(resizedImage, 1.0f) attributes:nil];
    
//        _imageView.image = resizedImage;
    
//        [self uploadProfile:filename];
    }
    
}



#pragma mark - Assets

- (NSDictionary *)loadMyInfo
{
    return [[UserContext shared] profileInfo];
    
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
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    
//    path    /fb/myinfo
//    param   scode=5684825a51beb9d2fa05e4675d91253c&userid=ztest01&certno=m9kebjkakte1tvrqfg90i9fh84
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};
    NSLog(@"MyInfo Request Parameter : %@", param);
    
    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];

    // 내 (프로필)정보
    [[SMNetworkClient sharedClient] postMyInfo:param
                                         block:^(NSDictionary *result, NSError *error) {
                                             
                                             [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];

                                             if (error) {
                                                 [[SMNetworkClient sharedClient] showNetworkError:error];
                                             }
                                             else {
                                                 // 과정 기수 목록을 DB에 저장하고 tableView 업데이트
                                                 //NSArray *classes = [result valueForKeyPath:@"data"];
                                                 
                                                 // 로그인 결과 로컬(파일) 저장.
                                                 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:result];
                                                 NSLog(@"서버에서 가져온 내 정보 : %@", dict);
                                                 
                                                 [[UserContext shared] setProfileInfo:dict];
                                                 [[NSUserDefaults standardUserDefaults] setValue:dict forKey:@"profile"];
                                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                                 
                                                 // 로컬 저장 후, 메모리로 업데이트.
                                                 [_myInfo setDictionary:[dict mutableCopy]];
                                                 
                                                 
//                                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [self updateMyInfo];
//                                                      [self onDBUpdate:(NSDictionary *)result];
                                                  });
                                              }
                                          }];
}

/// myInfo 화면 업데이트
- (void)updateMyInfo
{
    if ([_myInfo count] == 0) {
        return;
    }
    
    NSLog(@"MY INFO : %@", _myInfo);
    
    _idValueLabel.text = _myInfo[@"id"];
    _nameValueLabel.text = _myInfo[@"name"];
    
//    [self.view setNeedsDisplay];
}

/// myInfo DB 추가 및 업데이트
//- (void)onDBUpdate:(NSDictionary *)myInfo
//{
//    // 컨텍스트 지정
//    if (self.managedObjectContext == nil) {
////        self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
////        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
//        return;
//    }
//    
//    NSError *error;
//    BOOL isSaved = NO;
//    
//    // DB에 없는 항목은 추가하기
////    for (NSDictionary *dict in classList)
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
