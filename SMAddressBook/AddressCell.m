//
//  AddressCell.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 2..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "AddressCell.h"
#import <UIImageView+AFNetworking.h>

@interface AddressCell ()

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *emailLabel;
@property (strong, nonatomic) UILabel *descLabel; // 담당업무
@end

@implementation AddressCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        CGFloat xOffset = 0.0f;
        CGFloat yOffset = 0.0f;

        _cellType = AddressCellTypeNormal;
        
        // 프로필 사진
        UIImage *proImage = [UIImage imageNamed:@"ic_noimg_list"];
        _profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, yOffset, proImage.size.width, proImage.size.height)];
        _profileImageView.image = proImage;
        
        [self.contentView addSubview:_profileImageView];
        xOffset += (_profileImageView.frame.size.width + 10.0f);
        yOffset += 10.0f;

        
        // 이름 text
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor = UIColorFromRGB(0x333333);
        _nameLabel.backgroundColor = [UIColor clearColor];
        [_nameLabel setFont:[UIFont systemFontOfSize:14.0f]];
        
        [self.contentView addSubview:_nameLabel];
        yOffset += (_nameLabel.frame.size.height + 5.0f);
        

        // 설명
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.textColor = UIColorFromRGB(0x555555);
        _descLabel.backgroundColor = [UIColor clearColor];
        [_descLabel setFont:[UIFont systemFontOfSize:11.0f]];
        
        [self.contentView addSubview:_descLabel];
        yOffset += (_descLabel.frame.size.height + 1.0f);

        
        // 이메일
        _emailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _emailLabel.textColor = UIColorFromRGB(0x142c6d);
        _emailLabel.backgroundColor = [UIColor clearColor];
        [_emailLabel setFont:[UIFont systemFontOfSize:10.0f]];
        
        [self.contentView addSubview:_emailLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setCellInfo:(NSDictionary *)cellInfo
{
    _cellInfo = cellInfo;
    NSLog(@"주소록 셀 정보 : %@", _cellInfo);
    
    if (_cellInfo[@"photourl"]) {
//        [_profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://biz.snu.ac.kr/webdata%@", _cellInfo[@"photourl"]]]
        [_profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _cellInfo[@"photourl"]]]
                          placeholderImage:[UIImage imageNamed:@"ic_noimg_list"]];
    }
    
    if ([[UserContext shared].language isEqualToString:kLMKorean]) {
        if (_cellInfo[@"name"]) {
            _nameLabel.text = _cellInfo[@"name"];
        }
    } else {
        if (_cellInfo[@"name_en"]) {
            _nameLabel.text = _cellInfo[@"name_en"];
        }
    }
    
    if (_cellInfo[@"email"]) {
        _emailLabel.text = _cellInfo[@"email"];
    }

    if (_memType == MemberTypeStaff)
    {
        if ([[UserContext shared].language isEqualToString:kLMKorean]) {
            if (_cellInfo[@"work"]) {
                _descLabel.text = _cellInfo[@"work"];
            }
        } else {
            if (_cellInfo[@"work_en"]) {
                _descLabel.text = _cellInfo[@"work_en"];
            }
        }
    }
    else if (_memType == MemberTypeFaculty && _cellType == AddressCellTypeAllFaculty)
    {
        if ([[UserContext shared].language isEqualToString:kLMKorean]) {
            if (_cellInfo[@"major.title"]) {
                _descLabel.text = _cellInfo[@"major.title"];
            }
        } else {
            if (_cellInfo[@"major.title_en"]) {
                _descLabel.text = _cellInfo[@"major.title_en"];
            }
        }
    }
    else
    {
        _descLabel.text = @"";
    }
    
    
//    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect viewRect = self.bounds;
    CGFloat xOffset = 0.0f;
    CGFloat yOffset = 10.0f;
    
    // profile image
    xOffset += (_profileImageView.frame.size.width + 10.0f);

    CGFloat cellWidth = (viewRect.size.width - xOffset - 20.0f);

    _nameLabel.frame = CGRectMake(xOffset, 8.0f, 200.0f, 20.0f);
    _emailLabel.frame = CGRectMake(xOffset, 36.0f, 200.0f, 20.0f);
    
//    if (_memType == MemberTypeStaff)
    if ([_descLabel.text length] > 0)
    {
        if (_nameLabel.text.length > 0 && _descLabel.text.length > 0 && _emailLabel.text.length > 0)
        {
//            yOffset = 3.0f;
            _nameLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 16.0f);
            yOffset += 21.0f;
            _descLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 13.0f);
            yOffset += 14.0f;
            _emailLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 12.0f);
        }
        else if(_nameLabel.text.length > 0 && _descLabel.text.length > 0)
        {
            yOffset = 7.0f;
            _nameLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 16.0f);
            yOffset += 24.0f;
            _descLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 13.0f);
        }
        else if(_nameLabel.text.length > 0 && _emailLabel.text.length > 0) {
            yOffset = 7.0f;
            _nameLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 16.0f);
            yOffset += 24.0f;
            _emailLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 13.0f);
        }
    }
}

@end
