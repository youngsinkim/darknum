//
//  LoginViewController.m
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SMNetworkClient.h"

@interface LoginViewController ()

@property (strong, nonatomic) UITextField *userIdTextField;
@property (strong, nonatomic) UITextField *userPwdTextField;
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
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:UIColorFromRGB(0x133E89)];

    self.view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2f];
    
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
    // 배경 라인 박스
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 320.0f - 20.0f, 260.0f)];
    [bgView.layer setCornerRadius:2.0f];
    [bgView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5f].CGColor];
    [bgView.layer setBorderWidth:1.0f];
    
    [self.view addSubview:bgView];
    
    {
        CGFloat xOffset = 20.0f;
        CGFloat startY = 10.0f;
        
        // 아이디 입력창
        _userIdTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, 100.0f, 320.0f - xOffset - 100.0f, 24.0f)];
        _userIdTextField.delegate = self;
        _userIdTextField.placeholder = LocalizedString(@"user_id_placeholder", @"아이디 빈문자열");
        _userIdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _userIdTextField.returnKeyType = UIReturnKeyNext;
        _userIdTextField.delegate = self;
        _userIdTextField.font = [UIFont systemFontOfSize:16.0f];
        _userIdTextField.borderStyle = UITextBorderStyleLine;
        
        [bgView addSubview:_userIdTextField];
        
        
        // 비밀번호 입력창
        _userPwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, _userIdTextField.frame.origin.y + 34.0f, 320.0f - xOffset - 100.0f, 24.0f)];
        _userPwdTextField.delegate = self;
        _userPwdTextField.placeholder = LocalizedString(@"user_pwd_placeholder", @"비밀번호 빈문자열");
        _userPwdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _userPwdTextField.returnKeyType = UIReturnKeyDone;
        _userPwdTextField.delegate = self;
        _userPwdTextField.font = [UIFont systemFontOfSize:16.0f];
        _userPwdTextField.borderStyle = UITextBorderStyleLine;
        
        [bgView addSubview:_userPwdTextField];
        
        
        // 로그인 버튼
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.frame = CGRectMake(320.0f - xOffset - 70.0f, _userIdTextField.frame.origin.y, 70.0f, 58.0f);
        [_loginBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:10] forState:UIControlStateNormal];
        [_loginBtn setTitle:LocalizedString(@"login_title", @"로그인") forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _loginBtn.titleLabel.textAlignment = UITextAlignmentCenter;
        [_loginBtn addTarget:self action:@selector(onLoginClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [bgView addSubview:_loginBtn];
        
        
        // 한국어 버튼
        _koLanguageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _koLanguageBtn.frame = CGRectMake(xOffset, _userPwdTextField.frame.origin.y + 34.0f, 100.0f, 24.0f);
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
    self.userIdTextField.placeholder = LocalizedString(@"user_id_placeholder", @"아이디 빈문자열");
    self.userPwdTextField.placeholder = LocalizedString(@"user_pwd_placeholder", @"비밀번호 빈문자열");
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

#pragma mark - UITextField delegate

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
    return YES;
}

#pragma mark - UIControl Callbacks
/// 로그인
- (void)onLoginClicked
{
    [self requestAPILogin];
}

/// Korean
- (void)onKoreanLanguageClicked
{
    [TSLanguageManager setSelectedLanguage:kLMKorean];
    [self updateControls];
}

/// English
- (void)onEnglishLanguageClicked
{
    [TSLanguageManager setSelectedLanguage:kLMEnglish];
    [self updateControls];
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
- (void)requestAPILogin
{
    NSDictionary *pathDict = @{@"scode":@"5684825a51beb9d2fa05e4675d91253c", @"phone":@"01023873856", @"updatedate":@"0000-00-00 00:00:00", @"userid":@"ztest01", @"passwd":@"1111#"};
    // Request Data : scode=5684825a51beb9d2fa05e4675d91253c&phone=01023873856&updatedate=0000-00-00 00:00:00&userid=ztest01&passwd=1111#
    // Response Data : {"errcode":"0","certno":"m9kebjkakte1tvrqfg90i9fh84","memtype":"1","updatecount":"218"}
    // 로그인 요청
    [[SMNetworkClient sharedClient] postLogin:pathDict
                                        block:^(NSMutableDictionary *result, NSError *error) {
                                            
                                            NSLog(@"API Result : \n%@", result);

                                            if (error)
                                            {
                                                [[SMNetworkClient sharedClient] showNetworkError:error];
                                            }
                                            else
                                            {
                                                // 로그인 성공하면 즐겨찾기 화면으로 이동
                                                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                                [appDelegate showMainViewController:self animated:YES];

//                                                if ([result[@"list"] isKindOfClass:[NSArray class]]) {
//                                                    [self.vodList setArray:result[@"list"]];
//                                                }

                                            }
     
                                        }];
}
@end
