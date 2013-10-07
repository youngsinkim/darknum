//
//  FindWebViewController.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 10. 8..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindWebViewController : UIViewController <UIWebViewDelegate>

- (id)initWithUrl:(NSString *)url title:(NSString *)title;

@end
