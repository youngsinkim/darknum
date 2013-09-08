//
//  FavoriteSettCell.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 8..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FavoriteSettCell.h"

@interface FavoriteSettCell ()

@property (strong, nonatomic) UIButton *favoriteBtn;

@end

@implementation FavoriteSettCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGRect rect = self.bounds;
        
        _classLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 200.0f, 22.0f)];
        [_classLabel setTextColor:[UIColor darkGrayColor]];
        [_classLabel setBackgroundColor:[UIColor clearColor]];
        [_classLabel setFont:[UIFont systemFontOfSize:14.0f]];
        
        [self.contentView addSubview:_classLabel];
        
        
        _favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _favoriteBtn.tag = 300;
        _favoriteBtn.frame = CGRectMake(rect.size.width - 60.0f, 10.0f, 21.0f, 22.0f);
        [_favoriteBtn setBackgroundImage:[UIImage imageNamed:@"join_agreebox"] forState:UIControlStateNormal];
        [_favoriteBtn setBackgroundImage:[UIImage imageNamed:@"join_agreebox_ch"] forState:UIControlStateSelected];
        
        [_favoriteBtn addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_favoriteBtn];
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
    
//    UIButton *button = (UIButton *)[self viewWithTag:300];
    
    if (_hidden) {
        _favoriteBtn.hidden = YES;
    }
    else {
        _favoriteBtn.hidden = NO;
    }
    
}

- (void)setClassLabel:(UILabel *)classLabel
{
    _classLabel = classLabel;
    
    [self layoutSubviews];
}

- (void)setHidden:(BOOL)hidden
{
    _hidden = hidden;
    
    [self layoutSubviews];
}

- (void)setCellInfo:(NSDictionary *)cellInfo
{
    _cellInfo = cellInfo;
    
    [self layoutSubviews];
}

- (void)onBtnClicked:(id)sender
{
    [(UIButton *)sender setSelected:![(UIButton *)sender isSelected]];
    NSLog(@"cell selected(%d)", [sender isSelected]);
    
    if ([_delegate respondsToSelector:@selector(onFavoriteCheckTouched:)]) {
        [_delegate onFavoriteCheckTouched:self];
    }
}


@end
