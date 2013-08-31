//
//  UIViewController+LoadingProgress.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 31..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "UIViewController+LoadingProgress.h"
#import <MBProgressHUD.h>

@implementation UIViewController (LoadingProgress)

- (void)startLoading
{
    MBProgressHUD *hud = (MBProgressHUD *)[self.navigationController.view viewWithTag:77777];
    if (hud == nil) {
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        hud.tag = 77777;
        [self.navigationController.view addSubview:hud];
//        [self.navigationController.view bringSubviewToFront:hud];
    }
    
    if (hud != nil) {
        [hud show:YES];
    }
}

- (void)stopLoading
{
    MBProgressHUD *hud = (MBProgressHUD *)[self.navigationController.view viewWithTag:77777];
    if (hud != nil) {
        [hud removeFromSuperViewOnHide];
        [hud hide:YES afterDelay:0.3f];
    }
}

- (void)startDimLoading//WithBlock:(dispatch_block_t)block
{
    MBProgressHUD *hud = (MBProgressHUD *)[self.navigationController.view viewWithTag:77777];
    if (hud == nil) {
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        hud.tag = 77777;
        [self.navigationController.view addSubview:hud];
        //        [self.navigationController.view bringSubviewToFront:hud];
    }
    
    if (hud != nil) {
        hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        [hud showWhileExecuting:@selector(myProgressTask:) onTarget:self withObject:self animated:YES];
//        [hud showAnimated:YES whileExecutingBlock:block];
//        [hud show:YES];
    }
}

- (void)stopDimLoading
{
    MBProgressHUD *hud = (MBProgressHUD *)[self.navigationController.view viewWithTag:77777];
    if (hud != nil) {
        [hud removeFromSuperViewOnHide];
        [hud hide:YES afterDelay:0.3f];
    }

}


@end
