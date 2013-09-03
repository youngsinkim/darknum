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

@end

@implementation AddressCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        //        self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        
        // 프로필 사진
        _profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 50.0f, 50.0f)];
        _profileImageView.image = [UIImage imageNamed:@"placeholder"];
        
        [self.contentView addSubview:_profileImageView];
        
        
        // 이름
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 8.0f, 200.0f, 20.0f)];
        _nameLabel.textColor = [UIColor darkGrayColor];
        _nameLabel.backgroundColor = [UIColor clearColor];
        [_nameLabel setFont:[UIFont systemFontOfSize:15.0f]];
        
        [self.contentView addSubview:_nameLabel];
        
        
        // 이메일
        _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 36.0f, 200.0f, 20.0f)];
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
    NSLog(@"주소록 셀 정보 : %@", _cellInfo);
    
    if (_cellInfo[@"photourl"]) {
        [_profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://biz.snu.ac.kr/webdata%@", _cellInfo[@"photourl"]]]
                          placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    if (_cellInfo[@"name"]) {
        _nameLabel.text = _cellInfo[@"name"];
    }
    
    if (_cellInfo[@"email"]) {
        _emailLabel.text = _cellInfo[@"email"];
    }
    
//    [self setNeedsDisplay];
}

@end
