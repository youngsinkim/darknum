//
//  KakaoMessageViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 10. 6..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "KakaoMessageViewController.h"
#import "KakaoLinkCenter.h"

@interface KakaoMessageViewController ()

@property (strong, nonatomic) UITextView *messageView;
//@property (strong, nonatomic) UIButton *sendBtn;

@end

@implementation KakaoMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = LocalizedString(@"kakao message", @"카카오 메시지");
    if (!IS_LESS_THEN_IOS7) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    }

    CGRect viewFrame = self.view.bounds;
    CGFloat yOffset = 74.0f;
    
    if (IS_LESS_THEN_IOS7) {
        yOffset = 10.0f;
    }
    
    // 네비게이션 바 버튼
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel)];
    
    // 보내기 버튼
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0f, 0.0f, 49.0f, 30.0f);
    [button setTitle:LocalizedString(@"send", @"보내기") forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x0080FF) forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    //    [button setBackgroundImage:[[UIImage imageNamed:@"btn_white"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onSend) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    //    [barButtonItem setStyle:UIBarButtonItemStyleBordered];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onSend)];
//    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    // 메시지 텍스트필드
//    if (IS_LESS_THEN_IOS7) {
        _messageView = [[UITextView alloc] initWithFrame:CGRectMake(10, yOffset, viewFrame.size.width - 20.0f, 100.0f)];
//    } else {
//        NSTextStorage* textStorage = [[NSTextStorage alloc] initWithString:@"sss"];
//        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
//        [textStorage addLayoutManager:layoutManager];
//        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
//        [layoutManager addTextContainer:textContainer];
//        
//        _messageView = [[UITextView alloc] initWithFrame:CGRectMake(10, yOffset, viewFrame.size.width - 20.0f, 100.0f) textContainer:textContainer];
//    }
    _messageView.delegate = self;
    [_messageView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3f]];
    _messageView.keyboardType = UIKeyboardTypeDefault;
//    _messageView.contentMode = uitextfield
//    _messageField.background = [[UIImage imageNamed:@"input_text_border"] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
//    [_messageView setBorderStyle:UITextBorderStyleRoundedRect];
//    [_messageField setClearButtonMode:UITextFieldViewModeWhileEditing];
//    _messageView.placeholder = LocalizedString(@"카카오톡으로 전달할 메시지를 입력하셔 주세요.", @"카카오톡 전달 메시지");
//    [_messageView setTextColor:[UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f]];
//    [_messageView setTextAlignment:NSTextAlignmentLeft];
//    _messageView.contentSize = CGSizeMake(_messageView.frame.size.width, _messageView.frame.size.height);
//    [_messageView setFont:[UIFont systemFontOfSize:14.0f]];

//    [_messageField addTarget:self action:@selector(onCourseTextFieldTouched:) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:_messageView];
    [_messageView becomeFirstResponder];
    yOffset += 100.0f;

    // 메시진 전송 버튼
//    _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_sendBtn setFrame:CGRectMake((viewFrame.size.width - 100.0f) / 2.0f, yOffset, 100.0f, 26.0f)];
//    [_sendBtn setBackgroundImage:[[UIImage imageNamed:@"btn_white"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f] forState:UIControlStateNormal];
//    [_sendBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    [_sendBtn setTitle:@"검색" forState:UIControlStateNormal];
//    [_sendBtn addTarget:self action:@selector(onSearchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:_sendBtn];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - UI Control Events
- (void)onCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSend
{
    NSString *messageText = _messageView.text;
    if (messageText.length > 0)
    {
        if ([KakaoLinkCenter canOpenKakaoLink]) {
            [KakaoLinkCenter openKakaoLinkWithURL:@""
                                       appVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                      appBundleID:[[NSBundle mainBundle] bundleIdentifier]
                                          appName:@"주소록"//[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]
                                          message:messageText];
        } else {
            // kakao 없을 경우
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:LocalizedString(@"kakao not install", @"카카오톡 미설치") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [warningAlert show];

        }

    } else {
        // 메시지가 빈 경우
        
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:LocalizedString(@"message empty", @"빈 메시지") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [warningAlert show];

    }
}

#pragma mark - UITextView Delegates
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    NSLog(@"textViewShouldBeginEditing:");
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewDidBeginEditing:");
//    textView.backgroundColor = [UIColor greenColor];
    if (!IS_LESS_THEN_IOS7)
    {
        NSTextStorage* textStorage = [[NSTextStorage alloc] initWithString:textView.text];
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [textStorage addLayoutManager:layoutManager];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
        [layoutManager addTextContainer:textContainer];
        [_messageView removeFromSuperview];
        
        CGRect viewFrame = self.view.bounds;
        CGFloat yOffset = 74.0f;
        if (IS_LESS_THEN_IOS7) {
            
        }
        _messageView = [[UITextView alloc] initWithFrame:CGRectMake(10, yOffset, viewFrame.size.width - 20.0f, 100.0f) textContainer:textContainer];
        _messageView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
        _messageView.keyboardType = UIKeyboardTypeDefault;
        
        [self.view addSubview:_messageView];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    NSLog(@"textViewShouldEndEditing:");
//    textView.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"textViewDidEndEditing:");
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"shouldChangeTextInRange:");
    //textView에 어느 글을 쓰더라도 이 메소드를 호출합니다.
    if ([text isEqualToString:@"\n"]) {
        // return키를 누루면 원래 줄바꿈이 일어나므로 \n을 입력하는데 \n을 입력하면 실행하게 합니다.
        [textView resignFirstResponder]; //키보드를 닫는 메소드입니다.
        return FALSE; //리턴값이 FALSE이면, 입력한 값이 입력되지 않습니다.
    }
    return TRUE; //평소에 경우에는 입력을 해줘야 하므로, TRUE를 리턴하면 TEXT가 입력됩니다.
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textViewDidChange:");
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    NSLog(@"shouldInteractWithTextAttachment");
}


@end
