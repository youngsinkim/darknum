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
@property (strong, nonatomic) UILabel *emailLabel;

@end

@implementation StudentAddressCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat xOffset = 0.0f;
        CGFloat yOffset = 0.0f;
        
        // 프로필 사진
        UIImage *proImage = [UIImage imageNamed:@"ic_noimg_list"];
        _profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, yOffset, proImage.size.width, proImage.size.height)];
        _profileImageView.image = proImage;
        
        [self.contentView addSubview:_profileImageView];
        xOffset += (_profileImageView.frame.size.width + 10.0f);
        yOffset += 10.0f;
        
        
        // 이름 text
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 220.0f, 16.0f)];
        _nameLabel.textColor = UIColorFromRGB(0x333333);
        _nameLabel.backgroundColor = [UIColor clearColor];
        [_nameLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        
        [self.contentView addSubview:_nameLabel];
        yOffset += (_nameLabel.frame.size.height + 5.0f);
        
        
        // 소속 text
        _memberLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 220.0f, 13.0f)];
        _memberLabel.textColor = UIColorFromRGB(0x555555);
        _memberLabel.backgroundColor = [UIColor clearColor];
        [_memberLabel setFont:[UIFont systemFontOfSize:11.0f]];
        
        [self.contentView addSubview:_memberLabel];
        yOffset += (_memberLabel.frame.size.height + 1.0f);
        
        
        // 이메일 text
        _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 220.0f, 12.0f)];
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
    } else {
        _emailLabel.hidden = YES;
    }

    [self layoutSubviews];
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

    if (!_memberLabel.hidden && !_emailLabel.hidden) {
        _nameLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 16.0f);
        yOffset += (17.0f + 4.0f);
        _memberLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 13.0f);
        yOffset += (14.0f + 0.0f);
        _emailLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 12.0f);
    }
    else if (_memberLabel.hidden) {
        _nameLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 16.0f);
        yOffset += 24.0f;
        _emailLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 13.0f);
    }
    else if (_emailLabel.hidden) {
        _nameLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 16.0f);
        yOffset += 24.0f;
        _memberLabel.frame = CGRectMake(xOffset, yOffset, cellWidth, 13.0f);
    }
}

@end
