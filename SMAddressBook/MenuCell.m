//
//  MenuCell.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "MenuCell.h"
#import <QuartzCore/QuartzCore.h>

@interface MenuCell ()

@property (strong, nonatomic) UIImageView *iconImageView;

@end


@implementation MenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        CGFloat yOffset = 14.0f;
        CGFloat xOffset = 10.0f;
        
        self.backgroundColor = UIColorFromRGB(0x2b2e31);

        // icon
        UIImage *icon = [UIImage imageNamed:@"ic_mf_smba.png"];
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, yOffset, icon.size.width, icon.size.height)];
        _iconImageView.image = icon;
//        _iconImageView.contentMode = UIViewContentModeCenter;// UIViewContentModeTopLeft;
        
        [self.contentView addSubview:_iconImageView];

        
        // 텍스트
//        self.textLabel.textColor = [UIColor colorWithRed:190.0f/255.0f green:197.0f/255.0f blue:212.0f/255.0f alpha:1.0f];
//        self.textLabel.highlightedTextColor = self.textLabel.textColor;
//        self.textLabel.shadowColor = [UIColor colorWithRed:33.0f/255.0f green:38.0f/255.0f blue:49.0f/255.0f alpha:1.0f];
//        self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
//        self.textLabel.backgroundColor = [UIColor clearColor];
//        self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
        _menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(_iconImageView.frame.origin.x + _iconImageView.frame.size.width + 12.0f, yOffset, 200.0f, 16.0f)];
        [_menuLabel setFont:[UIFont systemFontOfSize:13.0f]];
        _menuLabel.textColor = UIColorFromRGB(0xccd3e6);
        _menuLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:_menuLabel];
        
        // 섹션 라인 (imsi)
//        NSLog(@"세션 높이 : %f", self.contentView.frame.size.height);
//        UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.contentView.bounds.size.height - 1, self.contentView.frame.size.width, 1.0f)];
//        UILabel *lineV = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.contentView.bounds.size.height - 3, self.contentView.bounds.size.width, 0.3f)];
//        lineV.backgroundColor = UIColorFromRGB(0x464646);
//        lineV.backgroundColor = [UIColor colorWithRed:56.0f/255.0f green:60.0f/255.0f blue:64.0f/255.0f alpha:1.0f];
//        [lineV.layer setCornerRadius:1.0f];
//        [lineV.layer setBorderColor:[UIColor colorWithRed:30.0f/255.0f green:32.0f/255.0f blue:34.0f/255.0f alpha:1.0f].CGColor];
//        [lineV.layer setBorderWidth:1.0f];

//        [self.contentView addSubview:lineV];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIconName:(NSString *)iconName
{
    _iconName = iconName;
    if (_iconName.length > 0)
    {
        _iconImageView.image = [UIImage imageNamed:_iconName];
        [_iconImageView setNeedsDisplay];
        
        if ([_iconName isEqualToString:@"ic_mf_all"]) {
            _menuLabel.textColor = UIColorFromRGB(0xcd5734);
        }
    }
}

//- (void)setCellInfo:(NSDictionary *)cellInfo
//{
//    _cellInfo = cellInfo;
//    
//    _iconImageView.image = [UIImage imageNamed:_cellInfo[@"icon"]];
//    [_iconImageView setNeedsDisplay];
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    if ([_menuLabel.text isEqualToString:LocalizedString(@"Member List", @"전체보기")]) {
//        _menuLabel.textColor = UIColorFromRGB(0x000000);
//    } else {
//        _menuLabel.textColor = UIColorFromRGB(0xccd3e6);
//    }
}
@end
