//
//  StudentToolView.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 5..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kStudentToolH       60.0f


@class StudentToolView;

@protocol StudentToolViewDelegate <NSObject>

- (void)didSelectedToolTag:(NSNumber *)type;

/// SMS 버튼
- (void)onTouchedSmsBtn:(id)sender;

@end

@interface StudentToolView : UIView

@property id<StudentToolViewDelegate> delegate;

@end
