//
//  ToolViewCell.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 22..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "ToolViewCell.h"

#define ToolViewCellH   42.0f

@interface ToolViewCell ()

@property (strong, nonatomic) UIImageView *thumbImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *descLabel;

@end

@implementation ToolViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGRect rect = self.bounds;
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 200.0f, 22.0f)];
        [_nameLabel setTextColor:[UIColor darkGrayColor]];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setFont:[UIFont systemFontOfSize:14.0f]];
        
        [self.contentView addSubview:_nameLabel];
        
        
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkBtn.tag = 300;
        _checkBtn.frame = CGRectMake(rect.size.width - 60.0f, 10.0f, 21.0f, 22.0f);
        [_checkBtn setBackgroundImage:[UIImage imageNamed:@"join_agreebox"] forState:UIControlStateNormal];
        [_checkBtn setBackgroundImage:[UIImage imageNamed:@"join_agreebox_ch"] forState:UIControlStateSelected];
        [_checkBtn setBackgroundImage:[UIImage imageNamed:@"join_agreebox"] forState:UIControlStateDisabled];
        
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
    
    if (_info[@"name"]) {
        _nameLabel.text = _info[@"name"];
    }
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
