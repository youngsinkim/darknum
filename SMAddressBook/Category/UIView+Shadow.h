//
//  UIView+Shadow.h
//  MBAAddress
//
//  Created by 선옥 채 on 13. 8. 17..
//  Copyright (c) 2013년 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Shadow)

+ (void)roundedLayer:(UIView *)v radius:(float)r shadow:(BOOL)s;

@end
