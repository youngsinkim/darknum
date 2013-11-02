//
//  TitleView.m
//  SMAddressBook
//
//  Created by 선옥 채 on 2013. 11. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "TitleView.h"

@interface TitleView ()

@property (strong, nonatomic) UILabel *titleLabel;

@end


@implementation TitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textColor = [UIColor grayColor];
//        _titleLabel.textColor = [UIColor colorWithRed:249.0f/255.0f green:215.0f/255.0f blue:89.0f/255.0f alpha:1.0f];
//        _titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_titleLabel];

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

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    _titleLabel.frame = self.bounds;
    _titleLabel.text = _title;
    
}

@end
