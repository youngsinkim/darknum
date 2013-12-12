//
//  LoginViewController.m
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "LoginViewController.h"
#import "TermsViewController.h"
#import "SMNetworkClient.h"
#import "NSString+MD5.h"
#import "MenuTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+LoadingProgress.h"
#import "PortraitNavigationController.h"
#import "FindWebViewController.h"

@interface LoginViewController ()

@property (strong, nonatomic) MBProgressHUD *HUD;
//@property (strong, nonatomic) LoadingView *loading;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) UILabel *loginLabel;
@property (strong, nonatomic) UIImageView *titleImgView;
@property (strong, nonatomic) UITextField *idTextField;
@property (strong, nonatomic) UITextField *pwdTextField;
@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) UIButton *koLanguageBtn;
@property (strong, nonatomic) UIButton *enLanguageBtn;
@property (strong, nonatomic) UIButton *idSaveCheckBtn;
@property (strong, nonatomic) UIButton *loginSaveCheckBtn;
@property (strong, nonatomic) UIButton *findIdBtn;
@property (strong, nonatomic) UIButton *findPasswdBtn;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        self.navigationItem.title = LocalizedString(@"Login", @"로그인");
        self.navigationItem.title = LocalizedString(@"SNU Biz members", @"SNU Biz members");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // 로그인 화면은 상속받은 네비게이션 버튼 표시 안함.
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil; 
//    self.navigationController.navigationBarHidden = YES;
//    self.extendedLayoutIncludesOpaqueBars = YES;

    // 로그인 화면 구성
    [self setupLoginUI];
    
    [_idTextField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 아이디 저장이 설정되어 있으면 로그인 입력창에 아이디를 노출시켜준다
    if ([UserContext shared].isSavedID == YES)
    {
        _idTextField.text = [UserContext shared].userId;
        _idSaveCheckBtn.selected = YES;
        [_pwdTextField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 로그인 화면 
- (void)setupLoginUI
{
    CGRect rect = self.view.frame;
    CGFloat yOffset = 30.0f;
    CGFloat xOffset = 30.0f;
    
    if (!IS_LESS_THEN_IOS7) {
//        yOffset += 64.0f;
    }
    
    // Member Login
    _loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, rect.size.width - (xOffset * 2), 16.0f)];
    [_loginLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    _loginLabel.textColor = UIColorFromRGB(0x142c6d);
    _loginLabel.backgroundColor = [UIColor clearColor];
    _loginLabel.text = LocalizedString(@"Member Login", @"Member Login");

    [self.view addSubview:_loginLabel];
    yOffset += (_loginLabel.frame.size.height + 3.0f);

    
    // 아이디 입력창
    UIImage *inputBgImage = [[UIImage imageNamed:@"t_field"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f];
    _idTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, yOffset, 320.0f - (xOffset * 2), inputBgImage.size.height)];
    _idTextField.delegate = self;
    [_idTextField setBackground:inputBgImage];
    [_idTextField setTextColor:UIColorFromRGB(0x404040)];
    [_idTextField setReturnKeyType:UIReturnKeyNext];
    [_idTextField setFont:[UIFont systemFontOfSize:13.0f]];
    [_idTextField setPlaceholder:LocalizedString(@"user_id_placeholder", @"아이디 빈문자열")];
    [_idTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, inputBgImage.size.height)];
        [_idTextField setLeftView:paddingView];
        [_idTextField setLeftViewMode:UITextFieldViewModeAlways];
    }
    
    [self.view addSubview:_idTextField];
    yOffset += (_idTextField.frame.size.height + 10.0f);
    
        
    // 비밀번호 입력창
    _pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, yOffset, 320.0f - (xOffset * 2.0f), inputBgImage.size.height)];
    _pwdTextField.delegate = self;
    [_pwdTextField setBackground:inputBgImage];
    [_pwdTextField setTextColor:UIColorFromRGB(0x404040)];
    [_pwdTextField setReturnKeyType:UIReturnKeyDone];
    [_pwdTextField setFont:[UIFont systemFontOfSize:13.0f]];
    [_pwdTextField setPlaceholder:LocalizedString(@"user_pwd_placeholder", @"비밀번호 빈문자열")];
    [_pwdTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_pwdTextField setSecureTextEntry:YES];
    {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, inputBgImage.size.height)];
        [_pwdTextField setLeftView:paddingView];
        [_pwdTextField setLeftViewMode:UITextFieldViewModeAlways];
    }
    
    [self.view addSubview:_pwdTextField];
    yOffset += (_pwdTextField.frame.size.height + 10.0f);
    
    
    // 로그인 button
    UIImage *btnImage = [UIImage imageNamed:@"btn_cyan"];
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.frame = CGRectMake(xOffset, yOffset, 320.0f - (xOffset * 2.0f), btnImage.size.height);
    [_loginBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
    [_loginBtn setTitle:LocalizedString(@"Login", @"로그인") forState:UIControlStateNormal];
    [_loginBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [_loginBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_loginBtn addTarget:self action:@selector(onLoginClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_loginBtn];
    yOffset += (_loginBtn.frame.size.height + 12.0f);
    
    
    // 아이디 저장 button
    _idSaveCheckBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _idSaveCheckBtn.frame = CGRectMake(xOffset, yOffset, 110.0f, 20.0f);
    [_idSaveCheckBtn setTitle:LocalizedString(@"id_save_text", @"아이디 저장") forState:UIControlStateNormal];
    [_idSaveCheckBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    _idSaveCheckBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    _idSaveCheckBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_idSaveCheckBtn setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    [_idSaveCheckBtn setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateSelected];
    [_idSaveCheckBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_idSaveCheckBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [_idSaveCheckBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [_idSaveCheckBtn addTarget:self action:@selector(onIdSaveChecked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_idSaveCheckBtn];
    
    
    /* 로그인 유지 버튼 */
    _loginSaveCheckBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginSaveCheckBtn.frame = CGRectMake(320.0f - xOffset - 140.0f, yOffset, 140.0f, 20.0f);
    [_loginSaveCheckBtn setTitle:LocalizedString(@"login_save_text", @"로그인 유지") forState:UIControlStateNormal];
    [_loginSaveCheckBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _loginSaveCheckBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    _loginSaveCheckBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_loginSaveCheckBtn setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    [_loginSaveCheckBtn setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateSelected];
    [_loginSaveCheckBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_loginSaveCheckBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [_loginSaveCheckBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [_loginSaveCheckBtn addTarget:self action:@selector(onLoginSaveChecked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_loginSaveCheckBtn];
    yOffset += (_loginSaveCheckBtn.frame.size.height + 12.0f);

    
    // 라인
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, rect.size.width - (xOffset * 2), 1.0f)];
    line.backgroundColor = UIColorFromRGB(0xbbbbbb);
    
    [self.view addSubview:line];
    yOffset += (line.frame.size.height + 20.0f);
    
    
    /* 아이디 찾기 버튼 */
    UIImage *grayBtnImage = [UIImage imageNamed:@"btn_gray"];
    _findIdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _findIdBtn.frame = CGRectMake(xOffset, yOffset, grayBtnImage.size.width, grayBtnImage.size.height);
    [_findIdBtn setBackgroundImage:grayBtnImage forState:UIControlStateNormal];
    [_findIdBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [_findIdBtn setTitle:LocalizedString(@"id_find_text", @"아이디 찾기") forState:UIControlStateNormal];
    [_findIdBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    [_findIdBtn addTarget:self action:@selector(onFindIdClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_findIdBtn];
    
    
    /* 비밀번호 찾기 버튼 */
    _findPasswdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _findPasswdBtn.frame = CGRectMake(320.0f - xOffset - grayBtnImage.size.width, yOffset, grayBtnImage.size.width, grayBtnImage.size.height);
    [_findPasswdBtn setBackgroundImage:grayBtnImage forState:UIControlStateNormal];
    _findPasswdBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [_findPasswdBtn setTitle:LocalizedString(@"password_find_text", @"비밀번호 찾기") forState:UIControlStateNormal];
    [_findPasswdBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    [_findPasswdBtn addTarget:self action:@selector(onFindPasswdClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_findPasswdBtn];
    yOffset += (_findIdBtn.frame.size.height + 20.0f);
    
    
    // 하단 Logo
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_logo"]];
    logoImageView.frame = CGRectMake(xOffset, yOffset, logoImageView.frame.size.width, logoImageView.frame.size.height);
    logoImageView.center = CGPointMake(320.0f / 2.0f, yOffset + logoImageView.frame.size.height / 2.0f);
    
    [self.view addSubview:logoImageView];

/* 1차 개박에서 단말 속성 따라가기로 결정하여 제외
        // 한국어 버튼
        _koLanguageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _koLanguageBtn.frame = CGRectMake(xOffset, _pwdTextField.frame.origin.y + 34.0f, 100.0f, 24.0f);
        [_koLanguageBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:4] forState:UIControlStateNormal];
        _koLanguageBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _koLanguageBtn.titleLabel.textAlignment = UITextAlignmentCenter;
        [_koLanguageBtn setTitle:LocalizedString(@"korean_text", @"한국어") forState:UIControlStateNormal];
        [_koLanguageBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_koLanguageBtn addTarget:self action:@selector(onKoreanLanguageClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [bgView addSubview:_koLanguageBtn];
        
        
        // English 버튼
        _enLanguageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _enLanguageBtn.frame = CGRectMake(_koLanguageBtn.frame.origin.x + 110.0f, _koLanguageBtn.frame.origin.y, 100.0f, 24.0f);
        [_enLanguageBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:4] forState:UIControlStateNormal];
        _enLanguageBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_enLanguageBtn setTitle:LocalizedString(@"english_text", @"영어") forState:UIControlStateNormal];
        [_enLanguageBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_enLanguageBtn addTarget:self action:@selector(onEnglishLanguageClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [bgView addSubview:_enLanguageBtn];
*/
}

#pragma mark - ViewController methods
- (void)resetUI
{
//    [self.HUD hide:YES];

    [self.loginBtn setEnabled:YES];
    [self.idSaveCheckBtn setEnabled:YES];
    [self.loginSaveCheckBtn setEnabled:YES];
}

// 컨트롤 문자열 업데이트 (언어 설정에 따른)
- (void)updateControls
{
    //    UIView *parent = self.view.superview;
    //    [self.view removeFromSuperview];
    //    self.view = nil; // unloads the view
    //    self.view.frame = [[UIScreen mainScreen] bounds];
    //
    //    [parent addSubview:self.view]; //reloads the view from the nib
    
    
    self.navigationItem.title = LocalizedString(@"Login", @"로그인");
    self.idTextField.placeholder = LocalizedString(@"user_id_placeholder", @"아이디 빈문자열");
    self.pwdTextField.placeholder = LocalizedString(@"user_pwd_placeholder", @"비밀번호 빈문자열");
    self.loginBtn.titleLabel.text = LocalizedString(@"Login", @"로그인");
    //    [_loginBtn setTitle:LocalizedString(@"login_title", @"로그인") forState:UIControlStateNormal];
    //    self.koLanguageBtn.titleLabel.text = LocalizedString(@"korean_text", @"한국어");
    //    self.enLanguageBtn.titleLabel.text = LocalizedString(@"english_text", @"영어");
    [_koLanguageBtn setTitle:LocalizedString(@"korean_text", @"한국어") forState:UIControlStateNormal];
    [_enLanguageBtn setTitle:LocalizedString(@"english_text", @"영어") forState:UIControlStateNormal];
    
    [_idSaveCheckBtn setTitle:LocalizedString(@"id_save_text", @"아이디 저장") forState:UIControlStateNormal];
    [_loginSaveCheckBtn setTitle:LocalizedString(@"login_save_text", @"로그인 유지") forState:UIControlStateNormal];
    
    [_findIdBtn setTitle:LocalizedString(@"id_find_text", @"아이디 찾기") forState:UIControlStateNormal];
    [_findPasswdBtn setTitle:LocalizedString(@"password_find_text", @"비밀번호 찾기") forState:UIControlStateNormal];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"Touched!");
    [self.view endEditing:YES];// this will do the trick

    [_idTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
    
    // 로딩 중이면 멈춤
    [self resetUI];
}

#pragma mark - UITextField delegate
/// 리턴 키를 누를 때 실행
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // keyboard 감추기
	[textField resignFirstResponder];
    
    if (textField == _idTextField) {
        // 다음(비밀번호) 컨트롤 focus
        [_pwdTextField becomeFirstResponder];
    }
    
	return YES;
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


#pragma mark - UIControl Callbacks
/// 로그인 버튼 
- (void)onLoginClicked
{
    _loginBtn.enabled = NO;
    _loginSaveCheckBtn.enabled = NO;
    _idSaveCheckBtn.enabled = NO;

    if ([_idTextField isFirstResponder]) {
        [_idTextField resignFirstResponder];
    }
    
    if ([_pwdTextField isFirstResponder]) {
        [_pwdTextField resignFirstResponder];
    }

    // 아이디 문자열 체크
    if ([_idTextField.text length] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"alert_id_empty_text", nil) delegate:self cancelButtonTitle:LocalizedString(@"Ok", nil) otherButtonTitles:nil];
        
        [alertView show];
        _loginBtn.enabled = YES;
        _loginSaveCheckBtn.enabled = YES;
        _idSaveCheckBtn.enabled = YES;

    
        return;
    }
    
    // 비밀번호 문자열 체크
    if ([_pwdTextField.text length] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"alert_pwd_empty_text", nil) delegate:self cancelButtonTitle:LocalizedString(@"Ok", nil) otherButtonTitles:nil];
    
        [alertView show];
        _loginBtn.enabled = YES;
        _loginSaveCheckBtn.enabled = YES;
        _idSaveCheckBtn.enabled = YES;
    
        return;
    }
    
    // *** 저장된 아이디가 아닌 다른 아이디로 로그인한 경우, DB 초기화를 위해 마지막 업데이트 날짜를 초기화해서 로그인 요청 한다.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserId]) {
        NSString *prevLoginId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:kUserId]];
        if (![_idTextField.text isEqualToString:prevLoginId])
        {
            // 다른 아이디로 로그인한 경우, 이전 로그인 정보 삭제.
            [UserContext shared].lastUpdateDate = @"0000-00-00 00:00:00";
        }
    }
    
    // TODO: 단말 전화번호 가져오기 기능 추가 필요
    NSString *crytoMobileNo = [Util phoneNumber];
//    NSDate *updateTime = [[UserContext shared] updateDate];
    NSString *lastUpdate = [[UserContext shared] lastUpdateDate];
    NSString *lang = [UserContext shared].language;
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSLog(@"app:%@, major:%@, minor:%@", appDisplayName, majorVersion, minorVersion);
    
    // TODO: 업데이트 시간 최초 이회에 마지막 시간 값으로 세팅되도록 수정 필요
    NSDictionary *param = @{@"scode":[crytoMobileNo MD5],
                            @"phone":crytoMobileNo,
                            @"updatedate":lastUpdate,
                            @"userid":_idTextField.text,
                            @"passwd":_pwdTextField.text,
                            @"lang":lang,
                            @"os":@"iOS",
                            @"version":version};

    // MARK: 서버로 로그인 요청
    [self requestAPILogin:param];
}

/// Korean
- (void)onKoreanLanguageClicked
{
//    [TSLanguageManager setSelectedLanguage:kLMKorean];
//    [self updateControls];
}

/// English
- (void)onEnglishLanguageClicked
{
//    [TSLanguageManager setSelectedLanguage:kLMEnglish];
//    [self updateControls];
}

/// 아이디 저장
- (void)onIdSaveChecked:(id)sender
{
    [(UIButton *)sender setSelected:![(UIButton *)sender isSelected]];
}

/// 로그인 유지
- (void)onLoginSaveChecked:(id)sender
{
    [(UIButton *)sender setSelected:![(UIButton *)sender isSelected]];
    if ([sender isSelected] == YES) {
        _idSaveCheckBtn.selected = YES;
    }
}

/// 아이디 찾기
- (void)onFindIdClicked
{
    // TODO: 아이디 찾기 웹 페이지로 이동
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://biz.snu.ac.kr/ko/member/findid"]];
    NSString *findIdUrl = @"https://biz.snu.ac.kr/fb/find-id?lang=";
    if (![[UserContext shared].language isEqualToString:kLMKorean]) {
        findIdUrl = [findIdUrl stringByAppendingString:kLMEnglish];
    } else {
        findIdUrl = [findIdUrl stringByAppendingString:kLMKorean];
    }
    FindWebViewController *findWebViewController = [[FindWebViewController alloc] initWithUrl:findIdUrl title:LocalizedString(@"Find Id", @"아이디 찾기")];
    [self presentViewController:[[PortraitNavigationController alloc] initWithRootViewController:findWebViewController] animated:YES completion:nil];
//    [self presentViewController:findWebViewController animated:YES completion:nil];
}

/// 비밀번호 찾기
- (void)onFindPasswdClicked
{
    // TODO: 비밀번호 찾기 웹 페이지로 이동
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://biz.snu.ac.kr/ko/member/resetpassword"]];
    NSString *findPwdUrl = @"https://biz.snu.ac.kr/fb/find-pw?lang=";
    if (![[UserContext shared].language isEqualToString:kLMKorean]) {
        findPwdUrl = [findPwdUrl stringByAppendingString:kLMEnglish];
    } else {
        findPwdUrl = [findPwdUrl stringByAppendingString:kLMKorean];
    }

    FindWebViewController *findWebViewController = [[FindWebViewController alloc] initWithUrl:findPwdUrl title:LocalizedString(@"Find Password", @"비밀번호 찾기")];
    [self presentViewController:[[PortraitNavigationController alloc] initWithRootViewController:findWebViewController] animated:YES completion:nil];

}

#pragma mark - Network methods
/// 로그인 요청 
- (void)requestAPILogin:(NSDictionary *)param
{
//    self.loading = [[LoadingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
//    self.loading.center = self.view.center;
//    [self.view addSubview:self.loading];
    
//    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//	self.HUD.delegate = self;
//    self.HUD.color = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
//    self.HUD.margin = 10.0f;

    NSLog(@"LOGIN Request Parameter : %@", param);
    
    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];

    // 로그인 요청
    [[SMNetworkClient sharedClient] postLogin:param
                                        block:^(NSDictionary *result, NSError *error) {
                                            
                                            NSLog(@"API(LOGIN) Result : \n%@", result);
                                            [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];

                                            if (error)
                                            {
                                                NSLog(@"error ---- %@", [error localizedDescription]);
                                                NSDictionary *info = [NSDictionary dictionaryWithDictionary:[error userInfo]];
                                                NSLog(@"error UserInfo : %@", info);
                                                BOOL isErrorAlert = YES;
                                                
                                                if ([info isKindOfClass:[NSDictionary class]]) {
                                                    if ([info[@"errcode"] isEqualToString:@"2"]) {
                                                        isErrorAlert = NO;
                                                        NSLog(@"..... 모든 정보 리셋하고 로그인 화면으로 이동");
                                                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                                        [appDelegate goLoginViewControllerWithDataReset:YES];
                                                    }
                                                }

                                                if (isErrorAlert) {
                                                    [[SMNetworkClient sharedClient] showNetworkError:error];
                                                }
                                            }
                                            else
                                            {
                                                // 로그인 결과 로컬(파일) 저장.
                                                NSDictionary *dict = [NSDictionary dictionaryWithDictionary:result];
                                                if (![dict isKindOfClass:[NSNull class]])
                                                {
                                                    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserId]) {
                                                        NSString *prevLoginId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:kUserId]];
                                                        if (![_idTextField.text isEqualToString:prevLoginId])
                                                        {
                                                            // 다른 아이디로 로그인한 경우, 이전 로그인 정보 삭제.
                                                            [[UserContext shared].profileInfo removeAllObjects];
                                                            [UserContext shared].isExistProfile = NO;
                                                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kProfileInfo];
                                                            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSetProfile];
                                                            [[NSUserDefaults standardUserDefaults] synchronize];

                                                            // 데이터베이스 초기화.
                                                            [DBMethod resetDatabase];
                                                        }
                                                    }

                                                    [UserContext shared].certNo     = dict[kCertNo];
                                                    [UserContext shared].memberType = dict[kMemType];
                                                    [UserContext shared].updateCount= dict[kUpdateCount];
                                                    [UserContext shared].myClass    = dict[kMyClass];
                                                    [UserContext shared].userKey    = dict[kUserKey];
                                                    [UserContext shared].myCourse   = dict[kMyCourse];
                                                    [UserContext shared].userId     = [self.idTextField text];
                                                
                                                    [[NSUserDefaults standardUserDefaults] setValue:dict[kCertNo] forKey:kCertNo];
                                                    [[NSUserDefaults standardUserDefaults] setValue:dict[kMemType] forKey:kMemType];
                                                    [[NSUserDefaults standardUserDefaults] setValue:dict[kUpdateCount] forKey:kUpdateCount];
                                                    [[NSUserDefaults standardUserDefaults] setValue: dict[kMyClass] forKey:kMyClass];
                                                    [[NSUserDefaults standardUserDefaults] setValue:dict[kUserKey] forKey:kUserKey];
                                                    [[NSUserDefaults standardUserDefaults] setValue: dict[kMyCourse] forKey:kMyCourse];
                                                    [[NSUserDefaults standardUserDefaults] setValue:[self.idTextField text] forKey:kUserId];
                                                
                                                    // 아이디 저장 체크되어 있으면 아이디 저장
                                                    if (self.idSaveCheckBtn.selected == YES)
                                                    {
                                                        [UserContext shared].isSavedID = YES;
                                                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSavedId];
                                                    }
                                                    [UserContext shared].userPwd = [self.pwdTextField text];
                                                    NSLog(@"비밀번호: %@", [UserContext shared].userPwd);
                                                
                                                    // 자동 로그인 체크되어 있으면 비밀번호 및 자동 로그인 여부 저장.
                                                    if (self.loginSaveCheckBtn.selected == YES)
                                                    {
                                                        [UserContext shared].isAutoLogin = YES;

                                                        [[NSUserDefaults standardUserDefaults] setValue:[self.pwdTextField text] forKey:kUserPwd];
                                                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAutoLogin];
                                                    }
                                                    
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    [UserContext shared].isLogined = YES;

                                                    // 업데이트가 존재하면 팝업으로 공지함.
                                                    if ([dict[@"forceupdate"] isEqualToString:@"y"])
                                                    {
                                                        // update url
                                                        NSString *appUpdateUrl = [NSString stringWithFormat:@"%@", dict[@"updateurl"]];
                                                        if (appUpdateUrl.length > 0)
                                                        {
                                                            [UserContext shared].appUpdateUrl = appUpdateUrl;

                                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                                                                message:LocalizedString(@"update alert msg", @"업데이트 알림 메시지")
                                                                                                               delegate:self
                                                                                                      cancelButtonTitle:LocalizedString(@"Ok", @"Ok")
                                                                                                      otherButtonTitles:LocalizedString(@"Cancel", @"Cancel"),
                                                                                       nil];
                                                            alertView.tag = 900;
                                                            [alertView show];
                                                            return;
                                                        }
                                                    }
                                                }
                                                

                                                // 로그인 성공 후, 약관 동의 화면 or 즐겨찾기 화면으로 이동
                                                NSLog(@"약관 동의 했나? %d", [[UserContext shared] isAcceptTerms]);
                                                if ([UserContext shared].isAcceptTerms == NO)
                                                {
                                                    // 약관 동의 하지 않았으면, 약관 동의 화면으로 이동
                                                    TermsViewController *termsViewController = [[TermsViewController alloc] init];
                                                    
                                                    [self.navigationController pushViewController:termsViewController animated:YES];
                                                }
                                                else
                                                {
                                                    // 로그인 성공하면 즐겨찾기 화면으로 이동
                                                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                                                    [appDelegate showMainViewController:self animated:YES];
                                                
                                                    // 메뉴 구성 먼저하고, 로그인 창을 모달로 띄운 시나리오에서는 해당 로그인 창을 닫는 루틴 처리.
                                                    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                                                    
                                                    if ([[UserContext shared] isExistProfile] == NO)
                                                    {
                                                        // 로그인 이후, 최초 프로필 설정이 안되어 있으면 프로필 화면으로 이동
                                                        MenuTableViewController *leftMenuViewController = (MenuTableViewController *)appDelegate.container.leftMenuViewController;
                                                        
                                                        [leftMenuViewController menuNavigationController:MenuViewTypeSettMyInfo withMenuInfo:nil];
                                                    }

                                                }

                                            }
                                            
                                            // 컨트롤 비활성화 했던거 복구.
                                            [self resetUI];
                                        }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 900)
    {
        /* 업데이트 진행 */
        if (buttonIndex == alertView.cancelButtonIndex)
        {
            NSString *url = [UserContext shared].appUpdateUrl;
            if (url.length > 0) {
                // https://itunes.apple.com/kr/app/~
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        }
        else
        {
            // 로그인 성공 후, 약관 동의 화면 or 즐겨찾기 화면으로 이동
            NSLog(@"약관 동의 했나? %d", [[UserContext shared] isAcceptTerms]);
            if ([UserContext shared].isAcceptTerms == NO)
            {
                // 약관 동의 하지 않았으면, 약관 동의 화면으로 이동
                TermsViewController *termsViewController = [[TermsViewController alloc] init];
                
                [self.navigationController pushViewController:termsViewController animated:YES];
            }
            else
            {
                // 로그인 성공하면 즐겨찾기 화면으로 이동
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                //                                                    [appDelegate showMainViewController:self animated:YES];
                
                // 메뉴 구성 먼저하고, 로그인 창을 모달로 띄운 시나리오에서는 해당 로그인 창을 닫는 루틴 처리.
                [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                
                if ([[UserContext shared] isExistProfile] == NO)
                {
                    // 로그인 이후, 최초 프로필 설정이 안되어 있으면 프로필 화면으로 이동
                    MenuTableViewController *leftMenuViewController = (MenuTableViewController *)appDelegate.container.leftMenuViewController;
                    
                    [leftMenuViewController menuNavigationController:MenuViewTypeSettMyInfo withMenuInfo:nil];
                }
                
            }
            
            [self resetUI];
        }
    }
}

@end
