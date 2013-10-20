//
//  SmsAuthViewController.m
//  SMAddressBook
//
//  Created by sochae on 13. 10. 18..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "SmsAuthViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+LoadingProgress.h"
#import "LoginViewController.h"


@interface SmsAuthViewController ()
{
    NSString *phoneNumberStr;
}
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) UILabel *phoneLabel;
@property (strong, nonatomic) UILabel *authLabel;
@property (strong, nonatomic) UITextField *phoneNumberField;
@property (strong, nonatomic) UITextField *smsNumberField;
@property (strong, nonatomic) UIButton *confirmBtn;
@property (strong, nonatomic) UIButton *smsBtn;

@end


@implementation SmsAuthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = LocalizedString(@"Sms Auth", @"본인 인증");
        phoneNumberStr = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;

    
    [self setupUI];
    
    [_phoneNumberField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI
{
    CGRect viewRect = self.view.bounds;
    CGFloat yOffset = 10.0f;
    
    // 본인인증 안내 문구
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, yOffset, 300.0f, 50.0f)];
//    [_infoLabel setTextAlignment:NSTextAlignmentCenter];
    [_infoLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_infoLabel setNumberOfLines:0];
    [_infoLabel setFont:[UIFont systemFontOfSize:14.0f]];
    _infoLabel.textColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f];
    _infoLabel.backgroundColor = [UIColor clearColor];
    _infoLabel.text = LocalizedString(@"Sms Auth Info", @"본인인증 안내");
    
    [self.view addSubview:_infoLabel];
    yOffset += _infoLabel.frame.size.height;
    

    // 휴대전화번호
    _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, yOffset, 300.0f, 30.0f)];
//    [_phoneLabel setTextAlignment:NSTextAlignmentLeft];
    [_phoneLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_phoneLabel setNumberOfLines:0];
    [_phoneLabel setFont:[UIFont systemFontOfSize:14.0f]];
    _phoneLabel.textColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f];
    _phoneLabel.backgroundColor = [UIColor clearColor];
    _phoneLabel.text = LocalizedString(@"Mobile Phone Number", @"휴대전화번호");
    
    [self.view addSubview:_phoneLabel];
    yOffset += _phoneLabel.frame.size.height;

    
    // 전화번호 입력창
//    UIImage *inputBoxBg = [UIImage imageNamed:@"input_text_border"];
    _phoneNumberField = [[UITextField alloc] initWithFrame:CGRectMake(20, yOffset, 200.0f, 30.0f)];
//    _phoneNumberField.background = [inputBoxBg stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    _phoneNumberField.delegate = self;
    _phoneNumberField.borderStyle = UITextBorderStyleRoundedRect;
//    _phoneNumberField.placeholder = LocalizedString(@"user_id_placeholder", @"휴대전화번호");
    _phoneNumberField.text = @"01023873856";// @"01025578458";
    //        [_idTextField setBorderStyle:UITextBorderStyleLine];
    //        [_idTextField.layer setBorderColor:[UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0].CGColor];
    [_phoneNumberField setTextColor:[UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f]];
//    [_phoneNumberField setTextAlignment:NSTextAlignmentCenter];
    [_phoneNumberField setReturnKeyType:UIReturnKeyNext];
    [_phoneNumberField setKeyboardType:UIKeyboardTypeDefault];
    [_phoneNumberField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    _phoneNumberField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _phoneNumberField.font = [UIFont systemFontOfSize:16.0f];
    
    [self.view addSubview:_phoneNumberField];
    yOffset += (_phoneNumberField.frame.size.height + 5.0f);
    
    
    // 인증번호
    _authLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, yOffset, 300.0f, 30.0f)];
//    [_authLabel setTextAlignment:NSTextAlignmentCenter];
    [_authLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_authLabel setNumberOfLines:0];
    [_authLabel setFont:[UIFont systemFontOfSize:14.0f]];
    _authLabel.textColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f];
    _authLabel.backgroundColor = [UIColor clearColor];
    _authLabel.text = LocalizedString(@"Auth Code", @"인증번호");
    
    [self.view addSubview:_authLabel];
    yOffset += (_authLabel.frame.size.height);
    
    // 전화번호 입력창
    //    UIImage *inputBoxBg = [UIImage imageNamed:@"input_text_border"];
    _smsNumberField = [[UITextField alloc] initWithFrame:CGRectMake(20, yOffset, 200.0f, 30.0f)];
    //    _phoneNumberField.background = [inputBoxBg stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    _smsNumberField.delegate = self;
    _smsNumberField.borderStyle = UITextBorderStyleRoundedRect;
    //    _phoneNumberField.placeholder = LocalizedString(@"user_id_placeholder", @"휴대전화번호");
    //        _idTextField.text = @"ztest01";
    //        [_idTextField setBorderStyle:UITextBorderStyleLine];
    //        [_idTextField.layer setBorderColor:[UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0].CGColor];
    [_smsNumberField setTextColor:[UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f]];
    //    [_phoneNumberField setTextAlignment:NSTextAlignmentCenter];
    [_smsNumberField setReturnKeyType:UIReturnKeyNext];
    [_smsNumberField setKeyboardType:UIKeyboardTypeDefault];
    [_smsNumberField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    _smsNumberField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _smsNumberField.font = [UIFont systemFontOfSize:16.0f];
    
    [self.view addSubview:_smsNumberField];
    yOffset += (_smsNumberField.frame.size.height + 10);

    
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmBtn.frame = CGRectMake(10.0f, yOffset, 100.0f, 30.0f);
    [_confirmBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:14] forState:UIControlStateNormal];
    [_confirmBtn setTitle:LocalizedString(@"Ok", @"확인") forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _confirmBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_confirmBtn addTarget:self action:@selector(onConfirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_confirmBtn];

    
    _smsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _smsBtn.frame = CGRectMake(150.0f, yOffset, 100.0f, 30.0f);
    [_smsBtn setBackgroundImage:[[UIImage imageNamed:@"white_btn_bg2"] stretchableImageWithLeftCapWidth:4 topCapHeight:14] forState:UIControlStateNormal];
    [_smsBtn setTitle:LocalizedString(@"Receivce Auth Code", @"인증번호받기") forState:UIControlStateNormal];
    [_smsBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _smsBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _smsBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_smsBtn addTarget:self action:@selector(onSmsBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_smsBtn];

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touched!");
    [self.view endEditing:YES];// this will do the trick
    
}

#pragma mark - UITextField delegate
/// 리턴 키를 누를 때 실행
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // keyboard 감추기
	[textField resignFirstResponder];
    
    if (textField == _phoneNumberField) {
        // 다음(비밀번호) 컨트롤 focus
        [_smsNumberField becomeFirstResponder];
    }
    
	return YES;
}

#pragma mark - UIControl Events
- (void)onConfirmBtnClicked
{
    if ([_phoneNumberField isFirstResponder]) {
        [_phoneNumberField resignFirstResponder];
    } else if ([_smsNumberField isFirstResponder]) {
        [_smsNumberField resignFirstResponder];
    }
    
    // 인증번호 문자열 체크
    if ([_smsNumberField.text length] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"Text Empty", @"인증번호 빈 문자열 오류") delegate:self cancelButtonTitle:LocalizedString(@"Ok", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }

    [self requestAuth:_smsNumberField.text];
}

- (void)onSmsBtnClicked
{
    // 전화번호 문자열 체크
    if ([_phoneNumberField.text length] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"Text Empty", @"인증번호 빈 문자열 오류") delegate:self cancelButtonTitle:LocalizedString(@"Ok", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }

    // 휴대전화 인증번호 요청
    [self requestAuthSms:_phoneNumberField.text];
}

#pragma mark - Network
- (void)requestAuth:(NSString *)smsNo
{
    NSString *lang = [UserContext shared].language;
    NSDictionary *param = @{@"phone":_phoneNumberField.text, @"certno":smsNo, @"lang":lang};
    
    NSLog(@"AuthSms Request Parameter : %@", param);
    
    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
    
    // 로그인 요청
    [[SMNetworkClient sharedClient] postAuth:param
                                          block:^(NSDictionary *result, NSError *error) {
                                              
                                              NSLog(@"API(Auth) Result : \n%@", result);
                                              [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                                              
                                              if (error)
                                              {
                                                  NSLog(@"error ---- %@", [error localizedDescription]);
                                                  [[SMNetworkClient sharedClient] showNetworkError:error];
                                              }
                                              else
                                              {
                                                  // 휴대전화 로컬(파일) 저장.
                                                  if (phoneNumberStr.length > 0)
                                                  {
                                                      [[NSUserDefaults standardUserDefaults] setValue:phoneNumberStr forKey:kScode];
                                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                                      NSLog(@"휴대폰 암호화번호: %@", [[NSUserDefaults standardUserDefaults] objectForKey:kScode]);
                                                      
                                                      // 휴대폰 인증 끝나면 로그인 화면으로 이동.
                                                      LoginViewController *loginViewController = [[LoginViewController alloc] init];
                                                      
                                                      [self.navigationController pushViewController:loginViewController animated:YES];
                                                      
                                                  }
                                              }
                                              
                                          }];
}

- (void)requestAuthSms:(NSString *)phoneNumber
{
    NSString *lang = [UserContext shared].language;
    NSDictionary *param = @{@"phone":phoneNumber, @"lang":lang};
    
    NSLog(@"AuthSms Request Parameter : %@", param);
    
    [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
    
    // 로그인 요청
    [[SMNetworkClient sharedClient] postAuthSms:param
                                        block:^(NSDictionary *result, NSError *error) {
                                            
                                            NSLog(@"API(AuthSms) Result : \n%@", result);
                                            [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                                            
                                            if (error)
                                            {
                                                NSLog(@"error ---- %@", [error localizedDescription]);
                                                [[SMNetworkClient sharedClient] showNetworkError:error];
                                            }
                                            else
                                            {
                                                // 휴대폰 번호 기억
                                                phoneNumberStr = _phoneNumberField.text;
                                                NSLog(@"사용자 휴대폰번호: %@", phoneNumberStr);
                                            }
                                            
                                        }];
}
@end
