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
@property (strong, nonatomic) UILabel *emailLabel;

@end

@implementation ToolViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _memType = MemberTypeStudent;
        _cellType = ToolViewCellTypeNormal;

        // Initialization code
        CGFloat xOffset = 0.0f;
        CGFloat yOffset = 0.0f;
        
        // 프로필 사진
        UIImage *proImage = [UIImage imageNamed:@"ic_noimg_list"];
        _profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, yOffset, proImage.size.width, proImage.size.height)];
        _profileImageView.image = proImage;
        
        [self.contentView addSubview:_profileImageView];
        xOffset += (_profileImageView.frame.size.width + 10.0f);
        yOffset += 6.0f;
        
        
        // 이름
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 220.0f, 17.0f)];
        _nameLabel.textColor = UIColorFromRGB(0x333333);
        _nameLabel.backgroundColor = [UIColor clearColor];
        [_nameLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        
        [self.contentView addSubview:_nameLabel];
        yOffset += (_nameLabel.frame.size.height + 5.0f);
        
        
        // 설명
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 220.0f, 13.0f)];
        _descLabel.textColor = UIColorFromRGB(0x555555);
        _descLabel.backgroundColor = [UIColor clearColor];
        [_descLabel setFont:[UIFont systemFontOfSize:12.0f]];
        
        [self.contentView addSubview:_descLabel];
        yOffset += (_descLabel.frame.size.height + 2.0f);

        
        _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 220.0f, 12.0f)];
        _emailLabel.textColor = UIColorFromRGB(0x142c6d);
        _emailLabel.backgroundColor = [UIColor clearColor];
        [_emailLabel setFont:[UIFont systemFontOfSize:10.0f]];
        
        [self.contentView addSubview:_emailLabel];

        
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkBtn.tag = 300;
        _checkBtn.frame = CGRectMake(self.frame.size.width - 30.0f, 24.0f,30.0f, 30.0f);
        [_checkBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
        [_checkBtn setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateSelected];
        [_checkBtn setImage:[UIImage imageNamed:@"check_disable"] forState:UIControlStateDisabled];
        [_checkBtn setImage:[UIImage imageNamed:@"check_disable"] forState:UIControlStateSelected|UIControlStateDisabled];
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
                          placeholderImage:[UIImage imageNamed:@"ic_noimg_list"]];
    }

    if ([[UserContext shared].language isEqualToString:kLMKorean]) {
        if (_info[@"name"]) {
            _nameLabel.text = _info[@"name"];
        }
    }
    else {
        if (_info[@"name_en"]) {
            _nameLabel.text = _info[@"name_en"];
        }
    }

    // 이메일
    if (_info[@"email"]) {
        _emailLabel.text = _info[@"email"];
        NSLog(@"이메일 : %@", _emailLabel.text);
    }

    //
    if (_memType == MemberTypeStudent)
    {
        if ([_info[@"share_email"] isEqualToString:@"y"]) {
            _emailLabel.hidden = NO;
        } else {
            _emailLabel.hidden = YES;
        }

        if ([[UserContext shared].language isEqualToString:kLMKorean])
        {
            if ([_info[@"company"] length] > 0 && [_info[@"department"] length] > 0) {
                NSString *description = [NSString stringWithFormat:@"%@ | %@ %@", _info[@"company"], _info[@"department"], _info[@"title"]];
                _descLabel.text = description;
            }
            else {
                _descLabel.text = @"";
            }
        }
        else {
            if ([_info[@"company_en"] length] > 0 && [_info[@"department_en"] length] > 0) {
                NSString *description = [NSString stringWithFormat:@" %@ | %@ %@", _info[@"company_en"], _info[@"department_en"], _info[@"title_en"]];
                _descLabel.text = description;
            }
            else {
                _descLabel.text = @"";
            }
        }
    }
    else if (_memType == MemberTypeFaculty)
    {
        if (_cellType == ToolViewCellTypeAllFaculty) {
            if ([[UserContext shared].language isEqualToString:kLMKorean]) {
                _descLabel.text = _info[@"major.title"];
            }
            else {
                _descLabel.text = _info[@"major.title_en"];
            }
        }
    }
    else if (_memType == MemberTypeStaff)
    {
        if ([[UserContext shared].language isEqualToString:kLMKorean])
        {
            _descLabel.text = _info[@"work"];
        }
        else
        {
            _descLabel.text = _info[@"work_en"];
        }
    }
    else {
        _descLabel.text = @"";
    }

    [self layoutSubviews];

//    _checkBtn.enabled = NO;
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
