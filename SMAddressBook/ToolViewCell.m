//
//  ToolViewCell.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 22..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "ToolViewCell.h"
#import <UIImageView+AFNetworking.h>


@interface ToolViewCell ()

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *descLabel;

@end

@implementation ToolViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGFloat xOffset = 6.0f;
        CGFloat yOffset = 6.0f;
        
        // 프로필 사진
        _profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, yOffset, 40.0f, 40.0f)];
        _profileImageView.image = [UIImage imageNamed:@"placeholder"];
        
        [self.contentView addSubview:_profileImageView];
        xOffset += (_profileImageView.frame.size.width + xOffset);
        
        
        // 이름
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 200.0f, 18.0f)];
        _nameLabel.textColor = [UIColor darkGrayColor];
        _nameLabel.backgroundColor = [UIColor clearColor];
        [_nameLabel setFont:[UIFont systemFontOfSize:16.0f]];
        
        [self.contentView addSubview:_nameLabel];
        yOffset += 22.0f;
        
        
        // 설명
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 230.0f, 14.0f)];
        _descLabel.textColor = [UIColor lightGrayColor];
        _descLabel.backgroundColor = [UIColor clearColor];
        [_descLabel setFont:[UIFont systemFontOfSize:12.0f]];
        
        [self.contentView addSubview:_descLabel];

        
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkBtn.tag = 300;
        _checkBtn.frame = CGRectMake(self.frame.size.width - 30.0f, 15.0f, 21.0f, 22.0f);
        [_checkBtn setBackgroundImage:[UIImage imageNamed:@"join_agreebox"] forState:UIControlStateNormal];
        [_checkBtn setBackgroundImage:[UIImage imageNamed:@"join_agreebox_ch"] forState:UIControlStateSelected];
        [_checkBtn setBackgroundImage:[UIImage imageNamed:@"join_agreebox"] forState:UIControlStateDisabled];
        
        [_checkBtn addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_checkBtn];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setInfo:(NSDictionary *)info
{
    _info = info;

    if (_info[@"photourl"]) {
        [_profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _info[@"photourl"]]]
                          placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }

    if (_info[@"name"]) {
        _nameLabel.text = _info[@"name"];
    }
    
    NSString *infoString = [NSString stringWithFormat:@"[%@] %@ %@ %@", _info[@"status"], _info[@"company"], _info[@"department"], _info[@"title"]];
    _descLabel.text = infoString;
}

- (void)onBtnClicked:(id)sender
{
//    [(UIButton *)sender setSelected:![(UIButton *)sender isSelected]];
    NSLog(@"cell selected(%d)", [sender isSelected]);
    
//    if ([_delegate respondsToSelector:@selector(onCheckTouched:)]) {
//        [_delegate onCheckTouched:self];
//    }
}

@end
