//
//  MenuTableViewController.h
//  SMAddressBook
//
//  Created by sochae on 13. 8. 21..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MFSideMenuContainerViewController.h>

typedef enum {
    MenuViewTypeAddrFaculty,
    MenuViewTypeAddrStaff,
    MenuViewTypeAddrStudent,
    MenuViewTypeAddrTotalStudent,
    MenuViewTypeSettMyInfo,
    MenuViewTypeSettFavorite,
    MenuViewTypeSettTerms,
    MenuViewTypeSettHelp,
    MenuViewTypeUnknown
} MenuViewType;

@interface MenuTableViewController : UITableViewController

//@property (strong, nonatomic) NSMutableArray *menuList;             //< 메뉴 리스트
@property (strong, nonatomic) NSMutableArray *addrMenuList;         //< 주소록 메뉴 리스트
@property (strong, nonatomic) NSArray *settMenuList;                //< 설정 메뉴 리스트

@property (strong, nonatomic) NSDictionary *facultyAddrDict;        //< 교수진
@property (strong, nonatomic) NSDictionary *facultyMemberAddrDict;  //< 교직원
@property (strong, nonatomic) NSDictionary *totalAddrDict;          //< 전체보기


- (MFSideMenuContainerViewController *)menuContainerViewController;
- (void)showMyInfoViewController;

/// 세로 모드 네비게이션바 세팅
- (UINavigationController *)navigationController:(UIViewController *)viewController;

/// 네비게이션 뷰 컨트롤러
- (UINavigationController *)menuNavigationController:(MenuViewType)menuType withMenuInfo:(NSDictionary *)info;

/// 메뉴 테이블 헤더 정보 업데이트
- (void)updateHeaderInfo;
- (void)updateHeaderImage:(UIImage *)image;

@end
