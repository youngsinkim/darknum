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
        
        _favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _favoriteBtn.frame = CGRectMake(320.0f-100.0f, 5.0f, 21.0f, 22.0f);
        [_favoriteBtn setBackgroundImage:[UIImage imageNamed:@"join_agreebox"] forState:UIControlStateNormal];
        [_favoriteBtn setBackgroundImage:[UIImage imageNamed:@"join_agreebox_ch"] forState:UIControlStateSelected];
        
        [_favoriteBtn addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_favoriteBtn];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)onBtnClicked:(id)sender
{
    [(UIButton *)sender setSelected:![(UIButton *)sender isSelected]];
}

- (void)setHidden:(BOOL)hidden
{
    _hidden = hidden;
    if (hidden == YES) {
        _favoriteBtn.hidden = YES;
        
        [self setNeedsDisplay];
    }
}
@end
