//
//  LoginViewController.m
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TermsViewController.h"
#import "SMNetworkClient.h"
#import "NSString+MD5.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController ()

@property (strong, nonatomic) MBProgressHUD *HUD;
//@property (strong, nonatomic) LoadingView *loading;
@property (strong, nonatomic) UILabel *infoLabel;
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
        self.navigationItem.title = LocalizedString(@"login_title", @"로그인");
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
    
//    self.extendedLayoutIncludesOpaqueBars = YES;
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundColor:UIColorFromRGB(0x133E89)];
//
//    self.view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2f];
    

    // 로그인 화면 구성
    [self setupLoginUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 로그인 화면 
- (void)setupLoginUI
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    
    // 배경 라인 박스
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 320.0f - 20.0f, rect.size.height - 44.0f - 20.0f)];
    [bgView.layer setCornerRadius:2.0f];
    [bgView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5f].CGColor];
    [bgView.layer setBorderWidth:1.0f];
    [bgView setUserInteractionEnabled:YES];
    
    [self.view addSubview:bgView];
    
    {
        CGFloat xOffset = 10.0f;
        CGFloat yOffset = 5.0f;
        CGFloat startY = 10.0f;
        
        // 로그인 안내 문구
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, startY, 280.0f, 60.0f)];
        [_infoLabel setTextAlignment:NSTextAlignmentCenter];
        [_infoLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_infoLabel setNumberOfLines:0];
        [_infoLabel setFont:[UIFont systemFontOfSize:14.0f]];
        _infoLabel.textColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f];
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.text = LocalizedString(@"login_info_text", @"로그인 안내 문구");
        
        [bgView addSubview:_infoLabel];
        startY += (_infoLabel.frame.size.height + yOffset);
        
        
        // 아이디 입력창
        UIImage *inputBoxBg = [UIImage imageNamed:@"input_text_border"];
        _idTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, startY, 200.0f, 28.0f)];
        _idTextField.background = [inputBoxBg stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        _idTextField.delegate = self;
        _idTextField.placeholder = LocalizedString(@"user_id_placeholder", @"아이디 빈문자열");
        _idTextField.text = @"ztest01";
//        [_idTextField setBorderStyle:UITextBorderStyleLine];
//        [_idTextField.layer setBorderColor:[UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0].CGColor];
        [_idTextField setTextColor:[UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f]];
        [_idTextField setTextAlignment:NSTextAlignmentCenter];
        [_idTextField setReturnKeyType:UIReturnKeyNext];
        [_idTextField setKeyboardType:UIKeyboardTypeDefault];
        [_idTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        _idTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _idTextField.font = [UIFont systemFontOfSize:16.0f];
        
        [bgView addSubview:_idTextField];
        
        
        // 로그인 버튼
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.frame = CGRectMake(xOffset + _idTextField.frame.size.width + 10.0f, startY, 70.0f, 56.0f);
        [_loginBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:14] forState:UIControlStateNormal];
        [_loginBtn setTitle:LocalizedString(@"login_title", @"로그인") forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _loginBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_loginBtn addTarget:self action:@selector(onLoginClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [bgView addSubview:_loginBtn];
        startY += (_idTextField.frame.size.height + yOffset);

        
        // 비밀번호 입력창
        _pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, startY, 200.0f, 28.0f)];
        _pwdTextField.background = [inputBoxBg stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        _pwdTextField.delegate = self;
        _pwdTextField.placeholder = LocalizedString(@"user_pwd_placeholder", @"비밀번호 빈문자열");
        _pwdTextField.text = @"1111#";
//        [_pwdTextField setBorderStyle:UITextBorderStyleLine];
//        [_pwdTextField.layer setBorderColor:[UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0].CGColor];
        [_pwdTextField setTextColor:[UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f]];
        [_pwdTextField setTextAlignment:NSTextAlignmentCenter];
        [_pwdTextField setReturnKeyType:UIReturnKeyDone];
        [_pwdTextField setKeyboardType:UIKeyboardTypeDefault];
        [_pwdTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        _pwdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _pwdTextField.font = [UIFont systemFontOfSize:16.0f];
        
        [bgView addSubview:_pwdTextField];
        startY += (_pwdTextField.frame.size.height + yOffset);
                
        
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
        
        
        /* 아이디 저장 버튼 */
        UIImage *checkIconImage = [UIImage imageNamed:@"check_off"];
        _idSaveCheckBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _idSaveCheckBtn.frame = CGRectMake(xOffset, _koLanguageBtn.frame.origin.y + 40.0f, 120.0f, 24.0f);
        [_idSaveCheckBtn setImage:checkIconImage forState:UIControlStateNormal];
        [_idSaveCheckBtn setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateSelected];
        _idSaveCheckBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _idSaveCheckBtn.titleLabel.textAlignment = UITextAlignmentLeft;
        [_idSaveCheckBtn setTitle:LocalizedString(@"id_save_text", @"아이디 저장") forState:UIControlStateNormal];
        [_idSaveCheckBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_idSaveCheckBtn addTarget:self action:@selector(onIdSaveChecked:) forControlEvents:UIControlEventTouchUpInside];
        
        [bgView addSubview:_idSaveCheckBtn];
        
        
        /* 로그인 유지 버튼 */
        _loginSaveCheckBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginSaveCheckBtn.frame = CGRectMake(xOffset + _idSaveCheckBtn.frame.size.width + 30.0f, _koLanguageBtn.frame.origin.y + 40.0f, 120.0f, 24.0f);
        [_loginSaveCheckBtn setImage:checkIconImage forState:UIControlStateNormal];
        [_loginSaveCheckBtn setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateSelected];
        _loginSaveCheckBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _loginSaveCheckBtn.titleLabel.textAlignment = UITextAlignmentLeft;
        [_loginSaveCheckBtn setTitle:LocalizedString(@"login_save_text", @"로그인 유지") forState:UIControlStateNormal];
        [_loginSaveCheckBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_loginSaveCheckBtn addTarget:self action:@selector(onLoginSaveChecked:) forControlEvents:UIControlEventTouchUpInside];
        
        [bgView addSubview:_loginSaveCheckBtn];
        
        
        /* 아이디 찾기 버튼 */
        _findIdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _findIdBtn.frame = CGRectMake(30.0f, self.view.frame.size.height - 200.0f, 120.0f, 30.0f);
        [_findIdBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:4] forState:UIControlStateNormal];
        _findIdBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_findIdBtn setTitle:LocalizedString(@"id_find_text", @"아이디 찾기") forState:UIControlStateNormal];
        [_findIdBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_findIdBtn addTarget:self action:@selector(onFindIdClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_findIdBtn];
        
        
        /* 비밀번호 찾기 버튼 */
        _findPasswdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _findPasswdBtn.frame = CGRectMake(self.view.frame.size.width - 150.0f, self.view.frame.size.height - 200.0f, 120.0f, 30.0f);
        [_findPasswdBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:4] forState:UIControlStateNormal];
        _findPasswdBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_findPasswdBtn setTitle:LocalizedString(@"password_find_text", @"비밀번호 찾기") forState:UIControlStateNormal];
        [_findPasswdBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_findPasswdBtn addTarget:self action:@selector(onFindPasswdClicke) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_findPasswdBtn];
    }
}

#pragma mark - ViewController methods
- (void)reset
{
    [self.HUD hide:YES];
    
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
    
    
    self.navigationItem.title = LocalizedString(@"login_title", @"로그인");
    self.idTextField.placeholder = LocalizedString(@"user_id_placeholder", @"아이디 빈문자열");
    self.pwdTextField.placeholder = LocalizedString(@"user_pwd_placeholder", @"비밀번호 빈문자열");
    self.loginBtn.titleLabel.text = LocalizedString(@"login_title", @"로그인");
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
    NSLog(@"Touched!");
    [self.view endEditing:YES];// this will do the trick
    
    // 로딩 중이면 멈춤
    [self reset];
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

    // 아이디 문자열 체크
    if ([_idTextField.text length] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"alert_id_empty_text", nil) delegate:self cancelButtonTitle:LocalizedString(@"btn_ok", nil) otherButtonTitles:nil];
        
        [alertView show];
        _loginBtn.enabled = YES;
        _loginSaveCheckBtn.enabled = YES;
        _idSaveCheckBtn.enabled = YES;

    
        return;
    }
    
    // 비밀번호 문자열 체크
    if ([_pwdTextField.text length] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"alert_pwd_empty_text", nil) delegate:self cancelButtonTitle:LocalizedString(@"btn_ok", nil) otherButtonTitles:nil];
    
        [alertView show];
        _loginBtn.enabled = YES;
        _loginSaveCheckBtn.enabled = YES;
        _idSaveCheckBtn.enabled = YES;
    
        return;
    }
    
    
    // TODO: 단말 전화번호 가져오기 기능 추가 필요
    NSString *crytoMobileNo = [NSString stringWithFormat:@"01023873856"];
    
    // TODO: 업데이트 시간 최초 이회에 마지막 시간 값으로 세팅되도록 수정 필요
    NSDictionary *param = @{@"scode":[crytoMobileNo MD5],
                            @"phone":crytoMobileNo,
                            @"updatedate":@"0000-00-00 00:00:00",
                            @"userid":_idTextField.text,
                            @"passwd":_pwdTextField.text};
    
    // MARK: 서버로 로그인 요청
    [self requestAPILogin:param];
}

/// Korean
- (void)onKoreanLanguageClicked
{
    [TSLanguageManager setSelectedLanguage:kLMKorean];
//    [self updateControls];
}

/// English
- (void)onEnglishLanguageClicked
{
    [TSLanguageManager setSelectedLanguage:kLMEnglish];
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
}

/// 아이디 찾기
- (void)onFindIdClicked
{
    // TODO: 아이디 찾기 웹 페이지로 이동
}

/// 비밀번호 찾기
- (void)onFindPasswdClicked
{
    // TODO: 비밀번호 찾기 웹 페이지로 이동
}

#pragma mark - Network methods
/// 로그인 요청 
- (void)requestAPILogin:(NSDictionary *)param
{
//    self.loading = [[LoadingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
//    self.loading.center = self.view.center;
//    [self.view addSubview:self.loading];
    
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.HUD.delegate = self;
    self.HUD.color = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    self.HUD.margin = 10.0f;

    NSLog(@"LOGIN Request Parameter : %@", param);
    
    // 로그인 요청
    [[SMNetworkClient sharedClient] postLogin:param
                                        block:^(NSMutableDictionary *result, NSError *error) {
                                            NSLog(@"API(LOGIN) Result : \n%@", result);

                                            if (error) {
                                                [[SMNetworkClient sharedClient] showNetworkError:error];
                                            }
                                            else
                                            {
                                                // 로그인 결과 로컬(파일) 저장.
                                                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:result];
                                            
                                                [UserContext shared].loginInfo = dict;
                                                [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kLoginInfo];
                                                [[NSUserDefaults standardUserDefaults] setObject:result[@"certno"] forKey:@"certno"];
                                            
                                                // 자동 로그인이 설정되어 있는 경우, 로그인 아이디/비밀번호 파일 저장.
                                                if (self.loginSaveCheckBtn.selected == YES)
                                                {
                                                    [[NSUserDefaults standardUserDefaults] setValue:[self.idTextField text] forKey:@"userId"];
                                                    [[NSUserDefaults standardUserDefaults] setValue:[self.pwdTextField text] forKey:@"userPwd"];
                                                }
                                                [[NSUserDefaults standardUserDefaults] synchronize];

                                                
                                                
                                                // 로그인 성공 후, 약관 동의 화면 or 즐겨찾기 화면으로 이동
                                                if ([[UserContext shared] isAcceptTerms] == YES)
                                                {
                                                    // 로그인 성공하면 즐겨찾기 화면으로 이동
//                                                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                                                    [appDelegate showMainViewController:self animated:YES];
                                                
                                                    // 메뉴 구성 먼저하고, 로그인 창을 모달로 띄운 시나리오에서는 해당 로그인 창을 닫는 루틴 처리.
                                                    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                                                }
                                                else
                                                {
                                                    // 약관 동의 하지 않았으면, 약관 동의 화면으로 이동
                                                    TermsViewController *termsViewController = [[TermsViewController alloc] init];

                                                    [self.navigationController pushViewController:termsViewController animated:YES];
                                                }

                                            }
                                            
//                                            [self.loading setHidden:YES];
//                                            [self.loginBtn setEnabled:YES];
                                            [self reset];
                                        }];
}
@end
