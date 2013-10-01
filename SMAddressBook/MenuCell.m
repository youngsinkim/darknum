//
//  MenuCell.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 25..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "MenuCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
        
        UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, kCellH)];
//        [background setImage:[[UIImage imageNamed:@"cell_background"] stretchableImageWithLeftCapWidth:0.0f topCapHeight:0.0f]];
        
        self.backgroundView = background;
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *selectedBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, kCellH)];
        [selectedBackground setImage:[[UIImage imageNamed:@"cell_selected_background"] stretchableImageWithLeftCapWidth:0.0f topCapHeight:0.0f]];
        
        self.selectedBackgroundView = selectedBackground;

        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;

        // 텍스트
        self.textLabel.textColor = [UIColor colorWithRed:190.0f/255.0f green:197.0f/255.0f blue:212.0f/255.0f alpha:1.0f];
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
        self.textLabel.shadowColor = [UIColor colorWithRed:33.0f/255.0f green:38.0f/255.0f blue:49.0f/255.0f alpha:1.0f];
        self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
        
        // 섹션 라인 (imsi)
        NSLog(@"세션 높이 : %f", self.contentView.frame.size.height);
        UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.contentView.frame.size.height - 5.0f, self.contentView.frame.size.width, 0.5f)];
        lineV.backgroundColor = [UIColor colorWithRed:56.0f/255.0f green:60.0f/255.0f blue:64.0f/255.0f alpha:1.0f];
//        [lineV.layer setCornerRadius:1.0f];
//        [lineV.layer setBorderColor:[UIColor colorWithRed:30.0f/255.0f green:32.0f/255.0f blue:34.0f/255.0f alpha:1.0f].CGColor];
//        [lineV.layer setBorderWidth:1.0f];

        [self.contentView addSubview:lineV];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
