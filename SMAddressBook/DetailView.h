//
//  DetailView.h
//  SMAddressBook
//
//  Created by sochae on 13. 9. 14..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailView : UIView

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *nameValueLabel;
@property (retain, nonatomic) NSString *name;

- (void)setName:(NSString *)name;

@end
