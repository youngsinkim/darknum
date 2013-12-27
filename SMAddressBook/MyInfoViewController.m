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
#import "Faculty.h"
#import "Staff.h"
#import "Student.h"
#import "Course.h"
#import "Major.h"
#import "NSDate+Helper.h"
#import <AFNetworkActivityIndicatorManager.h>


#define kScreenY    64.0f
#define kOFFSET_FOR_KEYBOARD 216.0f

@interface MyInfoViewController ()

@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSMutableDictionary *myInfo;

@property (strong, nonatomic) UIScrollView *scrollView;         // 배경 스크롤 뷰

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UIImageView *cameraImage;

@property (strong, nonatomic) UILabel *personalInfoLabel;

@property (strong, nonatomic) UILabel *idLabel;
@property (strong, nonatomic) UILabel *nameLabel;

@property (strong, nonatomic) UIImageView *mobilebgView;
@property (strong, nonatomic) UILabel *mobileLabel;
@property (strong, nonatomic) UILabel *mobileValueLabel;

@property (strong, nonatomic) UILabel *emailLabel;
@property (strong, nonatomic) UIImageView *emailbgView;
@property (strong, nonatomic) UIImageView *emailIconView;
@property (strong, nonatomic) UITextField *emailTextField;

@property (strong, nonatomic) UILabel *telLabel;
@property (strong, nonatomic) UIImageView *telbgView;
@property (strong, nonatomic) UIImageView *telIconView;
@property (strong, nonatomic) UITextField *telTextField;

@property (strong, nonatomic) UILabel *officeKoLabel;
@property (strong, nonatomic) UILabel *officeEnLabel;

@property (strong, nonatomic) UILabel *idValueLabel;
@property (strong, nonatomic) UILabel *nameValueLabel;

@property (strong, nonatomic) UIImageView *workBgView;              // 소속정보 뷰
@property (strong, nonatomic) UITextField *companyKoTextField;      // 직장명
@property (strong, nonatomic) UITextField *companyEnTextField;
@property (strong, nonatomic) UITextField *departmentKoTextField;   // 부서명
@property (strong, nonatomic) UITextField *departmentEnTextField;
@property (strong, nonatomic) UITextField *titleKoTextField;        // 직위
@property (strong, nonatomic) UITextField *titleEnTextField;
@property (strong, nonatomic) UIButton *shareMobileBtn;
@property (strong, nonatomic) UIButton *shareEmailBtn;
@property (strong, nonatomic) UIButton *shareOfficeBtn;

@property (strong, nonatomic) UIButton *currentBtn;     // 현직
@property (strong, nonatomic) UIButton *noCurrentBtn;   // 전직

@property (strong, nonatomic) UIView *otherBgView;
@property (strong, nonatomic) UILabel *otherInfoLabel;

@property (strong, nonatomic) UILabel *loginLabel;
@property (strong, nonatomic) UILabel *languageLabel;
@property (strong, nonatomic) UIButton *chIdSaveBtn;
@property (strong, nonatomic) UIButton *chAutoLoginBtn;
//@property (strong, nonatomic) UIButton *langKoBtn;
//@property (strong, nonatomic) UIButton *langEnBtn;

@property (strong, nonatomic) UIView *bottomBgView;
@property (strong, nonatomic) UIButton *saveBtn;
@property (strong, nonatomic) UIButton *cancelBtn;

@property (assign) CGFloat focusY;
@property (assign) CGRect prevRect;

@property (strong, nonatomic) NSString *photoFilename;
@property (strong, nonatomic) NSData *photoData;

@property (assign) BOOL isScrollUp;
@property (assign) CGFloat bufferY;
@property (assign) CGFloat scrollY;

@property (strong, nonatomic) LoadingProgressView *progressView;    // 즐겨찾기 업데이트에 사용할 프로그래스바
@property (strong, nonatomic) NSTimer *progressTimer;
@property (assign) NSInteger tot;
@property (assign) NSInteger cur;

@end


@implementation MyInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = LocalizedString(@"My Page", @"내 정보 설정");
        
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
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (_moc == nil) {
        _moc = [appDelegate managedObjectContext];
        NSLog(@"After managedObjectContext: %@", _moc);
    }

//    if (!IS_LESS_THEN_IOS7) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.navigationController.navigationBar.translucent = NO;
//    }

    _memType = (MemberType)[[[UserContext shared] memberType] integerValue];
    NSLog(@"내 멤버 타입 : %d", _memType);
    
    _idValueLabel.text = [UserContext shared].userId;
    
    // 내 정보 화면 구성
    [self setupMyInfoUI];
    
    
    // 로컬에서(DB) 데이터 가져오기
//    [_myInfo setDictionary:[self loadMyInfo]];
//    NSLog(@"로컬 저장된 내 정보 : %@", _myInfo);
//    [self updateMyInfo];
    
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

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 멤버 타입에 따른 컨트롤 표시 및 위치 조정
//    CGRect viewFrame = self.view.bounds;
    CGFloat yOffset = 35.0f;
    CGRect frame;
    
    if ([UserContext shared].isExistProfile != YES) {
        // 최초 실행 시 (프로필 설정 전)
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
        
        if ([self.navigationController.viewControllers[0] isEqual:self]) {
            self.searchButton.enabled = NO;
        }

        // 최초 실행 시, 프로필 화면에서 즐겨찾기 업데이트 진행
//        [self setupFavoriteDB];
    } else {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.menuContainerViewController.panMode = MFSideMenuPanModeDefault;
    }

    if (_memType != MemberTypeStudent)
    {
        _telLabel.hidden = NO;
        _telbgView.hidden = NO;
        _telIconView.hidden = NO;
        _telTextField.hidden = NO;
        
        _shareMobileBtn.hidden = YES;
        _shareEmailBtn.hidden = YES;
        _shareOfficeBtn.hidden = YES;
        
        _personalInfoLabel.hidden = YES;    // 소속정보 text
        _workBgView.hidden = YES;           // 소속정보 area
//        _saveBtn.hidden = YES;
        
//        if (_workBgView.hidden == YES) {
//            [_saveBtn setCenter:CGPointMake(_bottomBgView.frame.size.width / 2, _bottomBgView.frame.size.height / 2)];
//        }
        
        // 전화 text
        frame = _telLabel.frame;
        frame.origin.y += yOffset;
        _telLabel.frame = frame;
        yOffset += 15.0f;
        
        // 전화 bg
        frame = _telbgView.frame;
        frame.origin.y += yOffset;
        _telbgView.frame = frame;
        
        // 전화 icon
        frame = _telIconView.frame;
        frame.origin.y += yOffset;
        _telIconView.frame = frame;
        
        // 전화 textField
        frame = _telTextField.frame;
        frame.origin.y += yOffset;
        _telTextField.frame = frame;
        yOffset -= 5.0f;
        
        // email label
        frame = _emailLabel.frame;
        frame.origin.y += yOffset;
        _emailLabel.frame = frame;

        // email bg
        frame = _emailbgView.frame;
        frame.origin.y += yOffset;
        _emailbgView.frame = frame;

        // email icon
        frame = _emailIconView.frame;
        frame.origin.y += yOffset;
        _emailIconView.frame = frame;

        // email textField
        frame = _emailTextField.frame;
        frame.origin.y += yOffset;
        _emailTextField.frame = frame;
        yOffset -= (_personalInfoLabel.frame.size.height + _workBgView.frame.size.height + 15.0f);

        // 기타설정 text
        frame = _otherInfoLabel.frame;
        frame.origin.y += yOffset;
        _otherInfoLabel.frame = frame;

        // other back view
        frame = _otherBgView.frame;
        frame.origin.y += yOffset;
        _otherBgView.frame = frame;
        
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appearKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disappearKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // MARK: 프로필 유무 설정하여 최초 실행 이후에 프로필 화면으로 이동하지 않도록 처리.
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSetProfile];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [UserContext shared].isExistProfile = YES;

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
    CGFloat yOffset = 15.0f;
    CGFloat xOffset = 15.0f;
    CGFloat bottomOffset = 0.0f;
    CGFloat scrolViewHeight = viewFrame.size.height;
    CGFloat bottomHeight = 50.0f;
    
    NSLog(@"Iphone %f ",[[UIScreen mainScreen] bounds].size.height);
    
    if (IS_LESS_THEN_IOS7) {
        if ([[UIScreen mainScreen] bounds].size.height < 568) {
            scrolViewHeight -= (44.0f + bottomHeight);
            bottomOffset += 288.0f;
        } else {    // iOS 6
            scrolViewHeight -= (44.0f + bottomHeight);
            bottomOffset += 200.0f;
        }
    }
    else {
//        bottomOffset = (-64.0f + 88.0f + 100.0f);
        
        if ([[UIScreen mainScreen] bounds].size.height < 568) {
            scrolViewHeight -= (64.0f + bottomHeight);
            bottomOffset += 288.0f;
        } else {
            scrolViewHeight -= (64.0f + bottomHeight);
            bottomOffset += 200.0f;
        }
    }
    
    if (_memType != MemberTypeStudent) {
        bottomOffset = 0.0f;
    }
    
    // 배경 스크롤 뷰
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, viewFrame.size.width, scrolViewHeight)];
    _scrollView.backgroundColor = UIColorFromRGB(0xf0f0f0);
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
    
    
    // 사진 테두리 배경
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yOffset, 124.0f, 124.0f)];
    bgView.backgroundColor = UIColorFromRGB(0x8b9ab5);

    [_scrollView addSubview:bgView];
    
    
    // 프로필 사진
    self.profileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_noimg_info"]];
    self.profileImageView.frame = CGRectMake(xOffset + 2.0f, yOffset + 2.0f, 120.0f, 120.0f);
//    self.profileImageView.center = CGPointMake(viewFrame.size.width / 2, 65.0f);
    self.profileImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [_scrollView addSubview:self.profileImageView];

    
    // 사진 icon
    UIImageView *cameraImage = [[UIImageView alloc] initWithFrame:CGRectMake(bgView.frame.origin.x + bgView.frame.size.width - 6.0f - 15.0f, bgView.frame.origin.y + bgView.frame.size.height - 6.0f - 13.0f, 15.0f, 13.0f)];
    cameraImage.image = [UIImage imageNamed:@"ic_photo"];
    
    [_scrollView addSubview:cameraImage];

    
    // 이벤트 뷰
    {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        [self.view addGestureRecognizer:singleTap];

//        [scrollView setMultipleTouchEnabled:YES];
//        [bgView setUserInteractionEnabled:YES];
//        [self.view addSubview:scrollView];
//        self.view.userInteractionEnabled=YES;
    }
    
    
    // 이름 value
    self.nameValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(bgView.frame.origin.x + bgView.frame.size.width + 15.0f, yOffset + 15.0f, 150.0f, 18.0f)];
    [self.nameValueLabel setTextColor:UIColorFromRGB(0x142c6d)];
    [self.nameValueLabel setBackgroundColor:[UIColor clearColor]];
    [self.nameValueLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    
    [_scrollView addSubview:self.nameValueLabel];
    
    
    // 아이디 value
    self.idValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameValueLabel.frame.origin.x, yOffset + 15.0f + self.nameValueLabel.frame.size.height + 5.0f, self.nameValueLabel.frame.size.width, 14.0f)];
    [self.idValueLabel setTextColor:UIColorFromRGB(0x333333)];
    [self.idValueLabel setBackgroundColor:[UIColor clearColor]];
    [self.idValueLabel setFont:[UIFont systemFontOfSize:12.0f]];
    
    [_scrollView addSubview:self.idValueLabel];
    yOffset += (bgView.frame.size.height + 15.0f);


    // Mobile text
    self.mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, viewFrame.size.width - (xOffset * 2.0f), 13.0f)];
    [self.mobileLabel setTextColor:UIColorFromRGB(0x353d48)];
    [self.mobileLabel setBackgroundColor:[UIColor clearColor]];
    [self.mobileLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [self.mobileLabel setText:LocalizedString(@"Mobile Phone", @"전화")];
    
    [_scrollView addSubview:self.mobileLabel];
    yOffset += (self.mobileLabel.frame.size.height + 3.0f);
    
    
    // 모바일 background
    _mobilebgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"t_field"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f]];
    _mobilebgView.frame = CGRectMake(xOffset, yOffset, viewFrame.size.width - (xOffset * 2.0f), 30.0f);
    [_scrollView addSubview:_mobilebgView];
    
    
    // 모바일 icon
    UIImageView *mobileIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_view_mphone"]];
    mobileIconView.frame = CGRectMake(xOffset + 8.0f, yOffset + 8.0f, 14.0f, 14.0f);
    [_scrollView addSubview:mobileIconView];
    

    // 모바일 value
    self.mobileValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset + 8.0f + mobileIconView.frame.size.width + 12.0f, yOffset, 180.0f, 30.0f)];
    [self.mobileValueLabel setTextColor:UIColorFromRGB(0x555555)];
    [self.mobileValueLabel setBackgroundColor:[UIColor clearColor]];
    [self.mobileValueLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    [_scrollView addSubview:self.mobileValueLabel];
    
    
    // 전화 공개 체크버튼
    _shareMobileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareMobileBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"Disclosure", @"공개 여부")] forState:UIControlStateNormal];
    [_shareMobileBtn setFrame:CGRectMake(viewFrame.size.width - xOffset - 72.0f - 6.0f, yOffset, 72.0f, 29.0f)];
    [_shareMobileBtn.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_shareMobileBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    [_shareMobileBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateHighlighted];
    [_shareMobileBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [_shareMobileBtn setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateSelected];
    [_shareMobileBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_shareMobileBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 2)];
    [_shareMobileBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [_shareMobileBtn addTarget:self action:@selector(onSharedMobileBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [_scrollView addSubview:_shareMobileBtn];
    {
        // 전화 text
        _telLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, viewFrame.size.width - (xOffset * 2.0f), 13.0f)];
        [_telLabel setTextColor:UIColorFromRGB(0x353d48)];
        [_telLabel setBackgroundColor:[UIColor clearColor]];
        [_telLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [_telLabel setText:LocalizedString(@"Tel", @"Tel")];
        
        [_scrollView addSubview:_telLabel];
//        yOffset += (self.telLabel.frame.size.height + 3.0f);
        _telLabel.hidden = YES;
        
        // 메일 background
        self.telbgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"t_field"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f]];
        self.telbgView.frame = CGRectMake(xOffset, yOffset, viewFrame.size.width - (xOffset * 2.0f), 30.0f);
        [_scrollView addSubview:self.telbgView];
        self.telbgView.hidden = YES;
        
        
        // 메일 icon
        self.telIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_view_email"]];
        self.telIconView.frame = CGRectMake(xOffset + 8.0f, yOffset + 8.0f, 14.0f, 14.0f);
        [_scrollView addSubview:self.telIconView];
        self.telIconView.hidden = YES;

        // 전화 value
        self.telTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset + 8.0f + mobileIconView.frame.size.width + 12.0f, yOffset, 180.0f, 30.0f)];
        self.telTextField.delegate = self;
        [self.telTextField setTextColor:UIColorFromRGB(0x555555)];
        [self.telTextField setBackgroundColor:[UIColor clearColor]];
        [self.telTextField setFont:[UIFont systemFontOfSize:14.0f]];
        [self.telTextField setReturnKeyType:UIReturnKeyDone];
        [self.telTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [self.telTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.telTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [_scrollView addSubview:self.telTextField];
//        yOffset += (self.telTextField.frame.size.height + 10.0f);
        self.telTextField.hidden = YES;
    }
    yOffset += (_shareMobileBtn.frame.size.height + 10.0f);

    // Email text
    self.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, viewFrame.size.width - (xOffset * 2.0f), 13.0f)];
    [self.emailLabel setTextColor:UIColorFromRGB(0x353d48)];
    [self.emailLabel setBackgroundColor:[UIColor clearColor]];
    [self.emailLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [self.emailLabel setTextAlignment:NSTextAlignmentLeft];
    [self.emailLabel setText:LocalizedString(@"E-Mail", @"메일")];
    
    [_scrollView addSubview:self.emailLabel];
    yOffset += (self.emailLabel.frame.size.height + 3.0f);


    // 메일 background
    _emailbgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"t_field"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f]];
    _emailbgView.frame = CGRectMake(xOffset, yOffset, viewFrame.size.width - (xOffset * 2.0f), 30.0f);
    [_scrollView addSubview:_emailbgView];
    
    
    // 메일 icon
    _emailIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_view_email"]];
    _emailIconView.frame = CGRectMake(xOffset + 8.0f, yOffset + 8.0f, 14.0f, 14.0f);
    [_scrollView addSubview:_emailIconView];
    

    // 메일 value
    self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset + 8.0f + mobileIconView.frame.size.width + 12.0f, yOffset, 180.0f, 30.0f)];
    self.emailTextField.delegate = self;
    [self.emailTextField setTextColor:UIColorFromRGB(0x555555)];
    [self.emailTextField setBackgroundColor:[UIColor clearColor]];
    [self.emailTextField setFont:[UIFont systemFontOfSize:14.0f]];
    [self.emailTextField setReturnKeyType:UIReturnKeyDone];
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.emailTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [_scrollView addSubview:self.emailTextField];
    
    
    // Email check button
    _shareEmailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareEmailBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"Disclosure", @"공개 여부")] forState:UIControlStateNormal];
    [_shareEmailBtn setFrame:CGRectMake(viewFrame.size.width - xOffset - 72.0f - 6.0f, yOffset, 72.0f, 29.0f)];
    [_shareEmailBtn.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_shareEmailBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    [_shareEmailBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateHighlighted];
    [_shareEmailBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [_shareEmailBtn setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateSelected];
    [_shareEmailBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_shareEmailBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 2)];
    [_shareEmailBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
//    [_shareEmailBtn setBackgroundColor:[UIColor grayColor]];
    [_shareEmailBtn addTarget:self action:@selector(onSharedEmailBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [_scrollView addSubview:_shareEmailBtn];
    yOffset += (_shareEmailBtn.frame.size.height + 10.0f);
    

    // 개인정보 텍스트
    self.personalInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, viewFrame.size.width - (xOffset * 2.0f), 13.0f)];
    [self.personalInfoLabel setTextColor:UIColorFromRGB(0x353d48)];
    [self.personalInfoLabel setBackgroundColor:[UIColor clearColor]];
    [self.personalInfoLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [self.personalInfoLabel setTextAlignment:NSTextAlignmentLeft];
    [self.personalInfoLabel setText:LocalizedString(@"Personal information", @"소속 정보")];
    
    [_scrollView addSubview:self.personalInfoLabel];
    yOffset += (self.personalInfoLabel.frame.size.height + 3.0f);
    
    // 소속정보 배경 image
    _workBgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"t_field"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    _workBgView.frame = CGRectMake(xOffset, yOffset, viewFrame.size.width - (xOffset * 2), 286.0f);
    _workBgView.userInteractionEnabled = YES;
    
    [_scrollView addSubview:_workBgView];
    
    {
        CGFloat xOffset1 = 5.0f;
        CGFloat yOffset1 = 10.0f;
        CGFloat labelWidth = 64.0f;
        CGFloat valueWidth = 215.0f;
        
        // 국문 text
        self.officeKoLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset1, yOffset1, _workBgView.frame.size.width - (xOffset * 2), 12.0f)];
        [self.officeKoLabel setTextColor:UIColorFromRGB(0x142c6d)];
        [self.officeKoLabel setBackgroundColor:[UIColor clearColor]];
        [self.officeKoLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
        [self.officeKoLabel setText:LocalizedString(@"Company Korean", @"Company Korean")];
        
        [_workBgView addSubview:self.officeKoLabel];
        yOffset1 += (self.officeKoLabel.frame.size.height + 5.0f);
        
        
        // Company text
        UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset1, yOffset1, labelWidth, 24.0f)];
        [companyLabel setTextColor:UIColorFromRGB(0x555555)];
        [companyLabel setBackgroundColor:[UIColor clearColor]];
        [companyLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [companyLabel setText:LocalizedString(@"Company", @"직장명")];
        
        [_workBgView addSubview:companyLabel];
        
        
        // Company value
        self.companyKoTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset1 + labelWidth, yOffset1, valueWidth, 24.0f)];
        self.companyKoTextField.delegate = self;
        [self.companyKoTextField setTextColor:UIColorFromRGB(0x333333)];
        [self.companyKoTextField setBackgroundColor:[UIColor clearColor]];
        [self.companyKoTextField setFont:[UIFont systemFontOfSize:12.0f]];
        [self.companyKoTextField setReturnKeyType:UIReturnKeyDone];
        [self.companyKoTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.companyKoTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.companyKoTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [_workBgView addSubview:self.companyKoTextField];
        yOffset1 += self.companyKoTextField.frame.size.height;
        
        
        // 라인
        UIView *companyLine = [[UIView alloc] initWithFrame:CGRectMake(self.companyKoTextField.frame.origin.x - 5.0f, yOffset1, self.companyKoTextField.frame.size.width + 5.0f, 1.0f)];
        companyLine.backgroundColor = UIColorFromRGB(0xcccccc);
        
        [_workBgView addSubview:companyLine];
        yOffset1 += (companyLine.frame.size.height + 8.0f);

        
        // Department text
        UILabel *dptLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset1, yOffset1, labelWidth, 24.0f)];
        [dptLabel setTextColor:UIColorFromRGB(0x555555)];
        [dptLabel setBackgroundColor:[UIColor clearColor]];
        [dptLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [dptLabel setText:LocalizedString(@"Department", @"부서명")];
        
        [_workBgView addSubview:dptLabel];

        
        // 부서명 value
        self.departmentKoTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset1 + labelWidth, yOffset1, valueWidth, 24.0f)];
        self.departmentKoTextField.delegate = self;
        [self.departmentKoTextField setTextColor:UIColorFromRGB(0x333333)];
        [self.departmentKoTextField setBackgroundColor:[UIColor clearColor]];
        [self.departmentKoTextField setFont:[UIFont systemFontOfSize:12.0f]];
        [self.departmentKoTextField setReturnKeyType:UIReturnKeyDone];
        [self.departmentKoTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.departmentKoTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.departmentKoTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [_workBgView addSubview:self.departmentKoTextField];
        yOffset1 += self.departmentKoTextField.frame.size.height;
        
        
        // 라인
        UIView *dptLine = [[UIView alloc] initWithFrame:CGRectMake(self.departmentKoTextField.frame.origin.x - 5.0f, yOffset1, self.departmentKoTextField.frame.size.width + 5.0f, 1.0f)];
        dptLine.backgroundColor = UIColorFromRGB(0xcccccc);
        
        [_workBgView addSubview:dptLine];
        yOffset1 += (dptLine.frame.size.height + 8.0f);

        
        // title text
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset1, yOffset1, labelWidth, 24.0f)];
        [titleLabel setTextColor:UIColorFromRGB(0x555555)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [titleLabel setText:LocalizedString(@"Title", @"직위")];
        
        [_workBgView addSubview:titleLabel];

        
        // 소속 value
        self.titleKoTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset1 + labelWidth, yOffset1, valueWidth, 24.0f)];
        self.titleKoTextField.delegate = self;
        [self.titleKoTextField setTextColor:UIColorFromRGB(0x333333)];
        [self.titleKoTextField setBackgroundColor:[UIColor clearColor]];
        [self.titleKoTextField setFont:[UIFont systemFontOfSize:12.0f]];
        [self.titleKoTextField setReturnKeyType:UIReturnKeyDone];
        [self.titleKoTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.titleKoTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.titleKoTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [_workBgView addSubview:self.titleKoTextField];
        yOffset1 += self.titleKoTextField.frame.size.height;
        
        
        // 라인
        UIView *titleLine = [[UIView alloc] initWithFrame:CGRectMake(self.titleKoTextField.frame.origin.x - 5.0f, yOffset1, self.titleKoTextField.frame.size.width + 5.0f, 1.0f)];
        titleLine.backgroundColor = UIColorFromRGB(0xcccccc);
        
        [_workBgView addSubview:titleLine];
        yOffset1 += (titleLine.frame.size.height + 15.0f);

        
        // 영문 text
        self.officeEnLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset1, yOffset1, _workBgView.frame.size.width - (xOffset * 2), 12.0f)];
        [self.officeEnLabel setTextColor:UIColorFromRGB(0x142c6d)];
        [self.officeEnLabel setBackgroundColor:[UIColor clearColor]];
        [self.officeEnLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self.officeEnLabel setText:LocalizedString(@"Company English", @"Company English")];
        
        [_workBgView addSubview:self.officeEnLabel];
        yOffset1 += (self.officeKoLabel.frame.size.height + 5.0f);
        
        
        // Company text
        UILabel *companyEnLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset1, yOffset1, labelWidth, 24.0f)];
        [companyEnLabel setTextColor:UIColorFromRGB(0x555555)];
        [companyEnLabel setBackgroundColor:[UIColor clearColor]];
        [companyEnLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [companyEnLabel setText:LocalizedString(@"Company", @"직장명")];
        
        [_workBgView addSubview:companyEnLabel];

        
        // 직장명 value
        self.companyEnTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset1 + labelWidth, yOffset1, valueWidth, 24.0f)];
        self.companyEnTextField.delegate = self;
        [self.companyEnTextField setTextColor:UIColorFromRGB(0x333333)];
        [self.companyEnTextField setBackgroundColor:[UIColor clearColor]];
        [self.companyEnTextField setFont:[UIFont systemFontOfSize:12.0f]];
        [self.companyEnTextField setReturnKeyType:UIReturnKeyDone];
        [self.companyEnTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.companyEnTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.companyEnTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [_workBgView addSubview:self.companyEnTextField];
        yOffset1 += self.companyEnTextField.frame.size.height;

        
        // 라인
        UIView *companyEnLine = [[UIView alloc] initWithFrame:CGRectMake(self.companyEnTextField.frame.origin.x - 5.0f, yOffset1, self.companyEnTextField.frame.size.width + 5.0f, 1.0f)];
        companyEnLine.backgroundColor = UIColorFromRGB(0xcccccc);
        
        [_workBgView addSubview:companyEnLine];
        yOffset1 += (companyEnLine.frame.size.height + 8.0f);

        
        // 부서명 text
        UILabel *dptEnLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset1, yOffset1, labelWidth, 24.0f)];
        [dptEnLabel setTextColor:UIColorFromRGB(0x555555)];
        [dptEnLabel setBackgroundColor:[UIColor clearColor]];
        [dptEnLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [dptEnLabel setText:LocalizedString(@"Department", @"부서명")];
        
        [_workBgView addSubview:dptEnLabel];

        
        // 부서명 value
        self.departmentEnTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset1 + labelWidth, yOffset1, valueWidth, 24.0f)];
        self.departmentEnTextField.delegate = self;
        [self.departmentEnTextField setTextColor:UIColorFromRGB(0x333333)];
        [self.departmentEnTextField setBackgroundColor:[UIColor clearColor]];
        [self.departmentEnTextField setFont:[UIFont systemFontOfSize:12.0f]];
        [self.departmentEnTextField setReturnKeyType:UIReturnKeyDone];
        [self.departmentEnTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.departmentEnTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.departmentEnTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [_workBgView addSubview:self.departmentEnTextField];
        yOffset1 += self.departmentEnTextField.frame.size.height;
        
        
        // 라인
        UIView *dptEnLine = [[UIView alloc] initWithFrame:CGRectMake(self.departmentEnTextField.frame.origin.x - 5.0f, yOffset1, self.departmentEnTextField.frame.size.width + 5.0f, 1.0f)];
        dptEnLine.backgroundColor = UIColorFromRGB(0xcccccc);
        
        [_workBgView addSubview:dptEnLine];
        yOffset1 += (dptEnLine.frame.size.height + 8.0f);

        
        // 직위 text
        UILabel *titleEnLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset1, yOffset1, labelWidth, 24.0f)];
        [titleEnLabel setTextColor:UIColorFromRGB(0x555555)];
        [titleEnLabel setBackgroundColor:[UIColor clearColor]];
        [titleEnLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [titleEnLabel setText:LocalizedString(@"Title", @"소속")];
        
        [_workBgView addSubview:titleEnLabel];

        
        // 직위 value
        self.titleEnTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset1 + labelWidth, yOffset1, valueWidth, 24.0f)];
        self.titleEnTextField.delegate = self;
        [self.titleEnTextField setTextColor:UIColorFromRGB(0x333333)];
        [self.titleEnTextField setBackgroundColor:[UIColor clearColor]];
        [self.titleEnTextField setFont:[UIFont systemFontOfSize:12.0f]];
        [self.titleEnTextField setReturnKeyType:UIReturnKeyDone];
        [self.titleEnTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.titleEnTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.titleEnTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [_workBgView addSubview:self.titleEnTextField];
        yOffset1 += self.titleEnTextField.frame.size.height;

        
        // 라인
        UIView *titleEnLine = [[UIView alloc] initWithFrame:CGRectMake(self.titleEnTextField.frame.origin.x - 5.0f, yOffset1, self.titleEnTextField.frame.size.width + 5.0f, 1.0f)];
        titleEnLine.backgroundColor = UIColorFromRGB(0xcccccc);
        
        [_workBgView addSubview:titleEnLine];
        yOffset1 += (titleEnLine.frame.size.height + 8.0f);
        
        
        // 설정 text
        UILabel *optionLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset1, yOffset1, labelWidth, 24.0f)];
        [optionLabel setTextColor:UIColorFromRGB(0x142c6d)];
        [optionLabel setBackgroundColor:[UIColor clearColor]];
        [optionLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
        [optionLabel setText:LocalizedString(@"setting_title", @"설정")];
        
        [_workBgView addSubview:optionLabel];

        
        // 전직 check
        _noCurrentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_noCurrentBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"not currented", @"전직")] forState:UIControlStateNormal];
        [_noCurrentBtn setFrame:CGRectMake(xOffset1 + labelWidth, yOffset1, 70.0f, 24.0f)];
        [_noCurrentBtn.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [_noCurrentBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        [_noCurrentBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateHighlighted];
        [_noCurrentBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
        [_noCurrentBtn setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateSelected];
        [_noCurrentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_noCurrentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 2)];
        [_noCurrentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
        [_noCurrentBtn addTarget:self action:@selector(onNotCurrentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_workBgView addSubview:_noCurrentBtn];

        
        // 현직 check
        _currentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_currentBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"currented", @"현직")] forState:UIControlStateNormal];
        [_currentBtn setFrame:CGRectMake(_noCurrentBtn.frame.origin.x + 70.0f, yOffset1, 70.0f, 24.0f)];
        [_currentBtn.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [_currentBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        [_currentBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateHighlighted];
        [_currentBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
        [_currentBtn setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateSelected];
        [_currentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_currentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 2)];
        [_currentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
        [_currentBtn addTarget:self action:@selector(onCurrentedBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_workBgView addSubview:_currentBtn];

        
        // 공개 check button
        _shareOfficeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareOfficeBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"Disclosure", @"공개")] forState:UIControlStateNormal];
        [_shareOfficeBtn setFrame:CGRectMake(_workBgView.frame.size.width - 10.0f - 72.0f, yOffset1, 72.0f, 24.0f)];
        [_shareOfficeBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        [_shareOfficeBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateHighlighted];
        [_shareOfficeBtn.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [_shareOfficeBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
        [_shareOfficeBtn setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateSelected];
        [_shareOfficeBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_shareOfficeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_shareOfficeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 2)];
        [_shareOfficeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
        [_shareOfficeBtn addTarget:self action:@selector(onSharedOfficeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_workBgView addSubview:_shareOfficeBtn];
        yOffset1 += _shareOfficeBtn.frame.size.height;
        
        // 라인
        UIView *optEnLine = [[UIView alloc] initWithFrame:CGRectMake(self.noCurrentBtn.frame.origin.x - 5.0f, yOffset1, valueWidth + 5.0f, 1.0f)];
        optEnLine.backgroundColor = UIColorFromRGB(0xcccccc);
        
        [_workBgView addSubview:optEnLine];

    }
    yOffset += (_workBgView.frame.size.height + 10.0f);
    
    
    // 기타설정 text
    _otherInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, viewFrame.size.width - (xOffset * 2.0f), 13.0f)];
    [_otherInfoLabel setTextColor:UIColorFromRGB(0x353d48)];
    [_otherInfoLabel setBackgroundColor:[UIColor clearColor]];
    [_otherInfoLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [_otherInfoLabel setTextAlignment:NSTextAlignmentLeft];
    [_otherInfoLabel setText:LocalizedString(@"Other setup", @"기타 설정")];
    
    [_scrollView addSubview:_otherInfoLabel];
    yOffset += (_otherInfoLabel.frame.size.height + 3.0f);
    
    
    // 기타설정 배경 image
    _otherBgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"t_field"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    _otherBgView.frame = CGRectMake(xOffset, yOffset, viewFrame.size.width - (xOffset * 2.0f), 34.0f);
    _otherBgView.userInteractionEnabled = YES;
    
    [_scrollView addSubview:_otherBgView];

    {
        CGFloat xOffset1 = 5.0f;
        CGFloat yOffset1 = 5.0f;
        CGFloat labelWidth = 60.0f;
//        CGFloat valueWidth = 215.0f;
        
        
        // 로그인 text
        self.loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset1, yOffset1, _workBgView.frame.size.width - (xOffset * 2), 24.0f)];
        [self.loginLabel setTextColor:UIColorFromRGB(0x555555)];
        [self.loginLabel setBackgroundColor:[UIColor clearColor]];
        [self.loginLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self.loginLabel setText:LocalizedString(@"Login", @"로그인")];
        
        [_otherBgView addSubview:self.loginLabel];
        
        
        // 아이디 저장 check button
        _chIdSaveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chIdSaveBtn setFrame:CGRectMake(xOffset1 + labelWidth, yOffset1, 100.0f, 24.0f)];
        [_chIdSaveBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"id_save_text", @"아이디 저장")] forState:UIControlStateNormal];
        [_chIdSaveBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        [_chIdSaveBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateHighlighted];
        [_chIdSaveBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_chIdSaveBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
        [_chIdSaveBtn setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateSelected];
        [_chIdSaveBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_chIdSaveBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
        [_chIdSaveBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [_chIdSaveBtn addTarget:self action:@selector(onIdSavedBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_otherBgView addSubview:_chIdSaveBtn];
        
        
        // 자동 로그인 check button
        _chAutoLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chAutoLoginBtn setFrame:CGRectMake(_chIdSaveBtn.frame.origin.x + _chIdSaveBtn.frame.size.width + 10.0f, yOffset1, 100.0f, 24.0f)];
        [_chAutoLoginBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"Auto Login", @"자동 로그인")] forState:UIControlStateNormal];
        [_chAutoLoginBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        [_chAutoLoginBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateHighlighted];
//        [_chAutoLoginBtn setBackgroundColor:[UIColor grayColor]];
        [_chAutoLoginBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_chAutoLoginBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
        [_chAutoLoginBtn setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateSelected];
        [_chAutoLoginBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_chAutoLoginBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
        [_chAutoLoginBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [_chAutoLoginBtn addTarget:self action:@selector(onAutoLoginBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_otherBgView addSubview:_chAutoLoginBtn];

    }
    yOffset += (_otherBgView.frame.size.height + 22.0f);


    CGFloat bottomY = (viewFrame.size.height - bottomHeight);
    if (IS_LESS_THEN_IOS7) {
        bottomY -= 44.0f;
    } else {
        bottomY -= 64.0f;
    }
    
    _bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, bottomY, 320.0f, bottomHeight)];
    [_bottomBgView setBackgroundColor:UIColorFromRGB(0xadb5ca)];

    [self.view addSubview:_bottomBgView];

    
    // 라인
    UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 1.0f)];
    bottomLine.backgroundColor = UIColorFromRGB(0xcccccc);
    
    [_bottomBgView addSubview:bottomLine];

    
    // 저장 버튼
    UIImage *saveImage = [UIImage imageNamed:@"btn_darkgray.png"];
    _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_saveBtn setFrame:CGRectMake((_bottomBgView.frame.size.width / 2) - 5.0f - saveImage.size.width, 10.0f, saveImage.size.width, saveImage.size.height)];
    [_saveBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"save", @"저장")] forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_saveBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_saveBtn setBackgroundImage:saveImage forState:UIControlStateNormal];
    [_saveBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
//    [_saveBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_saveBtn addTarget:self action:@selector(onSaveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [_bottomBgView addSubview:_saveBtn];

    
    // 취소 버튼
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelBtn setFrame:CGRectMake((_bottomBgView.frame.size.width / 2) + 5.0f, 10.0f, saveImage.size.width, saveImage.size.height)];
    [_cancelBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"Cancel", @"취소")] forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_cancelBtn setBackgroundImage:saveImage forState:UIControlStateNormal];
    [_cancelBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_cancelBtn addTarget:self action:@selector(onCancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [_bottomBgView addSubview:_cancelBtn];

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


- (void)initUpdateProgress
{
    if (!_progressView)
    {
        _progressView = [[LoadingProgressView alloc] initWithFrame:self.view.bounds];
        _progressView.delegate = self;
        [[[UIApplication sharedApplication] keyWindow] addSubview:_progressView];
//        [self.view addSubview:_progressView];
    }
}

#pragma mark 즐겨찾기 업데이트 진행
- (void)setupFavoriteDB
{
    NSArray *favorites = [DBMethod loadDBFavoriteCourses];
    NSLog(@"(최초) 기존 즐겨찾기 DB 목록이 존재하나? %d", [favorites count]);
    if ([favorites count] > 0) {
        return;
    }
    
    // 업데이트 프로그래스 화면 구성
    [self initUpdateProgress];
    
    // 프로그래스 노출
    NSInteger updateCount = [[UserContext shared].updateCount integerValue];
    NSLog(@"업데이트 개수 (%d)", updateCount);
    [self.progressView onStart:updateCount withType:ProgressTypeUpdateDownload];

    
    // 1. 전체 기수 목록 구성
    NSLog(@".......... 1. 전체 기수(CourseClass) 목록 서버 요청 .........");
    [self performSelector:@selector(requestAPIClasses) withObject:nil afterDelay:0.1f];
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
    UIActionSheet *actionSheet = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:LocalizedString(@"Cancel", @"Cancel")
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:LocalizedString(@"Take a Photo", @"Take a Photo"),
                                                           LocalizedString(@"Photo of Library", @"Photo of Library"),
                                                           LocalizedString(@"Delete Photo", "사진 삭제"), nil];
        actionSheet.destructiveButtonIndex = 2;

    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:LocalizedString(@"Cancel", @"Cancel")
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:LocalizedString(@"Photo of Library", @"Photo of Library"),
                                                           LocalizedString(@"Delete Photo", "사진 삭제"), nil];
        actionSheet.destructiveButtonIndex = 1;
    }
    
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

- (void)onNotCurrentBtnClicked:(UIButton *)sender
{
    if (sender.isSelected == NO) {
        [_currentBtn setSelected:NO];
        [_noCurrentBtn setSelected:YES];
    }
}

- (void)onCurrentedBtnClicked:(UIButton *)sender
{
    if (sender.isSelected == NO) {
        [_currentBtn setSelected:YES];
        [_noCurrentBtn setSelected:NO];
    }
//    [sender setSelected:![sender isSelected]];
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

/// 자동 로그인 옵션
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
    
//    [UserContext shared].updateCount = @"";
//    [UserContext shared].lastUpdateDate = @"0000-00-00 00:00:00";
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastUpdate];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUpdateCount];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}


/// 프로필 저장 버튼
- (void)onSaveBtnClicked:(id)sender
{
    // 수정된 항목 즉 화면의 내용을 저장
//    [_profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _myInfo[@"photourl"]]]
//                      placeholderImage:[UIImage imageNamed:@"ic_noimg_info"]];
    
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
        
        if ([_currentBtn isSelected]) {
            _myInfo[@"iscurrent"] = @"y";
        } else {
            _myInfo[@"iscurrent"] = @"n";
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
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAutoLogin];
//        [UserContext shared].isAutoLogin = YES;
        _chIdSaveBtn.selected = YES;
        
        NSLog(@"비밀번호 저장 : %@", [UserContext shared].userPwd);
        [[NSUserDefaults standardUserDefaults] setValue:[UserContext shared].userPwd forKey:kUserPwd];

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

// 취소 버튼
- (void)onCancelBtnClicked:(id)sender
{
    // 내 정보 설정 취소 선택 시, 저장은 하지 않고 홈 화면으로 이동
    [self onHomeButtonClicked:sender];
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
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (buttonIndex == 0) {         // Camera
            [self showCamera];
        }
        else if (buttonIndex == 1) {    // Album
            [self showPhotoAlbum];
        }
        else if (buttonIndex == 2) {    // delete
            [self removePhoto];
        }
    }
    else {
        if (buttonIndex == 0) {         // Album
            [self showPhotoAlbum];
        } else if (buttonIndex == 1) {  // delete
            [self removePhoto];
        }
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

- (void)removePhoto
{
    [_profileImageView setImage:[UIImage imageNamed:@"ic_noimg_info.png"]];
    
    // 왼쪽 메뉴의 사진도 함께 삭제
    _myInfo[@"photourl"] = @"";
    MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
    [menu updateHeaderInfo];

//        [_profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _myInfo[@"photourl"]]]
//                          placeholderImage:[UIImage imageNamed:@"ic_noimg_info"]];
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
            
//            _myInfo[@"photourl"] = @"";
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
                      placeholderImage:[UIImage imageNamed:@"ic_noimg_info.png"]];
    
    _idValueLabel.text = [UserContext shared].userId;

    if ([[UserContext shared].language isEqualToString:kLMKorean]) {
        _nameValueLabel.text = _myInfo[@"name"];
    } else {
        _nameValueLabel.text = _myInfo[@"name_en"];
    }
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
        
        if ([_myInfo[@"share_mobile"] isEqualToString:@"n"]) {
            _shareMobileBtn.selected = NO;
        } else {
            _shareMobileBtn.selected = YES;
        }
        
        if ([_myInfo[@"share_email"] isEqualToString:@"n"]) {
            _shareEmailBtn.selected = NO;
        } else {
            _shareEmailBtn.selected = YES;
        }
        
        if ([_myInfo[@"share_company"] isEqualToString:@"n"]) {
            _shareOfficeBtn.selected = NO;
        } else {
            _shareOfficeBtn.selected = YES;
        }
        
        if ([_myInfo[@"iscurrent"] isEqualToString:@"n"]) {
            _currentBtn.selected = NO;
            _noCurrentBtn.selected = YES;
        } else {
            _currentBtn.selected = YES;
            _noCurrentBtn.selected = NO;
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
    
    // db에서 자신의 정보를 찾아 업데이트
    
}


#pragma mark - Network API
- (void)timeout:(NSDictionary*)dict {
    NSLog(@"timeout");
    AFHTTPRequestOperation *operation = [dict objectForKey:@"operation"];
    if (operation) {
        [operation cancel];
    }
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
//    [self perform:[[dict objectForKey:@"selector"] pointerValue] on:[dict objectForKey:@"object"] with:nil];
}

// 내 정보 조회
- (void)requestAPIMyInfo
{
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    NSString *lang = [UserContext shared].language;

    if (!mobileNo || !userId | !certNo) {
        return;
    }
    
//    path    /fb/myinfo
//    param   scode=5684825a51beb9d2fa05e4675d91253c&userid=ztest01&certno=m9kebjkakte1tvrqfg90i9fh84
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo, @"lang":lang};
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
                                                 
                                                 [UserContext shared].profileInfo = [_myInfo mutableCopy];
                                                 [[NSUserDefaults standardUserDefaults] setObject:_myInfo forKey:kProfileInfo];
                                                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSetProfile];
                                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                                 NSLog(@"저장 후 프로필 : %@", [[NSUserDefaults standardUserDefaults] objectForKey:kProfileInfo]);
                                                 
                                                 // 로컬 저장 후, 메모리로 업데이트.
                                                 [self updateDBMyInfo];
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
//    NSString *photoFileName = @"avatar.jpg";
//    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:photoFileName], 0.5);
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    
    NSLog(@"myInfo : %@", _myInfo);
    NSMutableDictionary *param = nil;

    if (_memType == MemberTypeStudent) {
        param = [@{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo, @"lang":lang,
//                   @"photourl":_myInfo[@"photourl"], @"viewphotourl":_myInfo[@"viewphotourl"],
                   @"email":_myInfo[@"email"],
                  @"company":_myInfo[@"company"], @"department":_myInfo[@"department"], @"title":_myInfo[@"title"],
                  @"company_en":_myInfo[@"company_en"], @"department_en":_myInfo[@"department_en"], @"title_en":_myInfo[@"title_en"],
//                            @"photo":photoFileName, @"photoData":imageData,
                  @"share_email":_myInfo[@"share_email"], @"share_mobile":_myInfo[@"share_mobile"], @"share_company":_myInfo[@"share_company"],
                   @"iscurrent":_myInfo[@"iscurrent"]} mutableCopy];
    } else {
        param = [@{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo, @"lang":lang,
//                   @"photourl":_myInfo[@"photourl"], @"viewphotourl":_myInfo[@"viewphotourl"],
                   @"tel":_myInfo[@"tel"], @"email":_myInfo[@"email"]} mutableCopy];
    }
    NSLog(@"MyInfo Request Parameter : %@", param);
    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
    
    static NSString * const kAPIUpdateMyInfo = (SERVER_URL@"/fb/updatemyinfo");
    NSLog(@"API Path(%@) param :\n%@", kAPIUpdateMyInfo, param);
    
    NSLog(@"내 정보 업데이트--- start");
    
    if (_photoFilename.length > 0 && _photoData)
    {
        NSLog(@"사진이 변경되어 사진과 함께 업데이트");

        NSMutableURLRequest *request =
        [[SMNetworkClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                  path:kAPIUpdateMyInfo
                                                            parameters:param
                                             constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                                 NSLog(@"내 정보 업데이트--- 1");
                                                 if (_photoFilename.length > 0 && _photoData) {
                                                     NSLog(@"내 정보 업데이트--- 사진 변경되어 photo 추가");
                                                     [formData appendPartWithFileData:_photoData name:@"photo" fileName:_photoFilename mimeType:@"image/jpeg"];
                                                 }
                                             }];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            
            NSLog(@"(사진 업로드) Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                NSLog(@"프로필 변경 완료");
                                                [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                                            
                                                if (_photoData)
                                                {
                                                    NSLog(@"사진 변경 정보 왼쪽 메뉴에 업데이트");
                                                    // 왼쪽 메뉴 사진 정보 업데이트
                                                    MenuTableViewController *menu = (MenuTableViewController *)self.menuContainerViewController.leftMenuViewController;
                                                    UIImage *image = [[UIImage alloc] initWithData:_photoData];
                                                    [menu updateHeaderImage:image];
                                                    
                                                    // DB에도 내 정보 업데이트
    //                                                [self updateDBMyInfo];
                                                    
                                                    NSLog(@"내 정보 다시 불러오기.");
                                                    _photoData = nil;
                                                    
                                                    // 내 정보 조회 호출
                                                    [self performSelector:@selector(requestAPIMyInfo) withObject:nil];
                                                }
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"내 정보 업데이트 실패 : %@",  [error localizedDescription]);
                                             [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                                             
                                             [[SMNetworkClient sharedClient] showNetworkError:error];
                                         }
        ];
        
        [operation start];
    }
    else
    {
        NSLog(@"사진 변경이 없어 나머지만 업데이트");
        [[SMNetworkClient sharedClient] updateMyInfo:param
                                               block:^(NSDictionary *result, NSError *error) {
                                                   
                                                   [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                                                 
                                                   if (error) {
                                                       NSLog(@"내 정보 업데이트 Fail : %@",  [error localizedDescription]);
                                                       [[SMNetworkClient sharedClient] showNetworkError:error];
                                                   }
                                                   else
                                                   {
                                                       NSLog(@"내 정보 업데이트 Success !");
                                                       // 내 정보 조회 호출
                                                       [self performSelector:@selector(requestAPIMyInfo) withObject:nil];
                                                   }
                                               }];
    }
}

- (void)updateDBMyInfo
{
    NSArray *fetched = [self findDBMyInfo];
    NSLog(@"자신의 정보 찾았나? %@", fetched);

    if (fetched && [fetched count] > 0)
    {
        if (_memType == MemberTypeFaculty)
        {
            Faculty *mo = fetched[0];
            mo.email        = _myInfo[@"email"];
            mo.office       = _myInfo[@"office"];
            mo.office_en    = _myInfo[@"office_en"];
            mo.photourl     = _myInfo[@"photourl"];
            mo.tel          = _myInfo[@"tel"];
            mo.viewphotourl = _myInfo[@"viewphotourl"];
        }
        else if (_memType == MemberTypeStaff)
        {
            Staff *mo = fetched[0];
            mo.email     = _myInfo[@"email"];
            mo.office    = _myInfo[@"office"];
            mo.office_en = _myInfo[@"office_en"];
            mo.work      = _myInfo[@"work"];
            mo.work_en   = _myInfo[@"work_en"];
            mo.photourl  = _myInfo[@"photourl"];
            mo.tel       = _myInfo[@"tel"];
            mo.viewphotourl = _myInfo[@"viewphotourl"];
        }
        else if (_memType == MemberTypeStudent)
        {
            Student *mo = fetched[0];
            mo.email = _myInfo[@"email"];
            mo.company = _myInfo[@"company"];
            mo.company_en = _myInfo[@"company_en"];
            mo.department = _myInfo[@"department"];
            mo.department_en = _myInfo[@"department_en"];
            mo.title = _myInfo[@"title"];
            mo.title_en = _myInfo[@"title_en"];
            mo.share_company = _myInfo[@"share_company"];
            mo.share_email = _myInfo[@"share_email"];
            mo.share_mobile = _myInfo[@"share_mobile"];
            mo.photourl = _myInfo[@"photourl"];
            mo.viewphotourl = _myInfo[@"viewphotourl"];
            mo.iscurrent = _myInfo[@"iscurrent"];
        }

        NSError *error;
        if ([self.moc hasChanges] && ![self.moc save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
//    if (_memType == MemberTypeStudent) {
//    }
//    else {
//    }
}


/// 각 과정별 기수 목록 서버로 요청
- (void)requestAPIClasses
{
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};
    
    // 과정별 기수 목록
    [[SMNetworkClient sharedClient] postClasses:param
                                          block:^(NSArray *result, NSError *error) {
                                              NSLog(@"response 기수 목록 (%d)", [result count]);
                                              
                                              if (error) {
                                                  [[SMNetworkClient sharedClient] showNetworkError:error];
                                              }
                                              else
                                              {
                                                  // 과정 기수 목록
//                                                  [_courses setArray:result];
                                                  
                                                  if ([result count] > 0)
                                                  {
                                                      // 기수목록 DB 저장
                                                      NSLog(@".......... SAVE DB CourseClasses .........");
                                                      [self performSelectorInBackground:@selector(savedCourseClasses:) withObject:result];
//                                                      [self saveDBCourseClasses:result];
//                                                  } else {
//                                                      NSLog(@"---------- 업데이트된 기수 목록이 없으므로 완료 처리 ----------");
//                                                      _isCourseSaveDone = YES;
                                                  }
                                                  

                                                  // 2. 교수 전공 목록 구성
                                                  NSLog(@".......... 2. 교수 전공(Majors) 목록 서버 요청 .........");
                                                  [self performSelector:@selector(requestAPIMajors) withObject:nil afterDelay:0.2f];

//                                                  NSLog(@".......... saveDBFavoriteUpdates .........");
//                                                  if (_isSavingFavorites == NO) {
//                                                      [self performSelector:@selector(saveDBFavoriteUpdates) withObject:nil];
//                                                  }
                                              }
                                          }];
}


/// (교수)전공목록 서버로 요청
- (void)requestAPIMajors
{
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};
    
    // 전공 전공 목록
    [[SMNetworkClient sharedClient] postMajors:param
                                         block:^(NSArray *result, NSError *error) {
                                             NSLog(@"response 전공 목록 (%d)", [result count]);
                                             
                                             if (error) {
                                                 [[SMNetworkClient sharedClient] showNetworkError:error];
                                             }
                                             else
                                             {
//                                                 [_majors setArray:result];
                                                 
                                                 if ([result count] > 0)
                                                 {
                                                     // 전공목록 DB 저장.
                                                     NSLog(@".......... SAVE DB MAJORS .........");
                                                     [self performSelectorInBackground:@selector(savedMajor:) withObject:result];
//                                                 } else {
//                                                     NSLog(@"---------- 변경된 교수 전공이 없어 완료 처리 ----------")
//                                                     _isMajorSaveDone = YES;
                                                 }

                                                 // 3. 즐겨찾기 업데이트 목록 구성
                                                 NSLog(@".......... 3. 즐겨찾기 업데이트 목록 서버 요청  .........");
                                                 [self performSelector:@selector(requestAPIFavorites) withObject:nil afterDelay:0.2f];

//                                                 if (_isSavingFavorites == NO) {
//                                                     [self performSelector:@selector(saveDBFavoriteUpdates) withObject:nil];
//                                                 }
                                                 
                                             }
                                         }];
}


/// 업데이트 목록 서버 요청
- (void)requestAPIFavorites
{
    NSString *mobileNo = [Util phoneNumber];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    NSString *lastUpdate = [UserContext shared].lastUpdateDate;
    
    if (!mobileNo || !userId | !certNo || !lastUpdate) {
        return;
    }
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo, @"updatedate":lastUpdate};
    
//    _studentSaveDone = NO;
//    _facultySaveDone = NO;
//    _staffSaveDone = NO;
//    _cur = 0;
    
    // 업데이트가 있을때만, 로딩 프로그래스 시작...
    //    NSLog(@"---------- Progress Show ----------");
    //    [self showUpdateProgress];
    
    // 즐겨찾기 업데이트 목록
    [[SMNetworkClient sharedClient] postFavorites:param
                                            block:^(NSDictionary *result, NSError *error) {
                                                NSLog(@"response 업데이트 목록 (%d)", [result count]);
                                                
                                                if (error) {
                                                    [[SMNetworkClient sharedClient] showNetworkError:error];
                                                }
                                                else
                                                {
                                                    // 즐겨찾기 업데이트 수신 후, 현재 시간을 마지막 업데이트 시간으로 저장
                                                    {
                                                        NSDate *date = [NSDate date];
                                                        NSString *displayString = [date string];
                                                        NSLog(@"즐겨찾기 업데이트 시간? %@", displayString);
                                                        
                                                        [UserContext shared].lastUpdateDate = displayString;
                                                        [[NSUserDefaults standardUserDefaults] setValue:displayString forKey:kLastUpdate];
                                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                                    }
                                                    
                                                    NSLog(@".......... 업데이트 시간 저장 : %@", [UserContext shared].lastUpdateDate);
//                                                    [_updateInfo setDictionary:result];
                                                    
                                                    NSLog(@".......... onUpdateDBFavorites (업데이트 저장 하자.) ..........");
                                                    
                                                    // 임시로 여기에서 progress 숨기기
//                                                    [self stopRepeatingTimer];
//                                                    if (_isSavingFavorites == NO) {
                                                    [self performSelector:@selector(saveDBFavorite:) withObject:[result mutableCopy]];
//                                                    }
                                                }
                                            }];
}

#pragma mark 학생 기수목록 저장
- (void)savedCourseClasses:(NSArray *)array
{
    if (array)
    {
        NSLog(@"서버에서 받아온 기수 목록 저장하자.");
        [DBMethod saveDBCourseClasses:array];
    }
}

#pragma mark 교수 전공목록 저장
- (void)savedMajor:(NSArray *)array
{
    if (array)
    {
        NSLog(@"서버에서 받아온 전공 목록 저장하자.");
        [DBMethod saveDBMajors:array];
    }
}

#pragma mark 즐겨찾기 업데이트 목록 저장
/// course classes DB 추가 및 업데이트
- (void)saveDBFavorite:(NSDictionary *)updateInfo
{
    _cur = 0;
//    _isSavingFavorites = YES;
    NSLog(@"----------- DB 저장 시작 (_cur=%d 초기화) ----------", _cur);
    
    NSDictionary *userInfo = @{@"end":@"1"};
    [self startRepeatingTimer:userInfo];
    
    NSDictionary *info = [NSDictionary dictionaryWithDictionary:updateInfo];
    [self saveDBFavoriteStudent:info];
    
}

#pragma mark 업데이트 (학생) 목록 저장
- (void)saveDBFavoriteStudent:(NSDictionary *)updateInfo
{
    NSLog(@"----- 학생목록 저장 시작 -----");
    if (![updateInfo[@"student"] isKindOfClass:[NSArray class]]) {
        //        _studentSaveDone = YES;
        NSLog(@"업데이트된 학생이 없으므로 학생은 pass!");
        
        NSLog(@".......... 다음 교수 저장 하자.");
        [self saveDBFavoriteFaculty:updateInfo];
        
        return;
    }
    
    NSArray *students = [updateInfo[@"student"] mutableCopy];
    NSLog(@".......... 학생 저장 [%d] ..........", [students count]);
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    if (moc == nil) {
        NSLog(@"After managedObjectContext: %@", moc);
        return;
    }
    
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:moc];
    
    NSManagedObjectContext *findContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [findContext setParentContext:moc];
    
    __block BOOL done = NO;
    
    [childContext performBlock:^{
        
        int n = 0;
        for (NSDictionary *dict in students)
        {
            NSLog(@"학생(%@) 저장", dict[@"name"]);
            
            Course *course = nil;
            //            Student *student = nil;
            __block NSArray *findCourses = nil;
            __block NSDictionary *info = [NSDictionary dictionaryWithDictionary:dict];
            
            
            [childContext performBlockAndWait:^{
                NSFetchRequest *courseFr = [[NSFetchRequest alloc] init];
                NSLog(@"(%@)학생의 과정(%@) 조회", info[@"name"], info[@"courseclass"]);
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:moc];
                [courseFr setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course == %@ AND courseclass == %@", info[@"course"], info[@"courseclass"]];
                [courseFr setPredicate:predicate];
                
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
                NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"course" ascending:YES];
                [courseFr setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil]];
                
                findCourses = [childContext executeFetchRequest:courseFr error:nil];
                NSLog(@"(%@)학생의 과정 찾았나? %d", info[@"name"], [findCourses count]);
            }];
            
            
            if ([findCourses count] > 0)
            {
                course = findCourses[0];
                
                NSArray *courseStudents = [course.students allObjects];
                NSLog(@"(%@ : %@)학생의 (%@)과정이 이미 존재함 : %d", info[@"name"], info[@"studcode"], course.courseclass, [courseStudents count]);
                
                //                for (Student *item in courseStudents) {
                //                    NSLog(@"(%@)과정의 학생 이름:%@, 아이디:%@", course.courseclass, item.name, item.studcode);
                //                }
                
                // 해당 과정에 이미 존재하는 학생인지 조사
                NSArray *existArray = [courseStudents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"studcode == %@", info[@"studcode"]]];
                NSLog(@"이미 해당 과정에 학생이 존재하나? %d", [existArray count]);
                
                if ([existArray count] > 0)
                {
                    Student *student = existArray[0];
                    
                    if ([info[@"remove"] isEqualToString:@"y"])
                    {
                        NSLog(@"(%@)학생 삭제", student.name);
                        [course removeStudentsObject:student];
                        [childContext deleteObject:student];
                    }
                    else
                    {
                        // 등록된 사용자이므로 정보만 업데이트
                        NSLog(@"업데이트 학생(%@) : %@", student.name, student.studcode);
                        
                        // ( NSManagedObject <- NSDictionary )
                        student.classtitle = info[@"classtitle"];
                        student.classtitle_en = info[@"classtitle_en"];
                        student.company = info[@"company"];
                        student.company_en = info[@"company_en"];
                        student.department = info[@"department"];
                        student.department_en = info[@"department_en"];
                        student.email = info[@"email"];
                        student.mobile = info[@"mobile"];
                        student.name = info[@"name"];
                        student.name_en = info[@"name_en"];
                        student.photourl = info[@"photourl"];
                        student.share_company = info[@"share_company"];
                        student.share_email = info[@"share_email"];
                        student.share_mobile = info[@"share_mobile"];
                        student.status = info[@"status"];
                        student.status_en = info[@"status_en"];
                        student.studcode = info[@"studcode"];
                        student.title = info[@"title"];
                        student.title_en = info[@"title_en"];
                        student.viewphotourl = info[@"viewphotourl"];
                        student.iscurrent = info[@"iscurrent"];
                        //                        student.course;
                    }
                }
                else
                {
                    __block NSMutableArray *anotherArray = nil;
                    NSLog(@"학생의 과정이 변경되었거나, 추가된 경우");
                    
                    [childContext performBlockAndWait:^{
                        NSLog(@"학생의 과정이 변경되었는지 조회");
                        NSFetchRequest *fetchedRequest = [[NSFetchRequest alloc] init];
                        
                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:moc];
                        [fetchedRequest setEntity:entity];
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"studcode == %@", info[@"studcode"]];
                        [fetchedRequest setPredicate:predicate];
                        
                        NSArray *array = [childContext executeFetchRequest:fetchedRequest error:nil];
                        anotherArray = [array mutableCopy];
                        NSLog(@"다른 과정에 학생이 존재하나? %d", [anotherArray count]);
                    }];
                    
                    if ([anotherArray count] > 0)
                    {
                        Student *std = anotherArray[0];
                        
                        NSLog(@"학생(%@)의 과정이 달라져서 이전 과정 삭제. (%@ -> %@)", std.name, std.course.courseclass, info[@"courseclass"]);
                        [std.course removeStudentsObject:std];
                    }
                    
                    NSLog(@"해당 (%@)과정에 (%@)학생 추가", course.courseclass, info[@"name"]);
                    NSManagedObjectContext *context = [course managedObjectContext];
                    Student *newStudent = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:context];
                    
                    newStudent.studcode = info[@"studcode"];
                    NSLog(@"추가 Student : %@", newStudent.studcode);
                    
                    // ( NSManagedObject <- NSDictionary )
                    newStudent.classtitle = info[@"classtitle"];
                    newStudent.classtitle_en = info[@"classtitle_en"];
                    newStudent.company = info[@"company"];
                    newStudent.company_en = info[@"company_en"];
                    newStudent.department = info[@"department"];
                    newStudent.department_en = info[@"department_en"];
                    newStudent.email = info[@"email"];
                    newStudent.mobile = info[@"mobile"];
                    newStudent.name = info[@"name"];
                    newStudent.name_en = info[@"name_en"];
                    newStudent.photourl = info[@"photourl"];
                    newStudent.share_company = info[@"share_company"];
                    newStudent.share_email = info[@"share_email"];
                    newStudent.share_mobile = info[@"share_mobile"];
                    newStudent.status = info[@"status"];
                    newStudent.status_en = info[@"status_en"];
                    newStudent.studcode = info[@"studcode"];
                    newStudent.title = info[@"title"];
                    newStudent.title_en = info[@"title_en"];
                    newStudent.viewphotourl = info[@"viewphotourl"];
                    newStudent.iscurrent = info[@"iscurrent"];
                    newStudent.course = course;
//                    [newStudent setCourse:course];
                    
                    NSLog(@"과정의 컨텍스트로 (%@)학생 저장 (%@ === %@)", newStudent.name, context, childContext);
                    [context save:nil];
                    
                }
                
            }
            else {
                NSLog(@"해당 과정이 없으면 오류!!!!!!!!!!!!!");
                //                course = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:_moc];
                //                course = [[Course alloc] initWithEntity:courseEntity insertIntoManagedObjectContext:childContext];
                //                course.course = info[@"course"];
                //                course.courseclass = info[@"courseclass"];
                //                course.title = info[@"classtitle"];
                //                course.title_en = info[@"classtitle_en"];
                //                course.favyn = @"n";
                //                course.type = @"1";
                //                NSLog(@"추가 Course : %@", course.courseclass);
                //                NSLog(@"..... Saving child (course)");
                //                [childContext save:nil];
            }
            
            _cur += 1;
            NSLog(@"..... 학생 저장 중 (%d - %d)", _cur, ++n);
            [childContext save:nil];
            
        } // for
        
        done = YES;
//        _studentSaveDone = YES;
        NSLog(@"..... student done .....");
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSLog(@"Saving parent");
            [moc save:nil];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
            NSLog(@"Done(학생): %d objects written", [[moc executeFetchRequest:request error:nil] count]);
            
            NSLog(@"학생 저장 끝났으니 교수 저장 하자.");
            [self saveDBFavoriteFaculty:updateInfo];
            
//            [_progressView setHidden:YES];   // test
//            [self hideUpdateProgress];
        });
        
    }]; // childContext
    
    // execute a read request after 0.5 second
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
        [moc performBlockAndWait:^{
            
            NSArray *objects = [moc executeFetchRequest:request error:nil];
            NSLog(@"In between read: (학생) %d objects", [objects count]);
//            NSLog(@"object : %@", object);
            
        }];
    });
    
    
    //    [ModelUtil saveDataInBackgroundWithContext:^(NSManagedObjectContext *context) {
    //        NSLog(@".......... 학생 저장 중 ..........");
    //        
    //    } completion:^{
    //        NSLog(@".......... 학생 저장 완료 ..........");
    //    }];
    
    NSLog(@"----- 학생목록 저장 종료 -----");
}


#pragma mark 업데이트 (교수) 목록 저장
- (void)saveDBFavoriteFaculty:(NSDictionary *)updateInfo
{
    NSLog(@"----- 교수 목록 저장 시작 -----");
    
    if (![updateInfo[@"faculty"] isKindOfClass:[NSArray class]]) {
//        _facultySaveDone = YES;
        NSLog(@"업데이트된 교수가 없으므로 학생은 pass!");
        NSLog(@".......... 다음 교직원 저장 하자.");
        [self saveDBFavoriteStaff:updateInfo];
        return;
    }
    
    NSArray *objects = updateInfo[@"faculty"];
    NSLog(@".......... 교수 저장 [%d] ..........", [objects count]);
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    if (moc == nil) {
        NSLog(@"After managedObjectContext: %@", moc);
        return;
    }

    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:moc];
    
    NSManagedObjectContext *findContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [findContext setParentContext:moc];
    
    //    NSLog(@"parent: %@,   child : %@,    find: %@,  main : %@", parentContext, childContext, findContext, appDelegate.managedObjectContext);
    __block BOOL done = NO;
    
    [childContext performBlock:^{
        
        int n = 0;
        for (NSDictionary *info in objects)
        {
            // 교수 전공 검색
            Major *major = nil;
            Faculty *faculty = nil;
            __block NSArray *findMajors = nil;
            
            [findContext performBlockAndWait:^{
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Major" inManagedObjectContext:moc];
                [fetchRequest setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"major == %@", info[@"major"]];
                [fetchRequest setPredicate:predicate];
                
                NSLog(@"(%@)교수의 (%@)전공 검색", info[@"name"], info[@"major"]);
                findMajors = [findContext executeFetchRequest:fetchRequest error:nil];
                NSLog(@"교수의 전공 찾았나? %d", [findMajors count]);
            }];
            
            if ([findMajors count] > 0)
            {
                major = findMajors[0];   // 이미 전공이 있으면 해당 전공을 가져와서 교수 정보 추가
                
                NSArray *majorFaculties = [major.facultys allObjects];
                NSLog(@"교수의 (%@)전공이 이미 존재함", major.major);
                
                // 이미 해당 전공에 교수 정보가 있는지 확인
                NSArray *findArray = [majorFaculties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"memberidx == %@", info[@"memberidx"]]];
                NSLog(@"해당 전공에 교수 찾았나? %d", [findArray count]);
                
                if ([findArray count] > 0)
                {
                    faculty = findArray[0];
                    
                    if ([info[@"remove"] isEqualToString:@"y"]) {
                        NSLog(@"(%@)교수정보 삭제", faculty.name);
                        [major removeFacultysObject:faculty];
                        [childContext deleteObject:faculty];
                    }
                    else {
                        // 등록된 사용자이므로 정보만 업데이트
                        NSLog(@"(%@)교수 업데이트 : %@", faculty.name, faculty.memberidx);
                        faculty.email = info[@"email"];
                        faculty.mobile = info[@"mobile"];
                        faculty.name = info[@"name"];
                        faculty.name_en = info[@"name_en"];
                        faculty.office = info[@"office"];
                        faculty.office_en = info[@"office_en"];
                        faculty.photourl = info[@"photourl"];
                        faculty.tel = info[@"tel"];
                        faculty.viewphotourl = info[@"viewphotourl"];
                    }
                }
                else
                {
                    __block NSMutableArray *anotherArray = nil;
                    
                    [childContext performBlockAndWait:^{
                        NSLog(@"교수가 다른 전공에 정보가 있는지 조회");
                        NSFetchRequest *fetchedRequest = [[NSFetchRequest alloc] init];
                        
                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:moc];
                        [fetchedRequest setEntity:entity];
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberidx == %@", info[@"memberidx"]];
                        [fetchedRequest setPredicate:predicate];
                        
                        NSArray *array = [childContext executeFetchRequest:fetchedRequest error:nil];
                        anotherArray = [array mutableCopy];
                        NSLog(@"다른 전공에 교수가 존재하나? %d", [anotherArray count]);
                        
                    }];
                    
                    if ([anotherArray count] > 0)
                    {
                        Faculty *anotherFaculty = anotherArray[0];
                        NSLog(@"교수(%@)의 전공이 달려저서 이전 전공 삭제. (%@ -> %@)", anotherFaculty.name, anotherFaculty.major, info[@"major"]);
                        [anotherFaculty.major removeFacultysObject:anotherFaculty];
                    }
                    
                    NSManagedObjectContext *context = [major managedObjectContext];
                    Faculty *newFaculty = [NSEntityDescription insertNewObjectForEntityForName:@"Faculty" inManagedObjectContext:context];
                    newFaculty.memberidx = info[@"memberidx"];
                    NSLog(@"해당 전공에 교수(%@) 추가 : %@", info[@"name"], newFaculty.memberidx);
                    
                    newFaculty.email = info[@"email"];
                    newFaculty.mobile = info[@"mobile"];
                    newFaculty.name = info[@"name"];
                    newFaculty.name_en = info[@"name_en"];
                    newFaculty.office = info[@"office"];
                    newFaculty.office_en = info[@"office_en"];
                    newFaculty.photourl = info[@"photourl"];
                    newFaculty.tel = info[@"tel"];
                    newFaculty.viewphotourl = info[@"viewphotourl"];
                    newFaculty.major = major;
                    
                    NSLog(@"전공 컨텍스트로 저장 (%@ ======= %@)", context, childContext);
                    [context save:nil];
                    
                }
            }
            else {
                NSLog(@"교수의 해당 전공(%@)이 없으면 오류 !!!!!!!!!!", info[@"major"]);
            }
            
            _cur += 1;
            NSLog(@"..... 교수 저장 중 (%d - %d)", _cur, ++n);
            [childContext save:nil];
            
        } // for
        
        done = YES;
//        _facultySaveDone = YES;
        NSLog(@"..... faculty done .....");
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSLog(@"Saving parent");
            [moc save:nil];
            
            NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Faculty"];
            NSLog(@"Done(교수): %d objects written", [[moc executeFetchRequest:fr error:nil] count]);
            
            NSLog(@"교수 저장 끝났으니 교직원 저장 하자.");
            [self saveDBFavoriteStaff:updateInfo];
//            [self hideUpdateProgress];
            
        });
        
    }]; // childContext
    
    // execute a read request after 0.5 second
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Faculty"];
        [moc performBlockAndWait:^{
            NSArray *object = [moc executeFetchRequest:fr error:nil];
            NSLog(@"In between read: 교수 %d objects", [object count]);
//            NSLog(@"object : %@", object);
            
        }];
    });
    
    NSLog(@"----- 교수 목록 저장 종료 -----");
}

#pragma mark 업데이트 (교직원) 목록 저장
- (void)saveDBFavoriteStaff:(NSDictionary *)updateInfo
{
    NSLog(@"----- 교직원 목록 저장 시작 -----");
    
    if (![updateInfo[@"staff"] isKindOfClass:[NSArray class]]) {
//        _staffSaveDone = YES;
        NSLog(@"업데이트된 교수가 없으므로 학생은 pass!");
        [self stopRepeatingTimer];
        return;
    }
    
    NSArray *objects = updateInfo[@"staff"];
    NSLog(@".......... 교직원 저장 [%d] ..........", [objects count]);
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    if (moc == nil) {
        NSLog(@"After managedObjectContext: %@", moc);
        return;
    }

    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:moc];
    
    NSManagedObjectContext *findContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [findContext setParentContext:moc];
    
    //    NSLog(@"parent: %@,   child : %@,    find: %@,  main : %@", parentContext, childContext, findContext, appDelegate.managedObjectContext);
    __block BOOL done = NO;
    
    [childContext performBlock:^{
        int n = 0;
        for (NSDictionary *info in objects)
        {
            // 교직원 검색
            Staff *staff = nil;
            __block NSMutableArray *findStaffes = nil;
            
            NSFetchRequest *staffFr = [[NSFetchRequest alloc] init];
            
            [childContext performBlockAndWait:^{
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Staff" inManagedObjectContext:moc];
                [staffFr setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberidx == %@", info[@"memberidx"]];
                [staffFr setPredicate:predicate];
                
                NSLog(@"교직원(%@) 검색", info[@"name"]);
                NSArray *array = [childContext executeFetchRequest:staffFr error:nil];
                findStaffes = [array mutableCopy];
                NSLog(@"교직원 찾았나? %d", [findStaffes count]);
            }];
            
            
            if ([findStaffes count] > 0)
            {
                staff = findStaffes[0]; // 이미 존재하는 교직원은 정보만 업데이트
                
                if ([info[@"remove"] isEqualToString:@"y"])
                {
                    NSLog(@"삭제 staff(%@)", staff.name);
                    [childContext deleteObject:staff];
                }
                else {
                    // 등록된 사용자이므로 정보만 업데이트
                    NSLog(@"업데이트 staff(%@) : %@", staff.name, staff.memberidx);
                    staff.email     = info[@"email"];
                    staff.mobile    = info[@"mobile"];
                    staff.name      = info[@"name"];
                    staff.name_en   = info[@"name_en"];
                    staff.office    = info[@"office"];
                    staff.office_en = info[@"office_en"];
                    staff.work      = info[@"work"];
                    staff.work_en   = info[@"work_en"];
                    staff.photourl  = info[@"photourl"];
                    staff.tel       = info[@"tel"];
                    staff.viewphotourl = info[@"viewphotourl"];
                }
            }
            else
            {
                Staff *newStaff = [NSEntityDescription insertNewObjectForEntityForName:@"Staff" inManagedObjectContext:childContext];
                newStaff.memberidx = info[@"memberidx"];
                
                NSLog(@"(%@)교직원 추가 : %@", info[@"name"], newStaff.memberidx);
                newStaff.email      = info[@"email"];
                newStaff.mobile     = info[@"mobile"];
                newStaff.name       = info[@"name"];
                newStaff.name_en    = info[@"name_en"];
                newStaff.office     = info[@"office"];
                newStaff.office_en  = info[@"office_en"];
                newStaff.work       = info[@"work"];
                newStaff.work_en    = info[@"work_en"];
                newStaff.photourl   = info[@"photourl"];
                newStaff.tel        = info[@"tel"];
                newStaff.viewphotourl = info[@"viewphotourl"];
            }
            
            _cur += 1;
            NSLog(@"..... 교직원 저장 중 (%d - %d)", _cur, ++n);
            [childContext save:nil];
            
        } // for
        
        done = YES;
//        _staffSaveDone = YES;
        NSLog(@"..... staff done .....");
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSLog(@"Saving parent");
            [moc save:nil];
            
            NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Staff"];
            NSLog(@"Done(Staff): %d objects written", [[moc executeFetchRequest:fr error:nil] count]);
            
            [self stopRepeatingTimer];
        });
        
    }]; // childContext
    
    // execute a read request after 0.5 second
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Staff"];
        [moc performBlockAndWait:^{
            
            NSArray *object = [moc executeFetchRequest:fr error:nil];
            NSLog(@"In between read: (교직원) %d objects", [object count]);
//            NSLog(@"object : %@", object);
        }];
    });
    NSLog(@"----- 교직원 목록 저장 종료 -----");
}


#pragma mark - DB methods

/// 내 정보 조희
- (NSArray *)findDBMyInfo
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // select Table
    NSEntityDescription *entity = nil;
    NSPredicate *predicate = nil;
    NSString *userKey = [UserContext shared].userKey;
    NSLog(@"자신의 타입 : %d, 고유키 : %@", _memType, userKey);
    
    if (_memType == MemberTypeStudent) {
        // 학생 table
        entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:self.moc];
        
        predicate = [NSPredicate predicateWithFormat:@"(studcode == %@)", userKey];
    }
    else if (_memType == MemberTypeFaculty)
    {
        // 교수 table
        entity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:self.moc];
        
        predicate = [NSPredicate predicateWithFormat:@"(memberidx == %@)", userKey];
    }
    else if (_memType == MemberTypeStaff)
    {
        // 교직원 table
        entity = [NSEntityDescription entityForName:@"Staff" inManagedObjectContext:self.moc];
        
        predicate = [NSPredicate predicateWithFormat:@"(memberidx == %@)", userKey];
    }
    
    if (entity == nil || predicate == nil) {
        return nil;
    }
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray *filtered = [self.moc executeFetchRequest:fetchRequest error:&error];
//    NSLog(@"Filtered DB count : %d", [filtered count]);
    
    return filtered;
}

#pragma mark - Timer
- (void)startRepeatingTimer:(NSDictionary *)info {
    NSLog(@".......... startRepeatingTimer (info : %@)", info);
    
    _tot = [[UserContext shared].updateCount floatValue];
    _cur = 0;
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                      target:self
                                                    selector:@selector(timerFired:)
                                                    userInfo:info
                                                     repeats:YES];
    
    self.progressTimer = timer;
}

- (void)timerFired:(NSTimer *)timer
{
//    NSDictionary *info = [timer userInfo];
    //    NSLog(@".......... timerFired (info : %@)", info);
    NSLog(@".......... timerFired ( %d / %d ) ..........", _cur, _tot);
    [self.progressView onProgress:_cur total:_tot];
    //    self.progressView.percentLabel.text = [NSString stringWithFormat:@"(Download %d / %d)", _cur, _tot];
    //    self.progressView.progress = (float)(_cur / _tot);
}

- (void)stopRepeatingTimer
{
    NSLog(@".......... stopRepeatingTimer");
    
    [self.progressView onProgress:_cur total:_tot];
    //    self.progressView.percentLabel.text = [NSString stringWithFormat:@"(Download %d / %d)", _cur, _tot];
    //    self.progressView.progress = (float)(_cur / _tot);
    
    [UIView animateWithDuration:0.2f
     //                          delay:0.0f
     //                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         [self.progressView onProgress:_tot total:_tot];
                         
                         //                         self.progressView.percentLabel.text = [NSString stringWithFormat:@"(Download %d / %d)", _tot, _tot];
                         //                         self.progressView.progress = (float)(_tot / _tot);
                     } completion:^(BOOL finished) {
                         [self.progressTimer invalidate];
                         self.progressTimer = nil;
                         
                         [self performSelector:@selector(hideProgressView) withObject:nil afterDelay:0.3];
                         //                         [self.progressView onStop];
                     }];
}


- (void)hideProgressView
{
    [self.progressView onStop];
    
    // TODO: 업데이트 카운트 한 번만 쓰고 0으로 초기화. (다음 로그인 시에 다시 세팅)
    [UserContext shared].updateCount = @"0";
    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:kUpdateCount];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

@end
