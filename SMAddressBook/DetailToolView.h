//
//  DetailToolView.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 13..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailToolView;

@protocol DetailToolViewDelegate <NSObject>

- (void)didSelectedToolTag:(NSNumber *)type;

@end


@interface DetailToolView : UIView

@property (weak) id<DetailToolViewDelegate> delegate;
@property (strong, nonatomic) UIButton *telBtn;
@property (strong, nonatomic) UIButton *smsBtn;
@property (strong, nonatomic) UIButton *emailBtn;
@property (strong, nonatomic) UIButton *saveBtn;
@property (strong, nonatomic) UIButton *kakaoBtn;

- (id)initWithFrame:(CGRect)frame type:(MemberType)type;

@end
