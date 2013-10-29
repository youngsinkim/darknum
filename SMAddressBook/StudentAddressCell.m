//
//  StudentAddressCell.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 2..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "StudentAddressCell.h"
#import <UIImageView+AFNetworking.h>

@interface StudentAddressCell ()

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *memberLabel;
//@property (strong, nonatomic) UILabel *mobileStLabel;
//@property (strong, nonatomic) UILabel *mobileLabel;
@property (strong, nonatomic) UILabel *emailStLabel;
@property (strong, nonatomic) UILabel *emailLabel;

@end

@implementation StudentAddressCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
//        self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        
        CGFloat xOffset = 5.0f;
        CGFloat yOffset = 5.0f;
        
        // 프로필 사진
        _profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, yOffset, 65.0f, 65.0f)];
        _profileImageView.image = [UIImage imageNamed:@"placeholder"];
        
        [self.contentView addSubview:_profileImageView];
        xOffset += (_profileImageView.frame.size.width + 5.0f);
        
        
        // 이름
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 200.0f, 16.0f)];
        _nameLabel.textColor = [UIColor darkGrayColor];
        _nameLabel.backgroundColor = [UIColor clearColor];
        [_nameLabel setFont:[UIFont systemFontOfSize:14.0f]];
        
        [self.contentView addSubview:_nameLabel];
        yOffset += 18.0f;
        
        
        // 소속
        _memberLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 200.0f, 14.0f)];
        _memberLabel.textColor = [UIColor lightGrayColor];
        _memberLabel.backgroundColor = [UIColor clearColor];
        [_memberLabel setFont:[UIFont systemFontOfSize:12.0f]];
        
        [self.contentView addSubview:_memberLabel];
        yOffset += 16.0f;
        
        // 모바일
//        _mobileStLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 35.f, 14.0f)];
//        _mobileStLabel.textColor = [UIColor grayColor];
//        [_mobileStLabel setFont:[UIFont systemFontOfSize:12.0f]];
//        _mobileStLabel.text = @"Mobile";
//        
//        [self.contentView addSubview:_mobileStLabel];
//        
//        
//        _mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset + 40.0f, yOffset, 150.0f, 14.0f)];
//        _mobileLabel.textColor = [UIColor lightGrayColor];
//        [_mobileLabel setFont:[UIFont systemFontOfSize:12.0f]];
//        
//        [self.contentView addSubview:_mobileLabel];
//        yOffset += 16.0f;
        
        
        // 이메일
        _emailStLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 35.f, 14.0f)];
        _emailStLabel.textColor = [UIColor grayColor];
        [_emailStLabel setFont:[UIFont systemFontOfSize:12.0f]];
        _emailStLabel.text = @"Email";
        
        [self.contentView addSubview:_emailStLabel];
        
        
        _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset + 40.0f, yOffset, 150.0f, 14.0f)];
        _emailLabel.textColor = [UIColor lightGrayColor];
        [_emailLabel setFont:[UIFont systemFontOfSize:12.0f]];
        
        [self.contentView addSubview:_emailLabel];
        
        
        // 라인
//        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 65 - 1, self.contentView.frame.size.width, 1.0f)];
//        line.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
//        
//        [self.contentView addSubview:line];
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
    
    if (cellInfo[@"photourl"]) {
//        [_profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://biz.snu.ac.kr/webdata%@", cellInfo[@"photourl"]]]
        [_profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", cellInfo[@"photourl"]]]
                          placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    if ([[UserContext shared].language isEqualToString:kLMKorean]) {
        if (cellInfo[@"name"]) {
            _nameLabel.text = cellInfo[@"name"];
        }
        
        if ([cellInfo[@"company"] length] > 0 && [cellInfo[@"department"] length] > 0) {
            NSString *description = [NSString stringWithFormat:@"%@ | %@ %@", cellInfo[@"company"], cellInfo[@"department"], cellInfo[@"title"]];
            _memberLabel.text = description;// cellInfo[@"desc"];
        }
        else {
            _memberLabel.text = @"";    // 스크롤 시, 텍스트 겹침 현상 발생되어 수정
        }
    }
    else {
        if (cellInfo[@"name_en"]) {
            _nameLabel.text = cellInfo[@"name_en"];
        }
        
        if ([cellInfo[@"company_en"] length] > 0 && [cellInfo[@"department_en"] length] > 0) {
            NSString *description = [NSString stringWithFormat:@" %@ | %@ %@", cellInfo[@"company_en"], cellInfo[@"department_en"], cellInfo[@"title_en"]];
            _memberLabel.text = description;// cellInfo[@"desc"];
        }
        else {
            _memberLabel.text = @"";    // 스크롤 시, 텍스트 겹침 현상 발생되어 수정
        }
    }
    
    // 로그인 유저 타입
    MemberType myType = (MemberType)[[[UserContext shared] memberType] integerValue];

    NSLog(@"직장 정보 길이 : %d", _memberLabel.text.length);
    if ([cellInfo[@"share_company"] isEqualToString:@"y"] || myType != MemberTypeStudent) {
        if (_memberLabel.text.length > 0)
            _memberLabel.hidden = NO;
        else
            _memberLabel.hidden = YES;
    } else {
        _memberLabel.hidden = YES;
    }

//    if (cellInfo[@"mobile"]) {
//        _mobileLabel.text = cellInfo[@"mobile"];
//    }
//    if ([cellInfo[@"share_mobile"] isEqualToString:@"y"]) {
//        _mobileLabel.hidden = NO;
//        _mobileStLabel.hidden = NO;
//    } else {
//        _mobileLabel.hidden = YES;
//        _mobileStLabel.hidden = YES;
//    }
    
    if (cellInfo[@"email"]) {
        _emailLabel.text = cellInfo[@"email"];
    }
    
    if ([cellInfo[@"share_email"] isEqualToString:@"y"] || myType != MemberTypeStudent) {
        _emailLabel.hidden = NO;
        _emailStLabel.hidden = NO;
    } else {
        _emailLabel.hidden = YES;
        _emailStLabel.hidden = YES;
    }

    [self layoutSubviews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect viewRect = self.bounds;
    CGFloat xOffset = 5.0f;
    CGFloat yOffset = 8.0f;

    // profile image
    xOffset += (_profileImageView.frame.size.width + 5.0f);
    
    CGFloat cellWidth = (viewRect.size.width - xOffset - 20.0f);

    if (!_memberLabel.hidden && !_emailLabel.hidden) {
        _nameLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 16.0f);
        yOffset += 20.0f;
        _memberLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 16.0f);
        yOffset += 20.0f;
        _emailStLabel.frame = CGRectMake(xOffset, yOffset, 35.0f, 16.0f);
        _emailLabel.frame = CGRectMake(xOffset + _emailStLabel.frame.size.width + 5.0f, yOffset, (cellWidth - _emailStLabel.frame.size.width), 14.0f);
    }
    else if (_memberLabel.hidden) {
        _nameLabel.frame = CGRectMake(xOffset, yOffset, 200.0f, 16.0f);
        yOffset += 24.0f;
        _emailStLabel.frame = CGRectMake(xOffset, yOffset, 35.0f, 16.0f);
        _emailLabel.frame = CGRectMake(xOffset + _emailStLabel.frame.size.width + 5.0f, yOffset, (cellWidth - _emailStLabel.frame.size.width), 16.0f);
    }
    else if (_emailLabel.hidden) {
        _nameLabel.frame = CGRectMake(xOffset, yOffset, 200.0f, 16.0f);
        yOffset += 24.0f;
        _memberLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 16.0f);
    }
}

@end
