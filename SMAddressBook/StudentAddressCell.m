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
@property (strong, nonatomic) UILabel *mobileLabel;
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
        UILabel *fixLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 35.f, 14.0f)];
        fixLabel1.textColor = [UIColor grayColor];
        [fixLabel1 setFont:[UIFont systemFontOfSize:12.0f]];
        fixLabel1.text = @"Mobile";
        
        [self.contentView addSubview:fixLabel1];
        
        
        _mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset + 40.0f, yOffset, 150.0f, 14.0f)];
        _mobileLabel.textColor = [UIColor lightGrayColor];
        [_mobileLabel setFont:[UIFont systemFontOfSize:12.0f]];
        
        [self.contentView addSubview:_mobileLabel];
        yOffset += 16.0f;
        
        
        // 이메일
        UILabel *fixLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 35.f, 14.0f)];
        fixLabel2.textColor = [UIColor grayColor];
        [fixLabel2 setFont:[UIFont systemFontOfSize:12.0f]];
        fixLabel2.text = @"Email";
        
        [self.contentView addSubview:fixLabel2];
        
        
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
    
    if (cellInfo[@"name"]) {
        _nameLabel.text = cellInfo[@"name"];
    }
    
    if (cellInfo[@"status"]) {
        NSString *description = [NSString stringWithFormat:@"[%@] %@ | %@", cellInfo[@"status"], cellInfo[@"company"], cellInfo[@"department"]];
        _memberLabel.text = description;// cellInfo[@"desc"];
    }
    
    if (cellInfo[@"mobile"]) {
        _mobileLabel.text = cellInfo[@"mobile"];
    }
    
    if (cellInfo[@"email"]) {
        _emailLabel.text = cellInfo[@"email"];
    }
//
//    [self setNeedsDisplay];
}

@end
