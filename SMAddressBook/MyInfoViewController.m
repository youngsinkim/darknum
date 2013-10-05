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
#import <UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import "MenuTableViewController.h"
#import "SMNetworkClient.h"

#define kScreenY    64.0f
#define kOFFSET_FOR_KEYBOARD 216.0f

@interface MyInfoViewController ()

@property (strong, nonatomic) NSMutableDictionary *myInfo;

@property (strong, nonatomic) UIScrollView *scrollView;         // 배경 스크롤 뷰

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
@property (strong, nonatomic) UILabel *telLabel;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextField *telTextField;

@property (strong, nonatomic) UIView *workBgView;
@property (strong, nonatomic) UITextField *companyKoTextField;      // 직장명
@property (strong, nonatomic) UITextField *companyEnTextField;
@property (strong, nonatomic) UITextField *departmentKoTextField;   // 부서명
@property (strong, nonatomic) UITextField *departmentEnTextField;
@property (strong, nonatomic) UITextField *titleKoTextField;        // 직위
@property (strong, nonatomic) UITextField *titleEnTextField;
@property (strong, nonatomic) UIButton *shareMobileBtn;
@property (strong, nonatomic) UIButton *shareEmailBtn;
@property (strong, nonatomic) UIButton *shareOfficeBtn;

@property (strong, nonatomic) UIView *otherBgView;
@property (strong, nonatomic) UILabel *otherInfoLabel;

@property (strong, nonatomic) UILabel *loginLabel;
@property (strong, nonatomic) UILabel *languageLabel;
@property (strong, nonatomic) UIButton *chIdSaveBtn;
@property (strong, nonatomic) UIButton *chAutoLoginBtn;
//@property (strong, nonatomic) UIButton *langKoBtn;
//@property (strong, nonatomic) UIButton *langEnBtn;

@property (strong, nonatomic) UIButton *saveBtn;

@property (assign) CGFloat focusY;
@property (assign) CGRect prevRect;

@property (strong, nonatomic) NSString *photoFilename;
@property (strong, nonatomic) NSData *photoData;

@property (assign) BOOL isScrollUp;
@property (assign) CGFloat bufferY;
@property (assign) CGFloat scrollY;
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
        _focusY = 0.0f;
        _photoFilename = @"";
        _photoData = [[NSData alloc] init];
        
        _isScrollUp = NO;
        _bufferY = 0.0f;
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
    

    
    // 로컬에서(DB) 데이터 가져오기
    [_myInfo setDictionary:[self loadMyInfo]];
    NSLog(@"로컬 저장된 내 정보 : %@", _myInfo);
    [self updateMyInfo];
    
    // 서버로 내 정보 요청
    [self requestAPIMyInfo];
    
    
    // 아이디 저장 여부
    if ([[UserContext shared] isSavedID]) {
        _chIdSaveBtn.selected = YES;
    } else {
        _chIdSaveBtn.selected = NO;
    }
    
    // 자동 로그인
//    [UserContext shared].userId     = [self.idTextField text];
    if ([[UserContext shared] isAutoLogin]) {
        _chAutoLoginBtn.selected = YES;
    } else {
        _chAutoLoginBtn.selected = NO;
    }


    // MARK: 프로필 유무 설정하여 최초 실행 이후에 프로필 화면으로 이동하지 않도록 처리.
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSetProfile];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [UserContext shared].isExistProfile = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 멤버 타입에 따른 컨트롤 표시 및 위치 조정
    CGRect viewFrame = self.view.bounds;
    CGFloat yOffset = 0.0f;
    CGRect frame;
    
    if (_memType != MemberTypeStudent)
    {
        _telLabel.hidden = NO;
        _telTextField.hidden = NO;
        
        _shareMobileBtn.hidden = YES;
        _shareEmailBtn.hidden = YES;
        _shareOfficeBtn.hidden = YES;
        _workBgView.hidden = YES;
        _saveBtn.hidden = YES;
        
        // tel label
        frame = _telLabel.frame;
        frame.origin.y += yOffset;
        _telLabel.frame = frame;
        
        // tel textField
        frame = _telTextField.frame;
        frame.origin.y += yOffset;
        _telTextField.frame = frame;
        yOffset += 24.0f;
        
        // email label
        frame = _emailLabel.frame;
        frame.origin.y += yOffset;
        _emailLabel.frame = frame;
        
        // email textField
        frame = _emailTextField.frame;
        frame.origin.y += yOffset;
        _emailTextField.frame = frame;
        yOffset += (24.0f + 30.0f);
        
        // other back view
        frame = _otherBgView.frame;
        frame.origin.y -= (_workBgView.frame.size.height - 30.0f);
        _otherBgView.frame = frame;
        
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appearKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disappearKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 내 정보 화면 구성
- (void)setupMyInfoUI
{
    CGRect viewFrame = self.view.frame;
    CGFloat yOffset = 0.0f;
    CGFloat bottomOffset = 0.0f;
    CGFloat scrolViewHeight = viewFrame.size.height;
    
    NSLog(@"Iphone %f ",[[UIScreen mainScreen] bounds].size.height);
    
    if (IS_LESS_THEN_IOS7) {
        scrolViewHeight -= 54.0f;
        bottomOffset = 60.0f;
    }
    else {
        scrolViewHeight -= 10.0f;
        bottomOffset = (-64.0f + 60.0f);
        
        if ([[UIScreen mainScreen] bounds].size.height < 568) {
            bottomOffset += 88.0f;
        }
    }
    
    // 배경 스크롤 뷰
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, yOffset, viewFrame.size.width, scrolViewHeight)];
    _scrollView.backgroundColor = [UIColor yellowColor];
    _scrollView.delegate = self;
    
    NSLog(@"스크롤 영역 높이 : %f", scrolViewHeight);
    _scrollView.contentSize = CGSizeMake(viewFrame.size.width, scrolViewHeight + bottomOffset);
//    if (_memType == MemberTypeStudent)
//    {
//        if (IS_LESS_THEN_IOS7) {
//            scrolViewHeight += 70.0f;
//            bottomOffset += 44.0f;
//        }
//        scrolViewHeight += 10.0f;
//        _scrollView.contentSize = CGSizeMake(viewFrame.size.width - 20.0f, scrolViewHeight);
//    }
//    else {
//        scrolViewHeight -= 64.0f;
//    }
    
    [self.view addSubview:_scrollView];
    
    
    // 배경 이미지 뷰
//    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, _scrollView.frame.size.width - 20.0f, scrolViewHeight - bottomOffset)];
//    UIView *bgView = [[UIView alloc] initWithFrame:self.scrollView.frame];
//    bgView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2f];
//    
//    [_scrollView addSubview:bgView];
    
    
    // 프로필 사진
    self.profileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder"]];
    self.profileImageView.frame = CGRectMake(0.0f, 5.0f, 120.0f, 120.0f);
    self.profileImageView.center = CGPointMake(viewFrame.size.width / 2, 65.0f);
    self.profileImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [_scrollView addSubview:self.profileImageView];

    // 이벤트 뷰
    {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        [self.view addGestureRecognizer:singleTap];
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
//    [self.personalInfoLabel setBackgroundColor:[UIColor lightGrayColor]];
    [self.personalInfoLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.personalInfoLabel setTextAlignment:NSTextAlignmentLeft];
    [self.personalInfoLabel setText:@"개인정보"];
    
    [_scrollView addSubview:self.personalInfoLabel];
    yOffset += 18.0f;
    
    {
        // 아이디 text
        self.idLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 80.0f, 18.0f)];
        [self.idLabel setTextColor:[UIColor blackColor]];
        [self.idLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.idLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.idLabel setTextAlignment:NSTextAlignmentCenter];
        [self.idLabel setText:@"아이디"];
        
        [_scrollView addSubview:self.idLabel];

        // 아이디 value
        self.idValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 200.0f, 18.0f)];
        [self.idValueLabel setTextColor:[UIColor darkGrayColor]];
        [self.idValueLabel setBackgroundColor:[UIColor whiteColor]];
        [self.idValueLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.idValueLabel setText:@"테스트 아이디"];
        
        [_scrollView addSubview:self.idValueLabel];
        yOffset += 22.0f;
        

        // 이름 text
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 80.0f, 18.0f)];
        [self.nameLabel setTextColor:[UIColor blackColor]];
        [self.nameLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.nameLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.nameLabel setText:@"이름"];
        
        [_scrollView addSubview:self.nameLabel];
        
        
        // 이름 value
        self.nameValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 200.0f, 18.0f)];
        [self.nameValueLabel setTextColor:[UIColor darkGrayColor]];
        [self.nameValueLabel setBackgroundColor:[UIColor whiteColor]];
        [self.nameValueLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.nameValueLabel setText:@"테스트 이름"];
        
        [_scrollView addSubview:self.nameValueLabel];
        yOffset += 22.0f;
        
        
        // Mobile text
        self.mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 80.0f, 22.0f)];
        [self.mobileLabel setTextColor:[UIColor blackColor]];
        [self.mobileLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.mobileLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.mobileLabel setTextAlignment:NSTextAlignmentCenter];
        [self.mobileLabel setText:@"Mobile"];
        
        [_scrollView addSubview:self.mobileLabel];
        
        
        // Mobile value
        self.mobileValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 150.0f, 22.0f)];
        [self.mobileValueLabel setTextColor:[UIColor darkGrayColor]];
        [self.mobileValueLabel setBackgroundColor:[UIColor whiteColor]];
        [self.mobileValueLabel setFont:[UIFont systemFontOfSize:12.0f]];
        
        [_scrollView addSubview:self.mobileValueLabel];

        
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
        
        [_scrollView addSubview:_shareMobileBtn];
        yOffset += 24.0f;

        
        // Tel text
        self.telLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 80.0f, 22.0f)];
        [self.telLabel setTextColor:[UIColor blackColor]];
        [self.telLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.telLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.telLabel setTextAlignment:NSTextAlignmentCenter];
        [self.telLabel setText:@"Tel."];
        
        [_scrollView addSubview:self.telLabel];
        self.telLabel.hidden = YES;
        
        
        // Tel value
        self.telTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 150.0f, 22.0f)];
        self.telTextField.delegate = self;
        [self.telTextField setTextColor:[UIColor darkGrayColor]];
        [self.telTextField setBackgroundColor:[UIColor whiteColor]];
        [self.telTextField setFont:[UIFont systemFontOfSize:12.0f]];
        [self.telTextField setReturnKeyType:UIReturnKeyDone];
        [self.telTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [self.telTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.telTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [_scrollView addSubview:self.telTextField];
        self.telTextField.hidden = YES;
//        yOffset = 24.0f;


        // Email text
        self.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 80.0f, 22.0f)];
        [self.emailLabel setTextColor:[UIColor blackColor]];
        [self.emailLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.emailLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.emailLabel setTextAlignment:NSTextAlignmentCenter];
        [self.emailLabel setText:@"Email"];
        
        [_scrollView addSubview:self.emailLabel];
        
        
        // Email value
        self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yOffset, 150.0f, 22.0f)];
        self.emailTextField.delegate = self;
        [self.emailTextField setTextColor:[UIColor darkGrayColor]];
        [self.emailTextField setBackgroundColor:[UIColor whiteColor]];
        [self.emailTextField setFont:[UIFont systemFontOfSize:12.0f]];
        [self.emailTextField setReturnKeyType:UIReturnKeyDone];
        [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
        [self.emailTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [_scrollView addSubview:self.emailTextField];
        
        
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
        
        [_scrollView addSubview:_shareEmailBtn];
        yOffset += 24.0f;


        _workBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, yOffset, viewFrame.size.width, 200.0f)];
//        _workBgView.backgroundColor = [UIColor yellowColor];
        
        [_scrollView addSubview:_workBgView];

        {
            CGFloat yyOffset = 0.0f;
            // 직장(국문) text
            self.officeKoLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yyOffset, 80.0f, 100.0f)];
            [self.officeKoLabel setTextColor:[UIColor blackColor]];
            [self.officeKoLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
            [self.officeKoLabel setFont:[UIFont systemFontOfSize:14.0f]];
            [self.officeKoLabel setTextAlignment:NSTextAlignmentCenter];
            [self.officeKoLabel setNumberOfLines:2];
            [self.officeKoLabel setText:@"직장\n(국문)"];
            
            [_workBgView addSubview:self.officeKoLabel];
            yyOffset += 2.0f;
            
            // 직장명 value
            self.companyKoTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yyOffset, 160.0f, 18.0f)];
            self.companyKoTextField.delegate = self;
            [self.companyKoTextField setTextColor:[UIColor darkGrayColor]];
            [self.companyKoTextField setBackgroundColor:[UIColor whiteColor]];
            [self.companyKoTextField setFont:[UIFont systemFontOfSize:14.0f]];
            [self.companyKoTextField setReturnKeyType:UIReturnKeyDone];
            [self.companyKoTextField setKeyboardType:UIKeyboardTypeDefault];
            [self.companyKoTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            self.companyKoTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            
            [_workBgView addSubview:self.companyKoTextField];
            yyOffset += 24.0f;

            
            // 부서명 value
            self.departmentKoTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yyOffset, 160.0f, 18.0f)];
            self.departmentKoTextField.delegate = self;
            [self.departmentKoTextField setTextColor:[UIColor darkGrayColor]];
            [self.departmentKoTextField setBackgroundColor:[UIColor whiteColor]];
            [self.departmentKoTextField setFont:[UIFont systemFontOfSize:14.0f]];
            [self.departmentKoTextField setReturnKeyType:UIReturnKeyDone];
            [self.departmentKoTextField setKeyboardType:UIKeyboardTypeDefault];
            [self.departmentKoTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            self.departmentKoTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            
            [_workBgView addSubview:self.departmentKoTextField];
            yyOffset += 24.0f;

            
            // 소속 value
            self.titleKoTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yyOffset, 160.0f, 18.0f)];
            self.titleKoTextField.delegate = self;
            [self.titleKoTextField setTextColor:[UIColor darkGrayColor]];
            [self.titleKoTextField setBackgroundColor:[UIColor whiteColor]];
            [self.titleKoTextField setFont:[UIFont systemFontOfSize:14.0f]];
            [self.titleKoTextField setReturnKeyType:UIReturnKeyDone];
            [self.titleKoTextField setKeyboardType:UIKeyboardTypeDefault];
            [self.titleKoTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            self.titleKoTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            
            [_workBgView addSubview:self.titleKoTextField];
            yyOffset += 24.0f;
            
            
            // 직장 공개 check button
            _shareOfficeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_shareOfficeBtn setFrame:CGRectMake(xOffset + 85.0f, yyOffset, 60.0f, 22.0f)];
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
            
            [_workBgView addSubview:_shareOfficeBtn];
            yyOffset += 28.0f;
            
            
            // 직장(영문) text
            self.officeEnLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yyOffset, 80.0f, 80.0f)];
            [self.officeEnLabel setTextColor:[UIColor blackColor]];
            [self.officeEnLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
            [self.officeEnLabel setFont:[UIFont systemFontOfSize:14.0f]];
            [self.officeEnLabel setTextAlignment:NSTextAlignmentCenter];
            [self.officeEnLabel setNumberOfLines:2];
            [self.officeEnLabel setText:@"직장\n(영문)"];
            
            [_workBgView addSubview:self.officeEnLabel];
            yyOffset += 2.0f;
            
            
            // 직장명 value
            self.companyEnTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yyOffset, 160.0f, 18.0f)];
            self.companyEnTextField.delegate = self;
            [self.companyEnTextField setTextColor:[UIColor darkGrayColor]];
            [self.companyEnTextField setBackgroundColor:[UIColor whiteColor]];
            [self.companyEnTextField setFont:[UIFont systemFontOfSize:14.0f]];
            [self.companyEnTextField setReturnKeyType:UIReturnKeyDone];
            [self.companyEnTextField setKeyboardType:UIKeyboardTypeDefault];
            [self.companyEnTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            self.companyEnTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            
            [_workBgView addSubview:self.companyEnTextField];
            yyOffset += 24.0f;
            
            
            // 부서명 value
            self.departmentEnTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yyOffset, 160.0f, 18.0f)];
            self.departmentEnTextField.delegate = self;
            [self.departmentEnTextField setTextColor:[UIColor darkGrayColor]];
            [self.departmentEnTextField setBackgroundColor:[UIColor whiteColor]];
            [self.departmentEnTextField setFont:[UIFont systemFontOfSize:14.0f]];
            [self.departmentEnTextField setReturnKeyType:UIReturnKeyDone];
            [self.departmentEnTextField setKeyboardType:UIKeyboardTypeDefault];
            [self.departmentEnTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            self.departmentEnTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            
            [_workBgView addSubview:self.departmentEnTextField];
            yyOffset += 24.0f;
            
            
            // 소속 value
            self.titleEnTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+85, yyOffset, 160.0f, 18.0f)];
            self.titleEnTextField.delegate = self;
            [self.titleEnTextField setTextColor:[UIColor darkGrayColor]];
            [self.titleEnTextField setBackgroundColor:[UIColor whiteColor]];
            [self.titleEnTextField setFont:[UIFont systemFontOfSize:14.0f]];
            [self.titleEnTextField setReturnKeyType:UIReturnKeyDone];
            [self.titleEnTextField setKeyboardType:UIKeyboardTypeDefault];
            [self.titleEnTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            self.titleEnTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            
            [_workBgView addSubview:self.titleEnTextField];
            yyOffset += 24.0f;
        }
        yOffset += 200.0f;
        
    }
    yOffset += 10.0f;
    
#if (1)
    // 기타설정 배경 뷰
    _otherBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, yOffset, viewFrame.size.width, 40.0f)];
//    _otherBgView.backgroundColor = [UIColor greenColor];
    
    [_scrollView addSubview:_otherBgView];
    
    {
        CGFloat yyOffset = 0.0f;
        // 기타설정 텍스트
        self.otherInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yyOffset, 60.0f, 16.0f)];
        [self.otherInfoLabel setTextColor:[UIColor blackColor]];
//        [self.otherInfoLabel setBackgroundColor:[UIColor lightGrayColor]];
        [self.otherInfoLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [self.otherInfoLabel setTextAlignment:NSTextAlignmentLeft];
        [self.otherInfoLabel setText:@"기타정보"];
        
        [_otherBgView addSubview:self.otherInfoLabel];
        yyOffset += 18.0f;

        {
            // 로그인 text
            self.loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yyOffset, 80.0f, 22.0f)];
            [self.loginLabel setTextColor:[UIColor blackColor]];
            [self.loginLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
            [self.loginLabel setFont:[UIFont systemFontOfSize:14.0f]];
            [self.loginLabel setTextAlignment:NSTextAlignmentCenter];
            [self.loginLabel setText:@"로그인"];
            
            [_otherBgView addSubview:self.loginLabel];
            

            // 아이디 저장 check button
            _chIdSaveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_chIdSaveBtn setFrame:CGRectMake(xOffset + 85.0f, yyOffset, 100.0f, 22.0f)];
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
            
            [_otherBgView addSubview:_chIdSaveBtn];
            
            
            // 자동 로그인 check button
            _chAutoLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_chAutoLoginBtn setFrame:CGRectMake(xOffset + 185.0f, yyOffset, 100.0f, 22.0f)];
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
            
            [_otherBgView addSubview:_chAutoLoginBtn];
        }
    }
#endif
    yOffset += 60.0f;

    // 저장 버튼
    _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_saveBtn setFrame:CGRectMake(xOffset + 185.0f, yOffset, 100.0f, 24.0f)];
    [_saveBtn setCenter:CGPointMake(viewFrame.size.width / 2, yOffset + 10)];
    [_saveBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"저장", @"저장")] forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [_saveBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_saveBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:14] forState:UIControlStateNormal];
    [_saveBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
//    [_saveBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_saveBtn addTarget:self action:@selector(onSaveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [_scrollView addSubview:_saveBtn];
    
}

/// 화면 클릭 이벤트
- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    UIView *tappedView = [gesture.view hitTest:[gesture locationInView:gesture.view] withEvent:nil];
    NSLog(@"Touch event on view: %@", [tappedView class]);

    [self.view endEditing:YES];// this will do the trick
//    [tappedView resignFirstResponder];

    if (tappedView == _profileImageView) {
        NSLog(@"이미지 클릭");
        [self onProfileImageClicked];
    }
}


#pragma mark - UITextField delegate
/// 리턴 키를 누를 때 실행
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // keyboard 감추기
	[textField resignFirstResponder];
    
//    if (textField == _idTextField) {
//        // 다음(비밀번호) 컨트롤 focus
//        [_pwdTextField becomeFirstResponder];
//    }
    
	return YES;
}

// textField 편집 모드 시작
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:_scrollView];
    pt = rc.origin;
    NSLog(@"텍스트 편집 시작 위치 : %f", pt.y);
    _focusY = pt.y;

//    CGRect viewFrame = self.view.bounds;
//
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:0.2];
//    _scrollView.frame = CGRectMake(10.0f, 0.0f, viewFrame.size.width - 20.0f, viewFrame.size.height - 216.0f);
//    [_scrollView scrollRectToVisible:textField.frame animated:YES];
//    [UIView commitAnimations];
}

/// textField 편집 모드 종료
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _focusY = 0.0f;
//    CGRect viewFrame = self.view.bounds;
//
////    [self autoCalculateDownPayment];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:0.2];
//    _scrollView.frame = CGRectMake(10.0f, 0.0f, viewFrame.size.width - 20.0f, viewFrame.size.height);
//    [UIView commitAnimations];
}

/// textField의 내용이 변경될 때 실행
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //    NSInteger length = [textField.text length] + string.length;
    //
    //    if (length > 20)
    //    {
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"long_name", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"okay", nil) otherButtonTitles:nil];
    //
    //        [alertView show];
    //
    //        return NO;
    //    }
    return YES;     // NO를 리턴할 경우 변경내용이 반영되지 않는다
}

/// textField의 내용이 삭제될 때 실행
// clearButtonMode 속성값이 UITextFieldViewModeNever가 아닌 경우에만 실행
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;    // NO를 리턴할 경우 변경내용이 반영되지 않는다.
}



#pragma mark - NSNotification selector
-(void)setViewMovedUp:(BOOL)movedUp scrollHeight:(CGFloat)scrollHeight
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2]; // if you want to slide up the view
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect rect = self.scrollView.frame;
//    CGFloat height = kOFFSET_FOR_KEYBOARD;
    CGFloat height = scrollHeight;

    if (movedUp)
    {
        rect.size.height += height;
        rect.origin.y -= height;
    }
    else
    {
        rect.size.height -= height;
        rect.origin.y += height;
        
        
    }
    self.scrollView.frame = rect;
    [UIView commitAnimations];
}

- (void)appearKeyboard:(NSNotification *)notification
{
    CGRect scrollRect = self.scrollView.frame;
    CGFloat yOffset = 44.0f;
//    CGFloat scollH =
    _scrollY = _scrollView.contentOffset.y;
//    if (!IS_LESS_THEN_IOS7) {
//        scollH += 64.0f;
//    }
    if (!IS_LESS_THEN_IOS7) {
        yOffset += 44.0f;
    }

    
    CGRect rect = CGRectZero;
    [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&rect];

    NSLog(@"포커싱 위치 : %f(%f), %f %f", _focusY, scrollRect.size.height, yOffset, rect.size.height);
    
    if ((scrollRect.size.height - yOffset - _focusY) < rect.size.height)
    {
        _isScrollUp = YES;
        
//        CGFloat scrollSize = (scrollRect.size.height - _focusY);
        _bufferY = rect.size.height - (scrollRect.size.height - yOffset - _focusY);
        NSLog(@"setviewMoveUp : %f", _bufferY);
        [self setViewMovedUp:YES scrollHeight:_bufferY];
//        [self.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 216.0f, 0)];
    }
    return;
//    _imageScrollView.scrollEnabled = NO;
//    
//    TextInputView *currentTextInputView = (TextInputView *)[_imageScrollView viewWithTag:300 + _selectedIndex];
//    currentTextInputView.canMove = NO;
//    
//    if (currentTextInputView.center.y > 160.0f) {
//        
//        CGRect rect = CGRectZero;
//        [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&rect];
//        
//        [UIView animateWithDuration:0.3f animations:^{
//            
//            _imageScrollView.transform = CGAffineTransformMakeTranslation(0.0f, 110.0f - currentTextInputView.center.y);
//            
//        }];
//    }
#if (0)
    CGRect viewFrame = self.view.bounds;
    CGRect rect = CGRectZero;
    
//    _scrollView.scrollEnabled = NO;
    [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&rect];
    
    CGFloat bottomOffset = rect.size.height;
    NSLog(@"포커싱 위치 : %f, %f", _focusY, viewFrame.size.height - bottomOffset - 64.0f - 20.0f);
    
    CGFloat sizeY = 64.0f;
    if (IS_LESS_THEN_IOS7) {
        sizeY += 44.0f;
    }
    
    if (_focusY > viewFrame.size.height - bottomOffset - sizeY - 20.0f)
    {
        CGSize keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 40, 0.0);
        NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        [UIView animateWithDuration:duration animations:^{

            _scrollView.contentInset = contentInsets;
            _scrollView.scrollIndicatorInsets = contentInsets;
            
            _scrollView.frame = CGRectMake(0.0f, 0.0f, viewFrame.size.width - 0.0f, viewFrame.size.height - bottomOffset);
            [_scrollView scrollRectToVisible:CGRectMake(0.0f, 0.0f, viewFrame.size.width, viewFrame.size.height - bottomOffset) animated:YES];
            NSLog(@"스크롤 %f, %f", keyboardSize.height, viewFrame.size.height - bottomOffset);
        }];
        
    }
#endif
}

- (void)disappearKeyboard:(NSNotification *)notification
{
//    CGRect scrollRect = self.scrollView.frame;
//    CGRect rect = CGRectZero;
//    [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&rect];
//    NSLog(@"포커싱 위치 : %f, %f", _focusY, rect.size.height);

    if (_isScrollUp == YES)
    {
        _isScrollUp = NO;
        
//        CGFloat scrollSize = rect.size.height - (scrollRect.size.height - _focusY);
        CGFloat scrollSize = _bufferY;
        NSLog(@"setviewMoveDown : %f", scrollSize);

        [self setViewMovedUp:NO scrollHeight:scrollSize];
        self.scrollView.contentOffset = CGPointMake(0.0f, _scrollY);
        [self.scrollView setNeedsLayout];
//        [self.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, -_scrollY, 0)];
    }
    return;
    
    CGRect viewFrame = self.view.bounds;
    CGFloat yOffset = 64.0f;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(yOffset, 0, 0, 0);
    NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{

        _scrollView.contentInset = contentInsets;
        _scrollView.scrollIndicatorInsets = contentInsets;

        _scrollView.frame = CGRectMake(0.0f, 0.0f, viewFrame.size.width - 0.0f, viewFrame.size.height);
//        _scrollView.scrollsToTop = YES;
    }];

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
    [_shareMobileBtn setSelected:![sender isSelected]];
}

- (void)onSharedEmailBtnClicked:(UIButton *)sender
{
    [_shareEmailBtn setSelected:![sender isSelected]];
}

- (void)onSharedOfficeBtnClicked:(UIButton *)sender
{
    [_shareOfficeBtn setSelected:![sender isSelected]];
}

- (void)onIdSavedBtnClicked:(UIButton *)sender
{
    [sender setSelected:![sender isSelected]];
    
//    BOOL isSavedId = [sender isSelected];
//    NSLog(@"아이디 저장? %d", isSavedId);
//    
//    [[NSUserDefaults standardUserDefaults] setBool:isSavedId forKey:kSavedId];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [UserContext shared].isSavedID = isSavedId;

}

- (void)onAutoLoginBtnClicked:(UIButton *)sender
{
    [sender setSelected:![sender isSelected]];
    
//    BOOL isAutoLogin = [sender isSelected];
//    NSLog(@"로그인 유지 ? %d", isAutoLogin);
//
//    if (isAutoLogin == YES) {
//        NSLog(@"아이디도 저장함");
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSavedId];
//        [UserContext shared].isSavedID = YES;
//        
//        _chIdSaveBtn.selected = YES;
//    }
//    
//    [[NSUserDefaults standardUserDefaults] setBool:isAutoLogin forKey:kAutoLogin];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [UserContext shared].isAutoLogin = isAutoLogin;
}

/// 프로필 저장 버튼
- (void)onSaveBtnClicked:(id)sender
{
    // 수정된 항목 즉 화면의 내용을 저장
//    [_profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _myInfo[@"photourl"]]]
//                      placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
//    _myInfo[@"id"] = _idValueLabel.text;
    _myInfo[@"mobile"] = _mobileValueLabel.text;
    _myInfo[@"email"] = _emailTextField.text;
    
    if (_memType == MemberTypeStudent)
    {
        _myInfo[@"company"] = _companyKoTextField.text;
        _myInfo[@"company_en"] = _companyEnTextField.text;
        _myInfo[@"department"] = _departmentKoTextField.text;
        _myInfo[@"department_en"] = _departmentEnTextField.text;
        _myInfo[@"title"] = _titleKoTextField.text;
        _myInfo[@"title_en"] = _titleEnTextField.text;
        
        if ([_shareEmailBtn isSelected]) {
            _myInfo[@"share_email"] = @"y";
        } else {
            _myInfo[@"share_email"] = @"n";
        }

        if ([_shareMobileBtn isSelected]) {
            _myInfo[@"share_mobile"] = @"y";
        } else {
            _myInfo[@"share_mobile"] = @"n";
        }

        if ([_shareOfficeBtn isSelected]) {
            _myInfo[@"share_company"] = @"y";
        } else {
            _myInfo[@"share_company"] = @"n";
        }
    }
    else
    {
        _myInfo[@"tel"] = _telTextField.text;
    }
    
    // 아이디 저장
    BOOL isSavedId = [_chIdSaveBtn isSelected];
    NSLog(@"아이디 저장? %d", isSavedId);
    
    [[NSUserDefaults standardUserDefaults] setBool:isSavedId forKey:kSavedId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [UserContext shared].isSavedID = isSavedId;

    // 로그인 유지
    BOOL isAutoLogin = [_chAutoLoginBtn isSelected];
    NSLog(@"로그인 유지 ? %d", isAutoLogin);
    
    if (isAutoLogin == YES) {
        NSLog(@"아이디도 저장함");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSavedId];
        [UserContext shared].isSavedID = YES;
        
        _chIdSaveBtn.selected = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:isAutoLogin forKey:kAutoLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [UserContext shared].isAutoLogin = isAutoLogin;

    
    // 변경된 프로필 서버로 저장
    [self requestAPIMyInfoUpdate];
    
//    [[UserContext shared] setProfileInfo:_myInfo];
//    [[NSUserDefaults standardUserDefaults] setObject:_myInfo forKey:kProfileInfo];
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSetProfile];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"변경 프로필 : %@", [[NSUserDefaults standardUserDefaults] objectForKey:kProfileInfo]);
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    _scrollY = scrollView.contentOffset.y;
    NSLog(@"스크롤된 영역 : %f", _scrollY);
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
    
//    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
//    if (image == nil) {
//        image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    }
    
    // Do something with the image
    if ([info objectForKey:UIImagePickerControllerEditedImage])
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        UIImage *resizedImage = [Util resizeImage:image size:400.0f];
        
        NSData *imageData = UIImageJPEGRepresentation(resizedImage, 1.0);

        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filename = @"photo.jpg";
        NSString *filePath = [cachesPath stringByAppendingPathComponent:filename];

        BOOL isCreated = [[NSFileManager defaultManager] createFileAtPath:filePath contents:imageData attributes:nil];

        if (isCreated)
        {
            // 프로필 화면 업데이트
            _profileImageView.image = resizedImage;
            
            // 서버로 올리기 위한 cache 저장
            _photoFilename = filename;
            _photoData = imageData;
            
            NSLog(@"이미지 저장 경로 : %@", _photoFilename);
        }
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


/// myInfo 화면 업데이트
- (void)updateMyInfo
{
    if ([_myInfo count] == 0) {
        return;
    }
    NSLog(@"MY INFO : %@", _myInfo);
    
    NSLog(@"photo : %@", [NSString stringWithFormat:@"%@", _myInfo[@"photourl"]]);
    [_profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _myInfo[@"photourl"]]]
                      placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    _idValueLabel.text = _myInfo[@"id"];
    _nameValueLabel.text = _myInfo[@"name"];
    _mobileValueLabel.text = _myInfo[@"mobile"];
    _emailTextField.text = _myInfo[@"email"];
    
    if (_memType == MemberTypeStudent)
    {
        _companyKoTextField.text = _myInfo[@"company"];
        _companyEnTextField.text = _myInfo[@"company_en"];
        _departmentKoTextField.text = _myInfo[@"department"];
        _departmentEnTextField.text = _myInfo[@"department_en"];
        _titleKoTextField.text = _myInfo[@"title"];
        _titleEnTextField.text = _myInfo[@"title_en"];
        
        if ([_myInfo[@"share_mobile"] isEqualToString:@"y"]) {
            _shareMobileBtn.selected = YES;
        } else {
            _shareMobileBtn.selected = NO;
        }
        
        if ([_myInfo[@"share_email"] isEqualToString:@"y"]) {
            _shareEmailBtn.selected = YES;
        } else {
            _shareEmailBtn.selected = NO;
        }
        
        if ([_myInfo[@"share_company"] isEqualToString:@"y"]) {
            _shareOfficeBtn.selected = YES;
        } else {
            _shareOfficeBtn.selected = NO;
        }
    }
    else
    {
        _telTextField.text = _myInfo[@"tel"];
    }
    
    // 업데이트된 내 정보 왼쪽 메뉴에도 적용
    //    MenuTableViewController *leftMenuViewController = (MenuTableViewController *)self.container.leftMenuViewController;
    //    [leftMenuViewController menuNavigationController:MenuViewTypeSettMyInfo withMenuInfo:nil];
    
    MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
    [menu updateHeaderInfo];
}


#pragma mark - Network API

// 내 정보 조회
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
                                             else
                                             {
                                                 // 과정 기수 목록을 DB에 저장하고 tableView 업데이트
                                                 //NSArray *classes = [result valueForKeyPath:@"data"];
                                                 
                                                 // 로그인 결과 로컬(파일) 저장.
//                                                 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:result];
                                                 [_myInfo setDictionary:result];
                                                 NSLog(@"서버에서 가져온 내 정보 : %@", _myInfo);
                                                 
                                                 [[UserContext shared] setProfileInfo:_myInfo];
                                                 [[NSUserDefaults standardUserDefaults] setObject:_myInfo forKey:kProfileInfo];
                                                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSetProfile];
                                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                                 NSLog(@"저장 후 프로필 : %@", [[NSUserDefaults standardUserDefaults] objectForKey:kProfileInfo]);
                                                 
                                                 // 로컬 저장 후, 메모리로 업데이트.
//                                                 [_myInfo setDictionary:[dict mutableCopy]];
                                                 
//                                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [self updateMyInfo];
//                                                      [self onDBUpdate:(NSDictionary *)result];
                                                  });
                                              }
                                          }];
}

/// 내 정보 업데이트
- (void)requestAPIMyInfoUpdate
{
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    NSString *lang = [UserContext shared].language;
    NSString *photoFileName = @"avatar.jpg";
//    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:photoFileName], 0.5);
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo,
                            @"lang":lang, @"email":_myInfo[@"email"],
                            @"company":_myInfo[@"company"], @"department":_myInfo[@"department"], @"title":_myInfo[@"title"],
                            @"company_en":_myInfo[@"company_en"], @"department_en":_myInfo[@"department_en"], @"title_en":_myInfo[@"title_en"],
//                            @"photo":photoFileName, @"photoData":imageData,
                            @"share_email":_myInfo[@"share_email"], @"share_mobile":_myInfo[@"share_mobile"], @"share_company":_myInfo[@"share_company"]};
    
//    NSLog(@"MyInfo Request Parameter : %@", param);
    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
    
    static NSString * const kAPIUpdateMyInfo = (SERVER_URL@"/fb/updatemyinfo");
    NSLog(@"API Path(%@) param :\n%@", kAPIUpdateMyInfo, param);
    
    NSMutableURLRequest *request =
    [[SMNetworkClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                              path:kAPIUpdateMyInfo
                                                        parameters:param
                                         constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                             if (_photoFilename.length > 0 && _photoData) {
                                                 [formData appendPartWithFileData:_photoData name:@"photo" fileName:_photoFilename mimeType:@"image/jpeg"];
                                             }
                                         }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];

        if (_photoData) {
            // 왼쪽 메뉴 사진 정보 업데이트
            MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
            
            UIImage *image = [[UIImage alloc] initWithData:_photoData];
            [menu updateHeaderImage:image];
        }
    }];
    
    [operation start];
    
}

@end
