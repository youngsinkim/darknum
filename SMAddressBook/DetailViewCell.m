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

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *classTitleLabel;
@property (strong, nonatomic) UILabel *companyLabel;
@property (strong, nonatomic) UILabel *mobileLabel;
@property (strong, nonatomic) UILabel *mobileValueLabel;

@property (strong, nonatomic) UILabel *majorLabel;
@property (strong, nonatomic) UILabel *majorValueLabel;
@property (strong, nonatomic) UILabel *telLabel;
@property (strong, nonatomic) UILabel *telValueLabel;
@property (strong, nonatomic) UILabel *emailLabel;
@property (strong, nonatomic) UILabel *emailValueLabel;
@property (strong, nonatomic) UILabel *officeLabel;
@property (strong, nonatomic) UILabel *officeValueLabel;
@property (strong, nonatomic) UILabel *workLabel;
@property (strong, nonatomic) UILabel *workValueLabel;


@end

@implementation DetailViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
        
        _profileImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_profileImage setImage:[UIImage imageNamed:@"placeholder"]];
        [_profileImage setContentMode:UIViewContentModeScaleAspectFit];
        [_profileImage setBackgroundColor:[UIColor whiteColor]];
        
        [self addSubview:_profileImage];
        

        // 이름
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setTextColor:UIColorFromRGB(0x142c6d)];
        [_nameLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
        [_nameLabel setTextAlignment:NSTextAlignmentLeft];
//        _nameLabel.clipsToBounds = YES;
//        _nameLabel.opaque = YES;
//        _nameLabel.layer.masksToBounds = NO;
//        _nameLabel.layer.opaque = YES;

        [self addSubview:_nameLabel];
        
        
        // 상태 (재학/졸업)
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_statusLabel setBackgroundColor:UIColorFromRGB(0x669900)];
        [_statusLabel setTextColor:[UIColor whiteColor]];
        [_statusLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_statusLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self addSubview:_statusLabel];
        _statusLabel.hidden = YES;
        
        
        // 기수
        _classTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_classTitleLabel setBackgroundColor:[UIColor clearColor]];
        [_classTitleLabel setTextColor:UIColorFromRGB(0x669900)];
        [_classTitleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [_classTitleLabel setTextAlignment:NSTextAlignmentLeft];
        
        [self addSubview:_classTitleLabel];

        
        // 직장
        _companyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_companyLabel setBackgroundColor:[UIColor clearColor]];
        [_companyLabel setTextColor:UIColorFromRGB(0x555555)];
        [_companyLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [_companyLabel setTextAlignment:NSTextAlignmentLeft];
        
        [self addSubview:_companyLabel];

        
        // 모바일 텍스트
        _mobileLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_mobileLabel setBackgroundColor:[UIColor clearColor]];
        [_mobileLabel setTextColor:UIColorFromRGB(0x46515f)];
        [_mobileLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_mobileLabel setTextAlignment:NSTextAlignmentLeft];
        [_mobileLabel setText:@"Mobile Phone"];
        
        [self addSubview:_mobileLabel];
        
        
        // 모바일
        _mobileValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_mobileValueLabel setBackgroundColor:[UIColor clearColor]];
        [_mobileValueLabel setTextColor:UIColorFromRGB(0x555555)];
        [_mobileValueLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [_mobileValueLabel setTextAlignment:NSTextAlignmentLeft];
        
        [self addSubview:_mobileValueLabel];
        
        
        // 이메일 텍스트
        _emailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_emailLabel setBackgroundColor:[UIColor clearColor]];
        [_emailLabel setTextColor:UIColorFromRGB(0x46515f)];
        [_emailLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_emailLabel setTextAlignment:NSTextAlignmentLeft];
        [_emailLabel setText:@"E - Mail"];
        
        [self addSubview:_emailLabel];
        
        
        // 이메일
        _emailValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_emailValueLabel setBackgroundColor:[UIColor clearColor]];
        [_emailValueLabel setTextColor:UIColorFromRGB(0x555555)];
        [_emailValueLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [_emailValueLabel setTextAlignment:NSTextAlignmentLeft];
        
        [self addSubview:_emailValueLabel];
        

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
        
        [self addSubview:_majorValueLabel];

        
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

        
        _workLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_workLabel setBackgroundColor:[UIColor clearColor]];
        [_workLabel setTextColor:[UIColor darkGrayColor]];
        [_workLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_workLabel setTextAlignment:NSTextAlignmentRight];
        [_workLabel setText:@"담당업무"];
        
        [self addSubview:_workLabel];
        
        
        _workValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_workValueLabel setBackgroundColor:[UIColor clearColor]];
        [_workValueLabel setTextColor:[UIColor grayColor]];
        [_workValueLabel setFont:[UIFont systemFontOfSize:16.0f]];
        
        [self addSubview:_workValueLabel];


//        int tag = 500;
//        for (int idx = 0; idx < 5; idx++)
//        {
//            UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 200 + (idx * 24.0f), 280.0f, 1.0f)];
//            line.tag = (tag + idx);
//            line.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:1.0f];
//            
//            [self addSubview:line];
//        }
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
 
    // 프로필 사진
    if (_cellInfo[@"viewphotourl"]) {
        NSLog(@"프로필 이미지 : %@", _cellInfo[@"viewphotourl"]);
        [_profileImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _cellInfo[@"viewphotourl"]]]
                      placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    // 이름 표시 (국문 / 영문)
    if ([[UserContext shared].language isEqualToString:kLMKorean]) {
        if (_cellInfo[@"name"]) {
            _nameLabel.text = _cellInfo[@"name"];
        }
    } else {
        if (_cellInfo[@"name_en"]) {
            _nameLabel.text = _cellInfo[@"name_en"];
        }
    }

    // 이메일 표시
    if (_cellInfo[@"email"]) {
        _emailValueLabel.text = _cellInfo[@"email"];
    }

    // 모바일 표시
    if (_cellInfo[@"mobile"]) {
        _mobileValueLabel.text = _cellInfo[@"mobile"];
    }
    
    // 로그인 유저 타입
    MemberType myType = (MemberType)[[[UserContext shared] memberType] integerValue];

    if (_memType == MemberTypeStudent)
    {
        if (_cellInfo[@"status"]) {
            _statusLabel.text = _cellInfo[@"status"];
        }
        
        if (_cellInfo[@"classtitle"]) {
            _classTitleLabel.text = _cellInfo[@"classtitle"];
        }
        
        NSMutableString *descString = [NSMutableString stringWithFormat:@""];
        if ([[UserContext shared].language isEqualToString:kLMKorean]) {
            if (_cellInfo[@"company"]) {
                [descString appendString:_cellInfo[@"company"]];
            }
            
            if (_cellInfo[@"department"]) {
                if (descString.length > 0) {
                    [descString appendFormat:@" "];
                }
                [descString appendString:_cellInfo[@"department"]];
            }
            
            if (_cellInfo[@"title"]) {
                if (descString.length > 0) {
                    [descString appendFormat:@" "];
                }
                [descString appendString:_cellInfo[@"title"]];
            }
        } else {
            if (_cellInfo[@"company_en"]) {
                [descString appendString:_cellInfo[@"company_en"]];
            }
            
            if (_cellInfo[@"department_en"]) {
                if (descString.length > 0) {
                    [descString appendFormat:@" "];
                }
                [descString appendString:_cellInfo[@"department_en"]];
            }
            
            if (_cellInfo[@"title_en"]) {
                if (descString.length > 0) {
                    [descString appendFormat:@" "];
                }
                [descString appendString:_cellInfo[@"title_en"]];
            }
        }
        _companyLabel.text = descString;
        if ([_cellInfo[@"share_company"] isEqualToString:@"y"] || myType != MemberTypeStudent) {
            _companyLabel.hidden = NO;
        } else {
            _companyLabel.hidden = YES;
        }
        
        // 모바일 번호 표시
        if ([_cellInfo[@"share_mobile"] isEqualToString:@"y"] || myType != MemberTypeStudent) {
            _mobileLabel.hidden = NO;
            _mobileValueLabel.hidden = NO;
        } else {
            _mobileLabel.hidden = YES;
            _mobileValueLabel.hidden = YES;
        }
        
        if ([_cellInfo[@"share_email"] isEqualToString:@"y"] || myType != MemberTypeStudent) {
            _emailLabel.hidden = NO;
            _emailValueLabel.hidden = NO;
        } else {
            _emailLabel.hidden = YES;
            _emailValueLabel.hidden = YES;
        }
        

//        if (_cellInfo[@"photourl"]) {
//            NSLog(@"프로필 이미지 : %@", _cellInfo[@"photourl"]);
//            [_profileImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _cellInfo[@"photourl"]]]
//                          placeholderImage:[UIImage imageNamed:@"placeholder"]];
//        }
//        
//        if (_cellInfo[@"name"]) {
//            _nameValueLabel.text = _cellInfo[@"name"];
//        }
    }
    else
    {
        if (_memType == MemberTypeFaculty) {
            if ([[UserContext shared].language isEqualToString:kLMKorean]) {
                NSLog(@"%@", _cellInfo[@"major.title"]);
                _majorValueLabel.text = _cellInfo[@"major.title"];
            } else {
                _majorValueLabel.text = _cellInfo[@"major.title_en"];
            }
            
        } else if (_memType == MemberTypeStaff) {
            if ([[UserContext shared].language isEqualToString:kLMKorean]) {
                _workValueLabel.text = _cellInfo[@"work"];
            } else {
                _workValueLabel.text = _cellInfo[@"work_en"];
            }
        }
        
        if (myType == MemberTypeStudent) {
            _mobileLabel.hidden = YES;
            _mobileValueLabel.hidden = YES;
        } else {
            _mobileLabel.hidden = NO;
            _mobileValueLabel.hidden = NO;
        }

        _telValueLabel.text = _cellInfo[@"tel"];
//        _emailValueLabel.text = _cellInfo[@"email"];
        _officeValueLabel.text = _cellInfo[@"office"];
    }
    
//    [self setNeedsDisplay];
    [self layoutSubviews];

}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // 멤버 타입별로 셀 내용 다르게 노출
    CGRect viewFrame = self.bounds;
    CGFloat width = 240.0f;
    
    CGFloat yOffset = 10.0f;
    CGFloat xOffset = (viewFrame.size.width - width) / 2;

    // 프로필 사진
    _profileImage.frame = CGRectMake(0.0f, yOffset, viewFrame.size.width, 200.0f);
    if (IS_LESS_THEN_IOS7) {
        yOffset += _profileImage.frame.size.height;
    } else {
        yOffset += (_profileImage.frame.size.height + 30);
    }

    // 이름
    _nameLabel.frame = CGRectMake(xOffset, yOffset, width, 24.0f);
    yOffset += 26.0f;

    if (_memType == MemberTypeStudent)
    {
//        _profileImage.frame = CGRectMake(0.0f, yOffset, viewFrame.size.width, 200.0f);
//        yOffset += (_profileImage.frame.size.height + 30);
//        _nameLabel.frame = CGRectMake(xOffset, yOffset, width, 24.0f);
//        yOffset += 26.0f;
        
        _statusLabel.frame = CGRectMake(xOffset, yOffset, 40.0f, 20.0f);
        _classTitleLabel.frame = CGRectMake(xOffset + 45.0f, yOffset, 150.0f, 20.0f);
        if (_statusLabel.hidden) {
            _classTitleLabel.frame = CGRectMake(xOffset, yOffset, 150.0f, 20.0f);
        }
        yOffset += 22.0f;
        _companyLabel.frame = CGRectMake(xOffset, yOffset, width, 16.0f);
        yOffset += (18.0f + 5.0f);
        
        if (!_mobileLabel.hidden) {
            _mobileLabel.frame = CGRectMake(xOffset, yOffset, width, 14.0f);
            yOffset += 16.0f;
        }
        if (!_mobileValueLabel.hidden) {
            _mobileValueLabel.frame = CGRectMake(xOffset, yOffset, width, 16.0f);
            yOffset += (18.0f + 10.0f);
        }
        if (!_emailLabel.hidden) {
            _emailLabel.frame = CGRectMake(xOffset, yOffset, width, 14.0f);
            yOffset += 16.0f;
        }
        if (!_emailValueLabel.hidden) {
            _emailValueLabel.frame = CGRectMake(xOffset, yOffset, width, 16.0f);
//            yOffset += (18.0f + 10.0f);
        }
        //        _majorLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        //        yOffset += 23.0f;
        //        _telLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
        //        yOffset += 23.0f;
        //        _officeLabel.frame = CGRectMake(10.0f, yOffset, 80.0f, 20.0f);
    }
    else
    {
        if (_memType == MemberTypeFaculty) {
            _majorValueLabel.frame = CGRectMake(xOffset, yOffset, width, 18.0f);
            yOffset += 20.0f;
        } else if (_memType == MemberTypeStaff) {
            _workValueLabel.frame = CGRectMake(xOffset, yOffset, width, 18.0f);
            yOffset += 20.0f;
        }

        _telValueLabel.frame = CGRectMake(xOffset, yOffset, width, 20.0f);
        yOffset += 24.0f;
        
        if (!_mobileLabel.hidden) {
            _mobileLabel.frame = CGRectMake(xOffset, yOffset, width, 14.0f);
            yOffset += 16.0f;
        }
        if (!_mobileValueLabel.hidden) {
            _mobileValueLabel.frame = CGRectMake(xOffset, yOffset, width, 16.0f);
            yOffset += 18.0f;
        }
        if (!_emailValueLabel.hidden) {
            _emailValueLabel.frame = CGRectMake(xOffset, yOffset, width, 18.0f);
            yOffset += 20.0f;
        }
        _officeValueLabel.frame = CGRectMake(xOffset, yOffset, width, 18.0f);
        yOffset += 20.0f;

    }
    
}
@end
