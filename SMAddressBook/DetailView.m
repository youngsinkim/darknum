//
//  DetailView.m
//  SMAddressBook
//
//  Created by sochae on 13. 9. 14..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "DetailView.h"

@implementation DetailView
@synthesize name;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor magentaColor];
        {
            _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 100, 80.0f, 20.0f)];
            [_nameLabel setBackgroundColor:[UIColor clearColor]];
            [_nameLabel setTextColor:[UIColor darkGrayColor]];
            [_nameLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
            [_nameLabel setTextAlignment:NSTextAlignmentRight];
            [_nameLabel setText:@"이름"];
            
            [self addSubview:_nameLabel];
            
            _nameValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 100, 80.0f, 20.0f)];
            [_nameValueLabel setBackgroundColor:[UIColor clearColor]];
            [_nameValueLabel setTextColor:[UIColor grayColor]];
            [_nameValueLabel setFont:[UIFont systemFontOfSize:16.0f]];
            
            [self addSubview:_nameValueLabel];
            
//            _nameLabel.text = @"이름";
//            _nameValueLabel.text = info[@"name"];
            self.name = [NSString stringWithFormat:@""];
        }
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

- (void)setName:(NSString *)name
{
    _nameValueLabel.text = name;
}
@end
