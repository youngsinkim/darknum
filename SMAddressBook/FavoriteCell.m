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
        self.backgroundColor = [UIColor clearColor];
        
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 26, 27)];
        _photoImageView.image = [UIImage imageNamed:@"profile_noimg"];
//        [_photoImageView.layer setCornerRadius:2.0f];
//        _photoImageView.contentScaleFactor = 1.0f;
//        _photoImageView.contentMode = UIViewContentModeCenter;
        
        [self.contentView addSubview:_photoImageView];
        
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(47, 8, 180, 20)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = UIColorFromRGB(0x323C73);
        _titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _titleLabel.text = self.title;
        
        [self.contentView addSubview:_titleLabel];
        
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(47, 25, 270, 20)];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = [UIColor grayColor];
        _countLabel.font = [UIFont systemFontOfSize:10.0f];
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
