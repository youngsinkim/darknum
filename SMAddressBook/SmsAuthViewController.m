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

/// 본인인증 화면 UI
- (void)setupUI
{
    CGRect rect = self.view.frame;
    CGFloat yOffset = 30.0f;
    CGFloat xOffset = 24.0f;
    
    // 본인인증 안내 문구
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, yOffset, rect.size.width - (10.0f * 2), 30.0f)];
    [_infoLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_infoLabel setNumberOfLines:0];
    [_infoLabel setFont:[UIFont systemFontOfSize:13.0f]];
    _infoLabel.textColor = UIColorFromRGB(0x333333);
    _infoLabel.textAlignment = NSTextAlignmentCenter;
    _infoLabel.backgroundColor = [UIColor clearColor];
    _infoLabel.text = LocalizedString(@"Athentication Description", @"본인인증 안내");
    
    [self.view addSubview:_infoLabel];
    yOffset += (_infoLabel.frame.size.height + 5.0f);
    

    // 휴대전화번호
    _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, rect.size.width - (xOffset * 2), 15.0f)];
    [_phoneLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_phoneLabel setNumberOfLines:0];
    [_phoneLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    _phoneLabel.textColor = UIColorFromRGB(0x142c6d);
    _phoneLabel.backgroundColor = [UIColor clearColor];
    _phoneLabel.text = LocalizedString(@"cell phone no.", @"휴대전화번호");
    
    [self.view addSubview:_phoneLabel];
    yOffset += (_phoneLabel.frame.size.height + 3.0f);

    
    // 전화번호 text
    UIImage *inputBgImage = [UIImage imageNamed:@"t_field"];
    _phoneNumberField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, yOffset, inputBgImage.size.width, inputBgImage.size.height)];
    _phoneNumberField.delegate = self;
    [_phoneNumberField setBackground:inputBgImage];
    [_phoneNumberField setTextColor:UIColorFromRGB(0x404040)];
    [_phoneNumberField setReturnKeyType:UIReturnKeyNext];
    [_phoneNumberField setKeyboardType:UIKeyboardTypePhonePad];
    [_phoneNumberField setFont:[UIFont systemFontOfSize:13.0f]];
    [_phoneNumberField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, inputBgImage.size.height)];
        [_phoneNumberField setLeftView:paddingView];
        [_phoneNumberField setLeftViewMode:UITextFieldViewModeAlways];
    }
//    _phoneNumberField.placeholder = LocalizedString(@"user_id_placeholder", @"휴대전화번호");
//    _phoneNumberField.text = @"01023873856";// @"01025578458";
//    [_phoneNumberField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//    _phoneNumberField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [self.view addSubview:_phoneNumberField];
    
    
    // 인증번호받기 button
    UIImage *btnImage = [UIImage imageNamed:@"btn_cyan"];
    _smsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _smsBtn.frame = CGRectMake(_phoneNumberField.frame.origin.x + _phoneNumberField.frame.size.width + 4.0f, yOffset, btnImage.size.width, btnImage.size.height);
    [_smsBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
    [_smsBtn setTitle:LocalizedString(@"Send Verification Code", @"인증번호받기") forState:UIControlStateNormal];
    [_smsBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [_smsBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [_smsBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_smsBtn addTarget:self action:@selector(onSmsBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_smsBtn];
    yOffset += (_phoneNumberField.frame.size.height + 20.0f);
    
    
    // 인증번호
    _authLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, rect.size.height - (xOffset * 2), 15.0f)];
    [_authLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_authLabel setNumberOfLines:0];
    [_authLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    _authLabel.textColor = UIColorFromRGB(0x142c6d);
    _authLabel.backgroundColor = [UIColor clearColor];
    _authLabel.text = LocalizedString(@"Verification code", @"인증번호");
    
    [self.view addSubview:_authLabel];
    yOffset += (_authLabel.frame.size.height + 3.0f);
    
    
    // 전화번호 입력창
    _smsNumberField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, yOffset, inputBgImage.size.width, inputBgImage.size.height)];
    _smsNumberField.delegate = self;
    [_smsNumberField setBackground:inputBgImage];
    [_smsNumberField setTextColor:UIColorFromRGB(0x404040)];
    [_smsNumberField setReturnKeyType:UIReturnKeyDone];
    [_smsNumberField setKeyboardType:UIKeyboardTypeNumberPad];
    [_smsNumberField setFont:[UIFont systemFontOfSize:13.0f]];
    [_smsNumberField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, inputBgImage.size.height)];
        [_smsNumberField setLeftView:paddingView];
        [_smsNumberField setLeftViewMode:UITextFieldViewModeAlways];
    }
    
    [self.view addSubview:_smsNumberField];

    
    // 확인 button
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmBtn.frame = CGRectMake(_smsNumberField.frame.origin.x + _smsNumberField.frame.size.width + 4.0f, yOffset, btnImage.size.width, btnImage.size.height);
    [_confirmBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
    [_confirmBtn setTitle:LocalizedString(@"Submit", @"확인") forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [_confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [_confirmBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_confirmBtn addTarget:self action:@selector(onConfirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_confirmBtn];

    // 2014-1-11, 인증번호 확인 버튼은 인증번호 받기가 정상동작하면 활성화한다.
    [_confirmBtn setEnabled:NO];

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [super touchesBegan:touches withEvent:event];
    NSLog(@"Touched!");
//    [textField resignFirstResponder];
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
    }
    
    if ([_smsNumberField isFirstResponder]) {
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
    if ([_phoneNumberField isFirstResponder]) {
        [_phoneNumberField resignFirstResponder];
    }
    
    if ([_smsNumberField isFirstResponder]) {
        [_smsNumberField resignFirstResponder];
    }

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
//                                                  phoneNumberStr = _phoneNumberField.text;

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

                                                [_confirmBtn setEnabled:YES];
                                            }
                                            
                                        }];
}
@end
