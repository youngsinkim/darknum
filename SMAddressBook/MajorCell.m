//
//  MajorCell.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "MajorCell.h"

@interface MajorCell ()

@property (strong, nonatomic) UILabel *majorLabel;

@end

@implementation MajorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGFloat xOffset = 15.0f;
        CGFloat yOffset = 11.0f;
        
        // 전공 text
        _majorLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 220.0f, 17.0f)];
        _majorLabel.textColor = UIColorFromRGB(0x142c6d);
        _majorLabel.backgroundColor = [UIColor clearColor];
        [_majorLabel setFont:[UIFont systemFontOfSize:14.0f]];
        
        [self.contentView addSubview:_majorLabel];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMajorText:(NSString *)majorText
{
    _majorText = majorText;
    
    _majorLabel.text = _majorText;
}

@end
