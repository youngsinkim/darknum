//
//  FavoriteCell.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 29..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FavoriteCell.h"
#import <QuartzCore/QuartzCore.h>
#import <UIImageView+AFNetworking.h>
#import "NSString+UrlEncoding.h"

@interface FavoriteCell ()

@property (strong, nonatomic) UIImageView *photoImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *countLabel;

@end

@implementation FavoriteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGFloat yOffset = 11.0f;
        CGFloat xOffset = 10.0f;
        
        // icon Image
        UIImage *iconImage = [UIImage imageNamed:@"ic_list_emba"];
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, yOffset, iconImage.size.width, iconImage.size.height)];
        _photoImageView.image = iconImage;
        
        [self.contentView addSubview:_photoImageView];
        yOffset -= 2.0f;

        // title text
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset + iconImage.size.width + 10.0f, yOffset, self.contentView.frame.size.width - xOffset * 2 + iconImage.size.width + 10.0f, 17.0f)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = UIColorFromRGB(0x142c6d);
        _titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _titleLabel.text = self.title;
        
        [self.contentView addSubview:_titleLabel];
        yOffset += 18.0f;
        
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset + iconImage.size.width + 10.0f, yOffset, self.contentView.frame.size.width - xOffset * 2 + iconImage.size.width + 10.0f, 14.0f)];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = UIColorFromRGB(0x444444);
        _countLabel.font = [UIFont systemFontOfSize:12.0f];
        _countLabel.text = @"0명의 학생이 있습니다";
        
        [self.contentView addSubview:_countLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setMemType:(NSInteger)type WidhCount:(NSInteger)count
{
    switch (type) {
        case 2:     // 교수(faculty)
            _countLabel.text = [NSString stringWithFormat:LocalizedString(@"%d faculty", nil), count];
            break;
        case 3:     // 교직원(staff)
            _countLabel.text = [NSString stringWithFormat:LocalizedString(@"%d staff", nil), count];
            break;
        default:    // 학생(student)
            _countLabel.text = [NSString stringWithFormat:LocalizedString(@"%d student", nil), count];
            break;
    }
}

- (void)setIconName:(NSString *)iconName
{
    _iconName = iconName;
    
    _photoImageView.image = [UIImage imageNamed:_iconName];
    [_photoImageView setNeedsDisplay];
}
@end
