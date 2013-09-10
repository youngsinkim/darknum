//
//  DetailViewCell.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 9..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "DetailViewCell.h"

@interface DetailViewCell ()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *nameValueLabel;
@property (strong, nonatomic) UILabel *classLabel;
@property (strong, nonatomic) UILabel *classValueLabel;
@property (strong, nonatomic) UILabel *majorLabel;
@property (strong, nonatomic) UILabel *majorValueLabel;
@property (strong, nonatomic) UILabel *telLabel;
@property (strong, nonatomic) UILabel *telValueLabel;
@property (strong, nonatomic) UILabel *mobileLabel;
@property (strong, nonatomic) UILabel *mobileValueLabel;
@property (strong, nonatomic) UILabel *emailLabel;
@property (strong, nonatomic) UILabel *emailValueLabel;
@property (strong, nonatomic) UILabel *officeLabel;
@property (strong, nonatomic) UILabel *officeValueLabel;
@property (strong, nonatomic) UILabel *companyLabel;
@property (strong, nonatomic) UILabel *companyValueLabel;

@end

@implementation DetailViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
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
            UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 200 + (idx * 22.0f), 280.0f, 1.0f)];
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
    NSLog(@"셀 정보: %@", _cellInfo);
    
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // 멤버 타입별로 셀 내용 다르게 노출
    CGFloat yOffset = 200.0f;
    int tag = 500;
    CGFloat yy = yOffset;// 100.0f + (20.0f * idx);
    
    if (_memType == MemberTypeFaculty)
    {
        for (int idx = 0; idx < 5; idx++)
        {
            UILabel *line = (UILabel *)[self viewWithTag:tag];
                yy += 30.0f;
                NSLog(@"yy = %f", yy);
                line.frame = CGRectMake(20.0f, yOffset + (idx * 24.0f) , 280.0f, 1.0f);
        }
        
        _nameLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        yOffset += 23.0f;
        _majorLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        yOffset += 23.0f;
        _telLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        yOffset += 23.0f;
        _mobileLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        yOffset += 23.0f;
        _emailLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        yOffset += 23.0f;
        _officeLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        
    }
    else if (_memType == MemberTypeStaff)
    {
        
    }
    else if (_memType == MemberTypeStudent)
    {
        
    }
}
@end
