//
//  DetailViewCell.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 9..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "DetailViewCell.h"
#import <UIImageView+AFNetworking.h>

@interface DetailViewCell ()



@end

@implementation DetailViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blueColor];
        
        _profileImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_profileImage setImage:[UIImage imageNamed:@"placeholder"]];
        
        [self addSubview:_profileImage];
        
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setTextColor:[UIColor darkGrayColor]];
        [_nameLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_nameLabel setTextAlignment:NSTextAlignmentRight];
        [_nameLabel setText:@"이름"];
        
        [self addSubview:_nameLabel];

        
        _nameValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_nameValueLabel setBackgroundColor:[UIColor clearColor]];
        [_nameValueLabel setTextColor:[UIColor grayColor]];
        [_nameValueLabel setFont:[UIFont systemFontOfSize:16.0f]];
//        _nameValueLabel.clipsToBounds = YES;
//        _nameValueLabel.opaque = YES;
//        _nameValueLabel.layer.masksToBounds = NO;
//        _nameValueLabel.layer.opaque = YES;

        
        [self addSubview:_nameValueLabel];

        
        _classLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_classLabel setBackgroundColor:[UIColor clearColor]];
        [_classLabel setTextColor:[UIColor darkGrayColor]];
        [_classLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_classLabel setTextAlignment:NSTextAlignmentRight];
        [_classLabel setText:@"기수"];
        
        [self addSubview:_classLabel];
        
        
        _classValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_classValueLabel setBackgroundColor:[UIColor clearColor]];
        [_classValueLabel setTextColor:[UIColor grayColor]];
        [_classValueLabel setFont:[UIFont systemFontOfSize:16.0f]];
        
        [self addSubview:_classValueLabel];

        
        _majorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_majorLabel setBackgroundColor:[UIColor clearColor]];
        [_majorLabel setTextColor:[UIColor darkGrayColor]];
        [_majorLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_majorLabel setTextAlignment:NSTextAlignmentRight];
        [_majorLabel setText:@"전공"];
        
        [self addSubview:_majorLabel];
        
        
        _majorValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_majorValueLabel setBackgroundColor:[UIColor clearColor]];
        [_majorValueLabel setTextColor:[UIColor grayColor]];
        [_majorValueLabel setFont:[UIFont systemFontOfSize:16.0f]];
        
        [self addSubview:_nameValueLabel];

        
        _telLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_telLabel setBackgroundColor:[UIColor clearColor]];
        [_telLabel setTextColor:[UIColor darkGrayColor]];
        [_telLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_telLabel setTextAlignment:NSTextAlignmentRight];
        [_telLabel setText:@"전화"];

        [self addSubview:_telLabel];
        
        
        _telValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_telValueLabel setBackgroundColor:[UIColor clearColor]];
        [_telValueLabel setTextColor:[UIColor grayColor]];
        [_telValueLabel setFont:[UIFont systemFontOfSize:16.0f]];
        
        [self addSubview:_telValueLabel];

        
        _mobileLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_mobileLabel setBackgroundColor:[UIColor clearColor]];
        [_mobileLabel setTextColor:[UIColor darkGrayColor]];
        [_mobileLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_mobileLabel setTextAlignment:NSTextAlignmentRight];
        [_mobileLabel setText:@"휴대폰"];

        [self addSubview:_mobileLabel];
        
        
        _mobileValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_mobileValueLabel setBackgroundColor:[UIColor clearColor]];
        [_mobileValueLabel setTextColor:[UIColor grayColor]];
        [_mobileValueLabel setFont:[UIFont systemFontOfSize:16.0f]];
        
        [self addSubview:_mobileValueLabel];

        
        _emailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_emailLabel setBackgroundColor:[UIColor clearColor]];
        [_emailLabel setTextColor:[UIColor darkGrayColor]];
        [_emailLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_emailLabel setTextAlignment:NSTextAlignmentRight];
        [_emailLabel setText:@"이메일"];

        [self addSubview:_emailLabel];
        
        
        _emailValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_emailValueLabel setBackgroundColor:[UIColor clearColor]];
        [_emailValueLabel setTextColor:[UIColor grayColor]];
        [_emailValueLabel setFont:[UIFont systemFontOfSize:16.0f]];
        
        [self addSubview:_emailValueLabel];

        
        _officeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_officeLabel setBackgroundColor:[UIColor clearColor]];
        [_officeLabel setTextColor:[UIColor darkGrayColor]];
        [_officeLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_officeLabel setTextAlignment:NSTextAlignmentRight];
        [_officeLabel setText:@"사무실"];

        [self addSubview:_officeLabel];
        
        
        _officeValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_officeValueLabel setBackgroundColor:[UIColor clearColor]];
        [_officeValueLabel setTextColor:[UIColor grayColor]];
        [_officeValueLabel setFont:[UIFont systemFontOfSize:16.0f]];
        
        [self addSubview:_officeValueLabel];

        
        _companyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_companyLabel setBackgroundColor:[UIColor clearColor]];
        [_companyLabel setTextColor:[UIColor darkGrayColor]];
        [_companyLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_companyLabel setTextAlignment:NSTextAlignmentRight];
        [_companyLabel setText:@"소속"];

        [self addSubview:_companyLabel];
        
        
        _companyValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_companyValueLabel setBackgroundColor:[UIColor clearColor]];
        [_companyValueLabel setTextColor:[UIColor grayColor]];
        [_companyValueLabel setFont:[UIFont systemFontOfSize:16.0f]];
        
        [self addSubview:_companyValueLabel];

        int tag = 500;
        for (int idx = 0; idx < 5; idx++)
        {
            UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 200 + (idx * 24.0f), 280.0f, 1.0f)];
            line.tag = (tag + idx);
            line.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:1.0f];
            
            [self addSubview:line];
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

- (void)setMemType:(MemberType)memType
{
    _memType = memType;
    
    [self layoutSubviews];
}

- (void)setCellInfo:(NSDictionary *)cellInfo
{
    _cellInfo = cellInfo;
    NSLog(@"셀 정보: %@", _cellInfo[@"name_en"]);
 
//    [self layoutSubviews];


    if (_memType == MemberTypeFaculty)
    {
        
    }
    else if (_memType == MemberTypeStaff)
    {
        
    }
    else if (_memType == MemberTypeStudent)
    {
//        if (_cellInfo[@"photourl"]) {
//            NSLog(@"프로필 이미지 : %@", _cellInfo[@"photourl"]);
//            [_profileImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _cellInfo[@"photourl"]]]
//                          placeholderImage:[UIImage imageNamed:@"placeholder"]];
//        }
//        
//        if (_cellInfo[@"name"]) {
//            _nameValueLabel.text = _cellInfo[@"name"];
//        }
        
        if (_cellInfo[@"email"]) {
            _emailLabel.text = _cellInfo[@"email"];
        }
    }
    
    if (_cellInfo[@"photourl"]) {
        NSLog(@"프로필 이미지 : %@", _cellInfo[@"photourl"]);
        [_profileImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _cellInfo[@"photourl"]]]
                      placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    if (_cellInfo[@"name"]) {
        _nameValueLabel.text = _cellInfo[@"name"];
    }
    
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // 멤버 타입별로 셀 내용 다르게 노출
    CGFloat yOffset = 200.0f;
//    int tag = 500;
//    CGFloat yy = yOffset;// 100.0f + (20.0f * idx);
    
    if (_memType == MemberTypeFaculty)
    {
        _profileImage.frame = CGRectMake(0.0f, 50.0f, 320.0f, 150.0f);
        _nameLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        _nameValueLabel.frame = CGRectMake(100.0f, yOffset, 80.0f, 20.0f);
        yOffset += 24.0f;
        _majorLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        yOffset += 24.0f;
        _telLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        yOffset += 24.0f;
        _mobileLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        yOffset += 24.0f;
        _emailLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        yOffset += 24.0f;
        _officeLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        
    }
    else if (_memType == MemberTypeStaff)
    {
        _profileImage.frame = CGRectMake(0.0f, 50.0f, 320.0f, 150.0f);
        _nameLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        _nameValueLabel.frame = CGRectMake(100.0f, yOffset, 80.0f, 20.0f);
        yOffset += 24.0f;
    }
    else if (_memType == MemberTypeStudent)
    {
        _profileImage.frame = CGRectMake(0.0f, 50.0f, 320.0f, 150.0f);
        _nameLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        _nameValueLabel.frame = CGRectMake(100.0f, yOffset, 80.0f, 20.0f);
        yOffset += 23.0f;
//        _majorLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
//        yOffset += 23.0f;
//        _telLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
//        yOffset += 23.0f;
//        _mobileLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
//        yOffset += 23.0f;
//        _emailLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
//        yOffset += 23.0f;
//        _officeLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
    }
}
@end
