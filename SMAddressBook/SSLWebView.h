//
//  SSLWebView.h
//  SMAddressBook
//
//  Created by sochae on 13. 9. 30..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSLWebView;

@protocol SSLWebViewDelegate <NSObject>
@optional
- (BOOL)webView:(SSLWebView *)webView canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)webView:(SSLWebView *)webView didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)webView:(SSLWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
@end

@interface SSLWebView : UIWebView

@property (nonatomic, assign) id<SSLWebViewDelegate> _delegate;
@property (nonatomic, assign) BOOL isAuthed;

@end
