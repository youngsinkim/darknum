//
//  MyInfoViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "MyInfoViewController.h"
#import "NSString+MD5.h"
#import "AppDelegate.h"
#import "StudentProfileViewController.h"
#import "StaffProfileViewController.h"

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
        self.myInfo = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

//- (id)initWithMemberType:(MemberType)type
//{
//    self = [super init];
//    if (self) {
//        self.mType = type;
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSInteger memType = [[[UserContext shared] memberType] integerValue];
    NSLog(@"내 멤버 타입 : %d", memType);
    
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
    self.profileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder"]];
    self.profileImageView.frame = CGRectMake(90.0f, 0.0f, 128.0f, 128.0f);
    self.profileImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    self.profileImageView.userInteractionEnabled = YES;
    
    [scrollView addSubview:self.profileImageView];

    //
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollView addGestureRecognizer:singleTap];
    [scrollView setMultipleTouchEnabled:YES];
    [scrollView setUserInteractionEnabled:YES];
    [self.view addSubview:scrollView];
    self.view.userInteractionEnabled=YES;
    
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
        
        
        // 아이디 value
        self.idValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset+100, yOffset, 200.0f, 20.0f)];
        [self.idValueLabel setTextColor:[UIColor darkGrayColor]];
//        [self.idValueLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.idValueLabel setFont:[UIFont systemFontOfSize:14.0f]];
//        [self.idValueLabel setText:@"아이디"];
        
        [studentView addSubview:self.idValueLabel];
        yOffset += 21.0f;
        
    
        // 이름 text
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 90.0f, 20.0f)];
        [self.nameLabel setTextColor:[UIColor blackColor]];
        [self.nameLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.nameLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.nameLabel setText:@"이름"];
        
        [studentView addSubview:self.nameLabel];
        
        
        // 이름 value
        self.nameValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset+100, yOffset, 200.0f, 20.0f)];
        [self.nameValueLabel setTextColor:[UIColor darkGrayColor]];
        [self.nameValueLabel setFont:[UIFont systemFontOfSize:14.0f]];
        
        [studentView addSubview:self.nameValueLabel];
        yOffset += 21.0f;
        
        
        // Mobile text
        self.mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 90.0f, 20.0f)];
        [self.mobileLabel setTextColor:[UIColor blackColor]];
        [self.mobileLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.mobileLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.mobileLabel setTextAlignment:NSTextAlignmentCenter];
        [self.mobileLabel setText:@"Mobile"];
        
        [studentView addSubview:self.mobileLabel];
        
        // Mobile value
        self.mobileValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset+100, yOffset, 200.0f, 20.0f)];
        [self.mobileValueLabel setTextColor:[UIColor darkGrayColor]];
        [self.mobileValueLabel setFont:[UIFont systemFontOfSize:14.0f]];
        
        [studentView addSubview:self.mobileValueLabel];
        yOffset += 21.0f;

        
        // Email text
        self.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 90.0f, 20.0f)];
        [self.emailLabel setTextColor:[UIColor blackColor]];
        [self.emailLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.emailLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.emailLabel setTextAlignment:NSTextAlignmentCenter];
        [self.emailLabel setText:@"Email"];
        
        [studentView addSubview:self.emailLabel];
        
        
        // Email value
        self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+100, yOffset, 200.0f, 20.0f)];
        self.emailTextField.delegate = self;
        [self.emailTextField setTextColor:[UIColor darkGrayColor]];
        [self.emailTextField setFont:[UIFont systemFontOfSize:14.0f]];
        [self.emailTextField setReturnKeyType:UIReturnKeyDone];
        [self.emailTextField setKeyboardType:UIKeyboardTypeDefault];
        [self.emailTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [studentView addSubview:self.mobileValueLabel];
        yOffset += 21.0f;

        
        // 직장(국문) text
        self.officeKoLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 90.0f, 120.0f)];
        [self.officeKoLabel setTextColor:[UIColor blackColor]];
        [self.officeKoLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
        [self.officeKoLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.officeKoLabel setTextAlignment:NSTextAlignmentCenter];
        [self.officeKoLabel setText:@"직장 (국문)"];
        
        [studentView addSubview:self.officeKoLabel];
        
        {
            // Email value
//            self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+100, yOffset, 200.0f, 20.0f)];
//            self.emailTextField.delegate = self;
//            [self.emailTextField setTextColor:[UIColor darkGrayColor]];
//            [self.emailTextField setFont:[UIFont systemFontOfSize:14.0f]];
//            [self.emailTextField setReturnKeyType:UIReturnKeyDone];
//            [self.emailTextField setKeyboardType:UIKeyboardTypeDefault];
//            [self.emailTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//            self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//            
//            [studentView addSubview:self.mobileValueLabel];

        }
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
//    path    /fb/myinfo
//    param   scode=5684825a51beb9d2fa05e4675d91253c&userid=ztest01&certno=m9kebjkakte1tvrqfg90i9fh84
    
    NSString *mobileNo = [Util phoneNumber];
//    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
//    NSString *certNo = [[NSUserDefaults standardUserDefaults] objectForKey:kUserCertNo];
    NSString *userId = [UserContext shared].userId;
    NSString *certNo = [UserContext shared].certNo;
    
    if (!mobileNo || !userId | !certNo) {
        return;
    }
    NSDictionary *param = @{@"scode":[mobileNo MD5], @"userid":userId, @"certno":certNo};
    
    // 내 (프로필)정보
    [[SMNetworkClient sharedClient] postMyInfo:param
                                         block:^(NSDictionary *result, NSError *error) {
                                             if (error) {
                                                 [[SMNetworkClient sharedClient] showNetworkError:error];
                                             } else {
                                                 // 과정 기수 목록을 DB에 저장하고 tableView 업데이트
                                                 //NSArray *classes = [result valueForKeyPath:@"data"];
                                                 
                                                 // 로그인 결과 로컬(파일) 저장.
                                                 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:result];
                                                 
                                                 NSLog(@"서버에서 가져온 내 정보 : %@", dict);
                                                 [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"profile"];
                                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                                 [[UserContext shared] setProfileInfo:dict];
                                                 
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
    
    [self.view setNeedsDisplay];
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
