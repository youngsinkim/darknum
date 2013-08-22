//
//  UIView+Shadow.m
//  MBAAddress
//
//  Created by 선옥 채 on 13. 8. 17..
//  Copyright (c) 2013년 sun. All rights reserved.
//

#import "UIView+Shadow.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Shadow)

+ (void)roundedLayer:(UIView *)v radius:(float)r shadow:(BOOL)s
{
    // border radius
    [v.layer setCornerRadius:r];
//    [v.layer setMasksToBounds:YES];
    
    // border
    [v.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [v.layer setBorderWidth:1.0f];
    
    // shadow
    if(s)
    {
        // drop shadow
        [v.layer setShadowColor:[UIColor blackColor].CGColor];
        [v.layer setShadowOpacity:0.5];
        [v.layer setShadowRadius:3.0];
        [v.layer setShadowOffset:CGSizeMake(2.0, 2.0)];

//        viewLayer.shadowPath = [UIBezierPath bezierPathWithRect:viewLayer.bounds].CGPath;
    }
    return;
}

@end
