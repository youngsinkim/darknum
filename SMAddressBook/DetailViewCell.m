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

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UILabel *hasAppLabel; // App 설치 여부 표시
@property (strong, nonatomic) UILabel *borderLabel;
@property (strong, nonatomic) UILabel *line;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *classTitleLabel;
@property (strong, nonatomic) UILabel *deliLabel;
@property (strong, nonatomic) UILabel *birthLabel;
@property (strong, nonatomic) UILabel *currentLabel;
@property (strong, nonatomic) UILabel *companyLabel;

@property (strong, nonatomic) UIImageView *mobilebgView;
@property (strong, nonatomic) UIImageView *mobileIconView;
@property (strong, nonatomic) UILabel *mobileValueLabel;

@property (strong, nonatomic) UILabel *majorLabel;
@property (strong, nonatomic) UILabel *majorValueLabel;

@property (strong, nonatomic) UIImageView *telbgView;
@property (strong, nonatomic) UIImageView *telIconView;
@property (strong, nonatomic) UILabel *telValueLabel;

@property (strong, nonatomic) UIImageView *emailbgView;
@property (strong, nonatomic) UIImageView *emilIconView;
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
        self.backgroundColor = UIColorFromRGB(0xf0f0f0);
        
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        [_bgView setBackgroundColor:UIColorFromRGB(0xa6b7d6)];
        
        [self addSubview:_bgView];
        
        
        _hasAppLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_hasAppLabel setBackgroundColor:[UIColor colorWithRed:20.0f/255.0f green:44.0f/255.0f blue:109.0f/255.0f alpha:0.8]];
        [_hasAppLabel setTextColor:UIColorFromRGB(0xffffff)];
        [_hasAppLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [_hasAppLabel setTextAlignment:NSTextAlignmentCenter];
        [_hasAppLabel setText:LocalizedString(@"has App Message", @"앱 미설치 문구")];
        
        [_bgView addSubview:_hasAppLabel];
        
        
        _borderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _borderLabel.backgroundColor = UIColorFromRGB(0x7d8aa2);
        
        [_bgView addSubview:_borderLabel];
        

        _profileImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_profileImage setImage:[UIImage imageNamed:@"placeholder"]];
        [_profileImage setContentMode:UIViewContentModeScaleAspectFit];
        [_profileImage setBackgroundColor:[UIColor clearColor]];
        
        [_bgView addSubview:_profileImage];
        
        
        // 라인
        _line = [[UILabel alloc] initWithFrame:CGRectZero];
        _line.backgroundColor = UIColorFromRGB(0xcad8f1);
        
        [self addSubview:_line];


        // 이름
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setTextColor:UIColorFromRGB(0x142c6d)];
        [_nameLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [_nameLabel setTextAlignment:NSTextAlignmentLeft];
//        _nameLabel.clipsToBounds = YES;
//        _nameLabel.opaque = YES;
//        _nameLabel.layer.masksToBounds = NO;
//        _nameLabel.layer.opaque = YES;

        [self addSubview:_nameLabel];
        
        
        // 상태 (재학/졸업)
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_statusLabel setBackgroundColor:UIColorFromRGB(0x0099cc)];
        [_statusLabel setTextColor:UIColorFromRGB(0xffffff)];
        [_statusLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [_statusLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self addSubview:_statusLabel];
//        _statusLabel.hidden = YES;
        
        
        // 기수
        _classTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_classTitleLabel setBackgroundColor:[UIColor clearColor]];
        [_classTitleLabel setTextColor:UIColorFromRGB(0x0099cc)];
        [_classTitleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_classTitleLabel setTextAlignment:NSTextAlignmentLeft];
        
        [self addSubview:_classTitleLabel];


        // (/)
        _deliLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_deliLabel setBackgroundColor:[UIColor clearColor]];
        [_deliLabel setTextColor:UIColorFromRGB(0x0099cc)];
        [_deliLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [_deliLabel setTextAlignment:NSTextAlignmentCenter];
        [_deliLabel setText:@" / "];
        
        [self addSubview:_deliLabel];

        
        // 생년월일
        _birthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_birthLabel setBackgroundColor:[UIColor clearColor]];
        [_birthLabel setTextColor:UIColorFromRGB(0x142c6d)];
        [_birthLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [_birthLabel setTextAlignment:NSTextAlignmentLeft];
        
        [self addSubview:_birthLabel];

        
        // 현직/전직
        _currentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_currentLabel setBackgroundColor:[UIColor clearColor]];
        [_currentLabel setTextColor:UIColorFromRGB(0x000000)];
        [_currentLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
        [_currentLabel setTextAlignment:NSTextAlignmentLeft];
        
        [self addSubview:_currentLabel];
        

        // 직장
        _companyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_companyLabel setBackgroundColor:[UIColor clearColor]];
        [_companyLabel setTextColor:UIColorFromRGB(0x444444)];
        [_companyLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
        [_companyLabel setTextAlignment:NSTextAlignmentLeft];
        
        [self addSubview:_companyLabel];

        
        // 모바일 background
        _mobilebgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"t_field"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f]];
        
        [self addSubview:_mobilebgView];

        
        // 모바일 icon
        _mobileIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_view_mphone"]];
        
        [self addSubview:_mobileIconView];

        
        // 모바일
        _mobileValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_mobileValueLabel setBackgroundColor:[UIColor clearColor]];
        [_mobileValueLabel setTextColor:UIColorFromRGB(0x555555)];
        [_mobileValueLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        [_mobileValueLabel setTextAlignment:NSTextAlignmentLeft];
        
        [self addSubview:_mobileValueLabel];
        
        
        // 이메일 텍스트
        _emailbgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"t_field"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f]];
        
        [self addSubview:_emailbgView];
        
        
        // 이메일 icon
        _emilIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_view_email"]];
        
        [self addSubview:_emilIconView];

        
        // 이메일
        _emailValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_emailValueLabel setBackgroundColor:[UIColor clearColor]];
        [_emailValueLabel setTextColor:UIColorFromRGB(0x555555)];
        [_emailValueLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        [_emailValueLabel setTextAlignment:NSTextAlignmentLeft];
        
        [self addSubview:_emailValueLabel];
        

        _majorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_majorLabel setBackgroundColor:[UIColor clearColor]];
        [_majorLabel setTextColor:UIColorFromRGB(0x444444)];
        [_majorLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [_majorLabel setTextAlignment:NSTextAlignmentRight];
        [_majorLabel setText:@"전공"];
        
        [self addSubview:_majorLabel];
        
        
        _majorValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_majorValueLabel setBackgroundColor:[UIColor clearColor]];
        [_majorValueLabel setTextColor:UIColorFromRGB(0x444444)];
        [_majorValueLabel setFont:[UIFont systemFontOfSize:12.0f]];
        
        [self addSubview:_majorValueLabel];

        
        // 전화 background
        _telbgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"t_field"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f]];

        [self addSubview:_telbgView];
        
        
        // 전화 icon
        _telIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_view_phone"]];
        
        [self addSubview:_telIconView];

        
        // 전화
        _telValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_telValueLabel setBackgroundColor:[UIColor clearColor]];
        [_telValueLabel setTextColor:UIColorFromRGB(0x444444)];
        [_telValueLabel setFont:[UIFont systemFontOfSize:13.0f]];
        
        [self addSubview:_telValueLabel];

        
        _officeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_officeLabel setBackgroundColor:[UIColor clearColor]];
        [_officeLabel setTextColor:[UIColor darkGrayColor]];
        [_officeLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [_officeLabel setTextAlignment:NSTextAlignmentRight];
        [_officeLabel setText:@"사무실"];

        [self addSubview:_officeLabel];
        
        
        _officeValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_officeValueLabel setBackgroundColor:[UIColor clearColor]];
        [_officeValueLabel setTextColor:UIColorFromRGB(0x444444)];
        [_officeValueLabel setFont:[UIFont systemFontOfSize:11.0f]];
        
        [self addSubview:_officeValueLabel];

        
        _workLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_workLabel setBackgroundColor:[UIColor clearColor]];
        [_workLabel setTextColor:[UIColor darkGrayColor]];
        [_workLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [_workLabel setTextAlignment:NSTextAlignmentRight];
        [_workLabel setText:@"담당업무"];
        
        [self addSubview:_workLabel];
        
        
        _workValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_workValueLabel setBackgroundColor:[UIColor clearColor]];
        [_workValueLabel setTextColor:UIColorFromRGB(0x444444)];
        [_workValueLabel setFont:[UIFont systemFontOfSize:12.0f]];
        
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
//    if (_cellInfo[@"viewphotourl"]) {
        NSLog(@"프로필 이미지 : %@", _cellInfo[@"viewphotourl"]);
        [_profileImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _cellInfo[@"viewphotourl"]]]
                      placeholderImage:[UIImage imageNamed:@"ic_noimg_info"]];
//    } else {
//        [_profileImage setImage:[UIImage imageNamed:@"ic_noimg_info"]];
//    }
    
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

    // 전직/현직 표시
    if ([_cellInfo[@"iscurrent"] isEqualToString:@"y"]) {
        _currentLabel.text = [NSString stringWithString:LocalizedString(@"currented", nil)];
    } else {
        _currentLabel.text = [NSString stringWithString:LocalizedString(@"not currented", nil)];
    }

    
    if (_cellInfo[@"tel"]) {
        _telValueLabel.text = _cellInfo[@"tel"];
        _telbgView.hidden = NO;
        _telIconView.hidden = NO;
        _telValueLabel.hidden = NO;
    } else {
        _telValueLabel.text = @"";
        _telbgView.hidden = YES;
        _telIconView.hidden = YES;
        _telValueLabel.hidden = YES;
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

        if (_cellInfo[@"birth"]) {
            _birthLabel.text = [NSString stringWithFormat:LocalizedString(@"%@ birth", @"생년월일"), _cellInfo[@"birth"]];
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
            _mobilebgView.hidden = NO;
            _mobileIconView.hidden = NO;
            _mobileValueLabel.hidden = NO;
        } else {
            _mobilebgView.hidden = YES;
            _mobileIconView.hidden = YES;
            _mobileValueLabel.hidden = YES;
        }
        
        if ([_cellInfo[@"share_email"] isEqualToString:@"y"] || myType != MemberTypeStudent) {
            _emailbgView.hidden = NO;
            _emilIconView.hidden = NO;
            _emailValueLabel.hidden = NO;
        } else {
            _emailbgView.hidden = YES;
            _emilIconView.hidden = YES;
            _emailValueLabel.hidden = YES;
        }
        

//        if (_cellInfo[@"photourl"]) {
//            NSLog(@"프로필 이미지 : %@", _cellInfo[@"photourl"]);
//            [_profileImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _cellInfo[@"photourl"]]]
//                          placeholderImage:[UIImage imageNamed:@"ic_noimg_info"]];
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
            _mobilebgView.hidden = YES;
            _mobileIconView.hidden = YES;
            _mobileValueLabel.hidden = YES;
        } else {
            _mobilebgView.hidden = NO;
            _mobileIconView.hidden = NO;
            _mobileValueLabel.hidden = NO;
        }

//        _emailValueLabel.text = _cellInfo[@"email"];
        _officeValueLabel.text = _cellInfo[@"office"];
    }
    
//    [self setNeedsDisplay];
    [self layoutSubviews];

}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect rect = self.frame;
    CGFloat yOffset = 0.0f;
    CGFloat xOffset = 15.0f;
    CGFloat height = 235.0f;
    CGFloat width = rect.size.width - (xOffset * 2);
    CGFloat borderArea = 200.0f;
    
    if (([[UIScreen mainScreen] bounds].size.height < 568)) {
        height = 175.0f;
        borderArea = 143.0f;
    }
    
    // 사진 영역
    _bgView.frame = CGRectMake(0.0f, yOffset, rect.size.width, height);
    
    // 앱 설치 text
    _hasAppLabel.frame = CGRectMake(0.0f, 0.0f, rect.size.width, 20.0f);
    
    // 프로필 사진
    _profileImage.frame = CGRectMake((rect.size.width - borderArea) / 2, _hasAppLabel.frame.origin.y + _hasAppLabel.frame.size.height + 2.0f, borderArea, borderArea);

    // 사진 테두리
    _borderLabel.frame = CGRectInset(_profileImage.frame, -2, -2);
    
    // 라인
    _line.frame = CGRectMake(0.0f, _bgView.frame.origin.y + _bgView.frame.size.height, rect.size.width, 2.0f);

    yOffset += (height + 15.0f);
    

    // 1_line (이름)
    _nameLabel.frame = CGRectMake(xOffset, yOffset, rect.size.width - (xOffset * 2), 20.0f);
    yOffset += (_nameLabel.frame.size.height + 5.0f);

    CGFloat statusHeight = 14.0f;
    
    if (_memType == MemberTypeStudent)
    {
        // 2_line
        _statusLabel.frame = CGRectMake(xOffset, yOffset, 32.0f, statusHeight);
//        switch (<#expression#>) {
//            case <#constant#>:
//                <#statements#>
//                break;
//                
//            default:
//                break;
//        }
        [_statusLabel setBackgroundColor:UIColorFromRGB(0x0099cc)];

        _classTitleLabel.frame = CGRectMake(xOffset + _statusLabel.frame.size.width + 5.0f, yOffset, 60.0f, statusHeight);
        _deliLabel.frame = CGRectMake(xOffset + _statusLabel.frame.size.width + _classTitleLabel.frame.size.width + 5.0f, yOffset, 20.0f, statusHeight);
        _birthLabel.frame = CGRectMake(xOffset + _statusLabel.frame.size.width + _classTitleLabel.frame.size.width + _deliLabel.frame.size.width + 5.0f, yOffset, 100.0f, statusHeight);
        
        if (_statusLabel.hidden) {
            _classTitleLabel.frame = CGRectMake(xOffset, yOffset, 150.0f, statusHeight);
            _deliLabel.frame = CGRectMake(xOffset + _classTitleLabel.frame.size.width + 5.0f, yOffset, 20.0f, statusHeight);
            _birthLabel.frame = CGRectMake(xOffset + _classTitleLabel.frame.size.width + _deliLabel.frame.size.width + 5.0f, yOffset, 100.0f, statusHeight);
        }
        yOffset += (_statusLabel.frame.size.height + 5.0f);
        
        // 3_line
        _currentLabel.frame = CGRectMake(xOffset, yOffset, 28.0f, 14.0f);
        _companyLabel.frame = CGRectMake(xOffset + _currentLabel.frame.size.width + 5.0f, yOffset, (width - _currentLabel.frame.size.width), 16.0f);
        yOffset += (_companyLabel.frame.size.height + 10.0f);
        
        if (!_mobileValueLabel.hidden) {
            _mobilebgView.frame = CGRectMake(xOffset, yOffset, width, 30.0f);
            _mobileIconView.frame = CGRectMake(xOffset + 8.0f, yOffset + 8.0f, 14.0f, 14.0f);
            _mobileValueLabel.frame = CGRectMake(xOffset + 8.0f + _mobileIconView.frame.size.width + 12.0f, yOffset, width, 30.0f);
            yOffset += (_mobilebgView.frame.size.height + 5.0f);
        }
        
        if (!_emailValueLabel.hidden) {
            _emailbgView.frame = CGRectMake(xOffset, yOffset, width, 30.0f);
            _emilIconView.frame = CGRectMake(xOffset + 8.0f, yOffset + 8.0f, 14.0f, 14.0f);
            _emailValueLabel.frame = CGRectMake(xOffset + 8.0f + _emilIconView.frame.size.width + 12.0f, yOffset, width, 30.0f);
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
        CGSize textSize = CGSizeZero;
        if (_memType == MemberTypeFaculty) {
            textSize = [_majorValueLabel.text sizeWithFont:_majorValueLabel.font];
            _majorValueLabel.frame = CGRectMake(xOffset, yOffset, textSize.width, 14.0f);
            yOffset += (_majorValueLabel.frame.size.height + 5.0f);
        } else if (_memType == MemberTypeStaff) {
            textSize = [_workValueLabel.text sizeWithFont:_workValueLabel.font];
            _workValueLabel.frame = CGRectMake(xOffset, yOffset, textSize.width, 13.0f);
//            _officeValueLabel.frame = CGRectMake(xOffset + _workValueLabel.frame.size.width + 5.0f, yOffset, width, 14.0f);
            yOffset += (_workLabel.frame.size.height + 5.0f);
        }

//        _deliLabel.frame = CGRectMake(xOffset + textSize.width, yOffset, 10.0f, 14.0f);
//        _officeValueLabel.frame = CGRectMake(xOffset + textSize.width + _deliLabel.frame.size.width + 5.0f, yOffset, width, 14.0f);
        _officeValueLabel.frame = CGRectMake(xOffset, yOffset, width, 14.0f);
        yOffset += (_officeValueLabel.frame.size.height + 5.0f);

        if ([_telValueLabel.text length] > 0) {
//        if (!_telValueLabel.hidden) {
            NSLog(@"tel : %@", _telValueLabel.text);
            _telbgView.frame = CGRectMake(xOffset, yOffset, width, 30.0f);
            _telIconView.frame = CGRectMake(xOffset + 8.0f, yOffset + 8.0f, 14.0f, 14.0f);
            _telValueLabel.frame = CGRectMake(xOffset + 8.0f + _telIconView.frame.size.width + 12.0f, yOffset, width, 30.0f);
            yOffset += (_telbgView.frame.size.height + 5.0f);
        }
        
        if (!_mobileValueLabel.hidden) {
            _mobilebgView.frame = CGRectMake(xOffset, yOffset, width, 30.0f);
            _mobileIconView.frame = CGRectMake(xOffset + 8.0f, yOffset + 8.0f, 14.0f, 14.0f);
            _mobileValueLabel.frame = CGRectMake(xOffset + 8.0f + _mobileIconView.frame.size.width + 12.0f, yOffset, width, 30.0f);
            yOffset += (_mobilebgView.frame.size.height + 5.0f);
        }
        
        if (!_emailValueLabel.hidden) {
            _emailbgView.frame = CGRectMake(xOffset, yOffset, width, 30.0f);
            _emilIconView.frame = CGRectMake(xOffset + 8.0f, yOffset + 8.0f, 14.0f, 14.0f);
            _emailValueLabel.frame = CGRectMake(xOffset + 8.0f + _emilIconView.frame.size.width + 12.0f, yOffset, width, 30.0f);
            yOffset += 20.0f;
        }

    }

}

@end
