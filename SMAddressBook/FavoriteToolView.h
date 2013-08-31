//
//  FavoriteToolView.h
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFvToolH    50.0f

#define kFToolFavoriteSetting    100
#define kFToolTotalStudent       101
#define kFToolHelp               102

@class FavoriteToolView;

@protocol FavoriteToolViewDelegate <NSObject>

- (void)onFavoriteSettBtnTouched:(id)sender;
- (void)onTotalStudentBtnTouched:(id)sender;
- (void)onHelpBtnTouched:(id)sender;

@end

@interface FavoriteToolView : UIView

@property (weak) id<FavoriteToolViewDelegate> delegate;

@end
