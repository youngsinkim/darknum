//
//  SSLWebView.m
//  SMAddressBook
//
//  Created by sochae on 13. 9. 30..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "SSLWebView.h"

@interface UIWebView()

- (BOOL)webView:(id)arg1 resource:(id)arg2 canAuthenticateAgainstProtectionSpace:(id)arg3 forDataSource:(id)arg4;
- (void)webView:(id)arg1 resource:(id)arg2 didCancelAuthenticationChallenge:(id)arg3 fromDataSource:(id)arg4;
- (void)webView:(id)arg1 resource:(id)arg2 didReceiveAuthenticationChallenge:(id)arg3 fromDataSource:(id)arg4;
- (void)webView:(id)arg1 resource:(id)arg2 didFailLoadingWithError:(id)arg3 fromDataSource:(id)arg4;
- (void)webView:(id)arg1 resource:(id)arg2 didFinishLoadingFromDataSource:(id)arg3;

- (id)webView:(id)arg1 resource:(id)arg2 willSendRequest:(id)arg3 redirectResponse:(id)arg4 fromDataSource:(id)arg5;
- (id)webView:(id)arg1 connectionPropertiesForResource:(id)arg2 dataSource:(id)arg3;

@end

@implementation SSLWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//- (BOOL)webView:(SSLWebView *)webView canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
//- (void)webView:(SSLWebView *)webView didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
//- (void)webView:(SSLWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end
