//
//  UIViewController+LoadingProgress.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 31..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (LoadingProgress)

- (void)startLoading;
- (void)stopLoading;

- (void)startDimLoading;
- (void)stopDimLoading;

@end
