//
//  LoadingProgressView.h
//  SMAddressBook
//
//  Created by sochae on 13. 9. 16..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ProgressTypeUpdateDownload,
    ProgressTypeFavoriteSetting,
    ProgressTypeUnknown
} ProgressType;

@class LoadingProgressView;
@protocol LoadingProgressViewDelegate <NSObject>

- (void)myProgressTask:(NSDictionary *)info;

@end


@interface LoadingProgressView : UIView

@property id<LoadingProgressViewDelegate> delegate;
@property (assign, nonatomic) CGFloat progress;
@property (assign, nonatomic) NSInteger pos;
@property (strong, nonatomic) NSString *percent;
//@property (nonatomic, retain) NSString *notificationString;
//@property (nonatomic, assign) BOOL showProgress;
@property (nonatomic, strong) NSTimer *myTimer;
@property (strong, nonatomic) UILabel *percentLabel;
@property (assign) NSInteger curValue;
@property (assign) NSInteger maxValue;

//- (void)setBackgroundSize:(NSString *)message;
//- (void)start;
- (void)start:(NSInteger)cur total:(NSInteger)tot;
- (void)stop;
//- (void)setProgress:(CGFloat)pos;

- (void)setPos:(CGFloat)pos withValue:(NSInteger)value;

- (void)onStart:(NSInteger)position withType:(ProgressType)type;
- (void)onProgress:(NSInteger)current total:(NSInteger)total;
- (void)onStop;

@end
