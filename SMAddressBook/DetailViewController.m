//
//  DetailViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 8. 26..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailViewCell.h"
#import "UIView+Shadow.h"
#import "Faculty.h"
#import "Staff.h"
#import "Student.h"
//#import "DetailView.h"
#import "PortraitNavigationController.h"
#import "KakaoMessageViewController.h"
#import "DetailGuideViewController.h"


@interface DetailViewController ()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) DetailToolView *toolbar;
//@property (strong, nonatomic) UITableView *contactTableView;
//@property (strong, nonatomic) MMHorizontalListView *horListView;    //< 세로 주소록 테이블 뷰
@property (strong, nonatomic) EasyTableView *horListView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (assign) MemberType memType;
@property (strong, nonatomic) UIImage *photo;


@end

@implementation DetailViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//        self.view.backgroundColor = [UIColor whiteColor];
//    }
//    return self;
//}

// 상세정보 생성 타입별 구분
- (id)initWithType:(MemberType)type
{
    self = [super init];
    if (self) {
        // Custom initialization
//        if (!IS_LESS_THEN_IOS7) {
//            self.edgesForExtendedLayout = UIRectEdgeNone;
//        }
        _memType = type;
        self.view.backgroundColor = [UIColor whiteColor];

        _currentIdx = -1;
//        _contacts = [[NSMutableArray alloc] initWithArray:items];
        _contacts = [[NSMutableArray alloc] init];
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.opaque = NO;
    
    CGRect rect = self.view.frame;
    rect.size.height -= kDetailViewH;
    
    if (IS_LESS_THEN_IOS7) {
        rect.size.height -= 44.0f;
    } else {
        rect.size.height -= 64.0f;
    }

    // 세로 테이블 뷰
    [self setupHorizontalView];
//    [self setupContactTableView];


    // 하단 툴바 뷰
    _toolbar = [[DetailToolView alloc] initWithFrame:CGRectMake(0.0f, rect.size.height, rect.size.width, kDetailViewH) type:_memType];
    _toolbar.delegate = self;
    
    [self.view addSubview:_toolbar];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if ([_contacts count] > 0)
    {
        [_horListView reloadData];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // 설치 후 최초 접근 시, 가이드 화면 노출함 (클릭하면 상태 저장하고 이후부터 노출 안함)
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:kDetailGuide] boolValue])
    {
        DetailGuideViewController *detailGuideVC = [[DetailGuideViewController alloc] init];
        detailGuideVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:detailGuideVC animated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupHorizontalView
{
    CGRect rect = self.view.frame;
    rect.size.height -= kDetailViewH;
    
    CGFloat yOffset = 0.0f;
    
    if (IS_LESS_THEN_IOS7) {
        yOffset += 44.0f;
    } else {
        yOffset += 44.0f;
        rect.size.height -= yOffset;
    }
    
    CGRect frameRect = CGRectMake(-1.0f, yOffset, rect.size.width+1, rect.size.height);
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect numberOfColumns:1 ofWidth:321.0f];
    
	self.horListView = view;
	
	self.horListView.delegate					= self;
	self.horListView.tableView.backgroundColor	= UIColorFromRGB(0xf0f0f0); // 테이블 뷰 배경
	self.horListView.tableView.allowsSelection	= NO;
    self.horListView.tableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
//	self.horListView.tableView.separatorColor	= [UIColor darkGrayColor];
	self.horListView.cellBackgroundColor		= [UIColor clearColor];
	self.horListView.autoresizingMask			= UIViewAutoresizingFlexibleTopMargin;
    
    self.horListView.tableView.pagingEnabled    = YES;
	
	[self.view addSubview:self.horListView];
    
    
    //pageControl에 필요한 옵션을 적용한다.
    _pageControl.currentPage = 0;         //현재 페이지 index는 0
    _pageControl.numberOfPages = 3;        //페이지 갯수는 3개
    [_pageControl addTarget:self action:@selector(pageChangeValue:) forControlEvents:UIControlEventValueChanged]; //페이지 컨트롤 값변경시 이벤트 처리 등록
    
    [self.view addSubview:_pageControl];
}

#if 0
/// 주소록 테이블 뷰
//- (void)setupContactTableView
//{
//    //    _contactTableView = [[ContactTableView alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 200.0f, 200.0f) style:UITableViewStylePlain];
//    //    _contactTableView.dataSource = self;
//    //    _contactTableView.delegate = self;
//    //    _contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    //
//    //    [parentView addSubview:_contactTableView];
//    
//    CGFloat height = self.view.frame.size.height - 44.0f - kDetailViewH;
//    NSLog(@"sub 뷰 생성 높이 : %f", height);
//    
//    // 툴바 뷰
//    _toolbar = [[DetailToolView alloc] initWithFrame:CGRectMake(0.0f, height, 320.0f, kDetailViewH) type:_memType];
//    _toolbar.delegate = self;
//    
//    [self.view addSubview:_toolbar];
//    
//    
//    // 배경 뷰
//    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, height)];
//    _bgView.backgroundColor = [UIColor clearColor];
//    
//    [self.view addSubview:_bgView];
//    
//
//    // 세로 테이블 뷰
//    _horListView = [[MMHorizontalListView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, _bgView.frame.size.height)];
//    _horListView.backgroundColor = [UIColor orangeColor];
////    _horListView.backgroundColor = [UIColor whiteColor];// colorWithAlphaComponent:0.6];
//    //    _horListView.alpha = 1;
//    //    _horListView.opaque = YES;
//    _horListView.dataSource = self;
//    _horListView.delegate = self;
//    _horListView.cellSpacing = 0;
//    _horListView.pagingEnabled = YES;
////    _horListView.showsHorizontalScrollIndicator = NO;
////    _horListView.showsVerticalScrollIndicator = NO;
//    _horListView.contentSize = CGSizeMake(_horListView.frame.size.width * _contacts.count, _bgView.frame.size.height);
//    
////    _horListView.pageControl.currentPage = 0;
////    _horListView.pageControl.numberOfPages = _contacts.count;
//    
////    [UIView roundedLayer:_horContactTableView radius:5.0f shadow:YES];
//    
//    [self.view addSubview:_horListView];
//    
//    [self.horListView reloadData];
//    
//    //    UILabel *label = [[UILabel alloc] init];
//    //    label.text = @"Modal View";
//    //    label.textColor = [UIColor whiteColor];
//    //    label.backgroundColor = [UIColor blackColor];
//    //    label.opaque = YES;
//    //    [label setFrame:_horListView.frame];
//    //    [_horListView addSubview:label];
//}
#endif

- (void)setContacts:(NSMutableArray *)contacts
{
    _contacts = contacts;
    
//    _pageControl.currentPage = 0;                       //현재 페이지 index는 0
//    _pageControl.numberOfPages = [_contacts count];     //페이지 갯수는 3개

    for (NSDictionary *dict in _contacts) {
        NSLog(@"넘기는 학생 : %@", dict);
    }

    [self.horListView reloadData];
    
    // 해당 셀로 이동.
//    [self.horListView scrollToIndex:3 animated:YES];

}

- (void)setCurrentIdx:(NSInteger)currentIdx
{
    _currentIdx = currentIdx;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentIdx inSection:0];
    [_horListView selectCellAtIndexPath:indexPath animated:NO];
}

#pragma mark - Callback 
#pragma mark 툴바 버튼 이벤트 처리
- (void)didSelectedToolTag:(NSNumber *)type
{
    if (_memType == MemberTypeStudent)
    {
        NSDictionary *info = _contacts[_currentIdx];
        NSLog(@"선택된 셀 정보 (%d) : %@", _currentIdx, info);
        
        switch ([type intValue])
        {
            case 0: // phone call
                [self sendPhoneCall:info];
                break;
                
            case 1: // sms
                [self sendSMS:info];
                break;
                
            case 2: // email
                [self sendEmail:info];
                break;
                
            case 3: // address book
                [self onSavedToAddress:info];
                break;
                
            case 4: // kakao talk
                [self sendKakao:info];
                break;
                
            default:
                break;
        }
    }
    else
    {
        NSDictionary *info = _contacts[_currentIdx];
        NSLog(@"선택된 셀 정보 (%d) : %@", _currentIdx, info);
        
        switch ([type intValue])
        {
            case 0: // phone call
                [self sendPhoneCall:info];
                break;
                
            case 1: // email
                [self sendEmail:info];
                break;
                
            case 2: // address book
                [self onSavedToAddress:info];
                break;
                
            default:
                break;
        }
    }
}

// 전화 걸기
- (void)sendPhoneCall:(NSDictionary *)info
{
    NSString *phoneNumber;
    NSString *mobile = info[@"mobile"];
    NSString *tel = info[@"tel"];
    
    if (_memType == MemberTypeStudent)
    {
        if (mobile && mobile.length > 0) {
            [self sendCall:mobile];
        }
    }
    else
    {
        if ((MemberType)[[UserContext shared].memberType integerValue] == MemberTypeStudent)
        {
            [self sendCall:tel];
        }
        else
        {
            if (mobile.length > 0 && tel.length > 0) {
                // 번호가 둘다 있으면 팝업 띄움
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                         delegate:self
                                                                cancelButtonTitle:LocalizedString(@"Cancel", @"취소")
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:LocalizedString(mobile, nil), LocalizedString(tel, nil),
                                              nil];
                
                [actionSheet showInView:self.view];

            } else if (mobile.length > 0) {
                [self sendCall:mobile];
            } else if (tel.length > 0) {
                [self sendCall:tel];
            }
        }
    }
    
    if (phoneNumber && phoneNumber.length > 0) {
        NSLog(@"전화 걸기 : %@", phoneNumber);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

- (void)sendCall:(NSString *)number
{
    NSLog(@"전화 걸기 : %@", number);
    NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@", number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

// 문자 전송
- (void)sendSMS:(NSDictionary *)info
{
    if (info[@"mobile"])
    {
        NSString *phoneNumber = [@"sms:" stringByAppendingString:info[@"mobile"]];
        NSLog(@"전화 걸기 ; %@", phoneNumber);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

// 이메일 전송
- (void)sendEmail:(NSDictionary *)info
{
    if (info[@"email"])
    {
        NSString *phoneNumber = [@"mailto://" stringByAppendingString:info[@"email"]];
        NSLog(@"이메일 전송 : %@", phoneNumber);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

#pragma mark 연락처로 저장
/// 연락처 저장
- (void)onSavedToAddress:(NSDictionary *)info
{
    NSLog(@"연락처에 저장할 정보 : %@", info);
    [self showPersonViewController];

}

// 카카오톡 전달
- (void)sendKakao:(NSDictionary *)info
{
    NSLog(@"카카오톡 전달");
    KakaoMessageViewController *viewController = [[KakaoMessageViewController alloc] init];
    viewController.view.backgroundColor = [UIColor whiteColor];

//    [self presentModalViewController:viewController animated:YES];
    [self presentViewController:[[PortraitNavigationController alloc] initWithRootViewController:viewController] animated:YES completion:nil];
}

#pragma mark - UIActionSheet delegates
// 전화번호 선택
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }

    NSDictionary *info = _contacts[_currentIdx];
    NSLog(@"전화걸 셀 정보 (%d) : %@", _currentIdx, info);

    if (buttonIndex == 0)
    {
        [self sendCall:info[@"mobile"]];
    } else {
        [self sendCall:info[@"tel"]];
    }
}

#pragma mark -
#pragma mark Address Book Access
// 연락처에서 해당 사용자 찾기 (이름 기준)
- (void)searchForPersonInAddressBook:(ABAddressBookRef )ab
                            withName:(NSString *)fn
{
    NSMutableDictionary *info = nil;
//    if (_memType == MemberTypeStudent)
    {
//        Student *mo = _contacts[_currentIdx];
//        NSLog(@"선택된 셀 : %d, %@", _currentIdx, mo.name_en);
//        
//        // ( NSDictionary <- NSManagedObject )
//        NSArray *keys = [[[mo entity] attributesByName] allKeys];
//        info = [[mo dictionaryWithValuesForKeys:keys] mutableCopy];
        info = [_contacts[_currentIdx] mutableCopy];
        NSLog(@"찾는 셀 정보: %@", info);
    }
    
    if (info == nil) {
        return;
    }
    
    // Search for the person in the address book
//    CFArrayRef persons = ABAddressBookCopyPeopleWithName(ab, (__bridge CFStringRef)fn);
    NSArray *people = (NSArray *)CFBridgingRelease(ABAddressBookCopyPeopleWithName(ab, (__bridge CFStringRef)fn));
    
    
    // Display message if person not found in the address book
    if ((people != nil) && (people.count == 0))
    {
        // Creating new entry
        ABRecordRef newPerson = ABPersonCreate();
        CFErrorRef error = NULL;
        
        // Add Person Image
//        DetailViewCell *cell = (DetailViewCell *)[self MMHorizontalListView:_horListView cellAtIndex:_currentIdx];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentIdx inSection:0];
        UITableViewCell *cell = [_horListView.tableView cellForRowAtIndexPath:indexPath];
        DetailViewCell *detailCell = (DetailViewCell *)[cell viewWithTag:CELL_CONTENT_TAG];
        

//        UIImage *image = [UIImage imageNamed:@"icon.png"];
//        NSData *dataRef=UIImagePNGRepresentation(image);
//        CFDataRef dr = CFDataCreate(NULL, [data bytes], [data length]);
        NSData *dataRef = UIImagePNGRepresentation(detailCell.profileImage.image);
        ABPersonSetImageData(newPerson, (__bridge CFDataRef)dataRef, nil);
        
        // Setting basic properties
        ABRecordSetValue(newPerson, kABPersonFirstNameProperty,  (__bridge CFStringRef)info[@"name"], &error);
//        ABRecordSetValue(newPerson, kABPersonLastNameProperty, CFSTR("Smith"), &error);
        ABRecordSetValue(newPerson, kABPersonOrganizationProperty, (__bridge CFStringRef)info[@"company"], &error);
        ABRecordSetValue(newPerson, kABPersonJobTitleProperty, (__bridge CFStringRef)info[@"department"], &error);
        NSAssert( !error, @"Something bad happened here." );
        
        // Adding phone numbers
        ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        
        NSLog(@"나의 타입 (%@), 대상자 타입(%d)", [[UserContext shared] memberType], _memType);
        BOOL isPossibleSave = YES;
        MemberType myType = (MemberType)[[[UserContext shared] memberType] integerValue];
        
        // 로그인 사용자가 학생인 경우, 교수의 휴대전화를 저장 불가능.
        if (myType == MemberTypeStudent) {
            if (_memType == MemberTypeFaculty) {
                isPossibleSave = NO;
            }
        }
        
        if (isPossibleSave) {
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFStringRef)info[@"mobile"], kABPersonPhoneMobileLabel, NULL);
        }
        
        if (info[@"tel"]) {
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFStringRef)info[@"tel"], kABPersonPhoneMainLabel, NULL);
        }
//        ABMultiValueAddValueAndLabel(multiPhone,@"02-9809878", kABWorkLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
        
        
        // Adding emails
        ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiEmail,  (__bridge CFStringRef)info[@"email"], (CFStringRef)@"Email", NULL);
        ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail, &error);

        // Adding person to the address book
//        ABAddressBookAddRecord(addressBook, person, nil);
        
        
        // Show an alert if name is not in Contacts
//        UIAlertView *saveContact=[[UIAlertView alloc] initWithTitle:@"Save New Contact to iPhone?" message:fn delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Save!", nil];
//        saveContact.tag = 2;
//        [saveContact show];
        // Create an address book object
        ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
        picker.newPersonViewDelegate = self;
        picker.displayedPerson = newPerson;
        picker.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onNewPersonCancelClick)];

        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
        [self presentViewController:navigation animated:YES completion:nil];
        
    }
    else
    {
		ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:0];
		ABPersonViewController *picker = [[ABPersonViewController alloc] init];
		picker.personViewDelegate = self;
		picker.displayedPerson = person;
		// Allow users to edit the person’s information
		picker.allowsEditing = YES;

        [self.navigationController pushViewController:picker animated:YES];

    }
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController
shouldPerformDefaultActionForPerson:(ABRecordRef)person
                    property:(ABPropertyID)property
                  identifier:(ABMultiValueIdentifier)identifierForValue {
	return YES;
}

- (void)onNewPersonCancelClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isABAddressBookCreateWithOptionsAvailable
{
    return &ABAddressBookCreateWithOptions != NULL;
}

#pragma mark 연락처 저장 화면
-(void)showPersonViewController
{
    // Fetch the address book
    NSString *fullName = @"";
    NSMutableDictionary *info = nil;
//    if (_memType == MemberTypeStudent)
    {
//        Student *mo = _contacts[_currentIdx];
//        NSLog(@"선택된 셀 : %d, %@", _currentIdx, mo.name_en);
//        
//        // ( NSDictionary <- NSManagedObject )
//        NSArray *keys = [[[mo entity] attributesByName] allKeys];
//        info = [[mo dictionaryWithValuesForKeys:keys] mutableCopy];
        info = _contacts[_currentIdx];
        NSLog(@"찾는 셀 정보: %@", info);
        
        fullName = info[@"name"];
    }
    
    if (info == nil || fullName.length == 0) {
        return;
    }

    
    //Check if we are using iOS6
    if ([self isABAddressBookCreateWithOptionsAvailable])
    {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (ABAddressBookGetAuthorizationStatus() == 0) {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                // First time access has been granted
                [self searchForPersonInAddressBook:addressBook withName:fullName];
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == 3) {
            // The user has previously given access
            [self searchForPersonInAddressBook:addressBook withName:fullName];
        }
        else {
            // The user has previously denied access
            UIAlertView *deniedAccess=[[UIAlertView alloc] initWithTitle:@"Unable to Access Address Book" message:@"Change App Privacy Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [deniedAccess show];
        }
    }
    //If using iOS 4/5
    else {
//        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFErrorRef err;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
        [self searchForPersonInAddressBook:addressBook withName:fullName];
    }


//    // Request authorization to Address Book
//    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
//
//    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
//        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
//            // First time access has been granted, add the contact
////            [self _addContactToAddressBook];
//        });
//    }
//    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
//        // The user has previously given access, add the contact
////        [self _addContactToAddressBook];
//    }
//    else {
//        // The user has previously denied access
//        // Send an alert telling user to change privacy setting in settings app
//    }
    
//	// Search for the person named "Appleseed" in the address book
//	NSArray *people = (NSArray *)CFBridgingRelease(ABAddressBookCopyPeopleWithName(self.addressBook, CFSTR("Appleseed")));
//	// Display "Appleseed" information if found in the address book
//	if ((people != nil) && [people count])
//	{
//		ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:0];
//		ABPersonViewController *picker = [[ABPersonViewController alloc] init];
//		picker.personViewDelegate = self;
//		picker.displayedPerson = person;
//		// Allow users to edit the person’s information
//		picker.allowsEditing = YES;
//		[self.navigationController pushViewController:picker animated:YES];
//	}
//	else
//	{
//		// Show an alert if "Appleseed" is not in Contacts
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//														message:@"Could not find Appleseed in the Contacts application"
//													   delegate:nil
//											  cancelButtonTitle:@"Cancel"
//											  otherButtonTitles:nil];
//		[alert show];
//	}
}

// Check the authorization status of our application for Address Book
-(void)checkAddressBookAccess
{
//    switch (ABAddressBookGetAuthorizationStatus())
//    {
//            // Update our UI if the user has granted access to their Contacts
//        case  kABAuthorizationStatusAuthorized:
//            [self accessGrantedForAddressBook];
//            break;
//            // Prompt the user for access to Contacts if there is no definitive answer
//        case  kABAuthorizationStatusNotDetermined :
//            [self requestAddressBookAccess];
//            break;
//            // Display a message if the user has denied or restricted access to Contacts
//        case  kABAuthorizationStatusDenied:
//        case  kABAuthorizationStatusRestricted:
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning"
//                                                            message:@"Permission was not granted for Contacts."
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
//        }
//            break;
//        default:
//            break;
//    }
}

// Prompt the user for access to their Address Book data
-(void)requestAddressBookAccess
{
//    QuickContactsViewController * __weak weakSelf = self;
//    
//    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error)
//                                             {
//                                                 if (granted)
//                                                 {
//                                                     dispatch_async(dispatch_get_main_queue(), ^{
//                                                         [weakSelf accessGrantedForAddressBook];
//                                                         
//                                                     });
//                                                 }
//                                             });
}

// This method is called when the user has granted access to their address book data.
-(void)accessGrantedForAddressBook
{
    // Load data from the plist file
//	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Menu" ofType:@"plist"];
//	self.menuArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
//    [self.tableView reloadData];
}


- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
//    [[self navigationController] popViewControllerAnimated:YES];
}

//#pragma mark - MMHorizontalListViewDatasource methods
//
//- (NSInteger)MMHorizontalListViewNumberOfCells:(MMHorizontalListView *)horizontalListView
//{
//    NSInteger count = ([_contacts count] > 0)? [_contacts count] : 1;
//    return count;
//}
//
//- (CGFloat)MMHorizontalListView:(MMHorizontalListView *)horizontalListView widthForCellAtIndex:(NSInteger)index
//{
//    return 320;
//}
//
//- (MMHorizontalListViewCell*)MMHorizontalListView:(MMHorizontalListView *)horizontalListView cellAtIndex:(NSInteger)index
//{
//    // dequeue cell for reusability
//    DetailViewCell *cell = (DetailViewCell *)[horizontalListView dequeueCellWithReusableIdentifier:@"test"];
//
//    if (!cell) {
////        CGFloat height = [[UIScreen mainScreen] applicationFrame].size.height - 44.0f;
//        CGFloat height = _bgView.frame.size.height;
//        NSLog(@"셀 생성 높이 : %f", height);
//        
//        cell = [[DetailViewCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, height)];
////        cell.reusableIdentifier = @"test";  // assign the cell identifier for reusability
//    }
//
//    [cell setBackgroundColor:[UIColor colorWithRed:(arc4random() % 255)/255.0 green:(arc4random() % 255)/255.0 blue:(arc4random() % 255)/255.0 alpha:0.5]];
//
//    if ([_contacts count] > 0)
//    {
//        _currentIdx = index;
//        NSLog(@"현재 셀 인덱스 : %d", _currentIdx);
//        
//        if (_memType == MemberTypeFaculty) {
//            Faculty *faculty = _contacts[index];
//
//            // ( NSDictionary <- NSManagedObject )
//            NSArray *keys = [[[faculty entity] attributesByName] allKeys];
//            NSDictionary *info = [faculty dictionaryWithValuesForKeys:keys];
//        
//            cell.memType = MemberTypeFaculty;
//            [(DetailViewCell *)cell setCellInfo:info];
//        }
//        else if (_memType == MemberTypeStaff) {
//            
//        }
//        else if (_memType == MemberTypeStudent)
//        {
////            Student *mo = _contacts[index];
////            
////            // ( NSDictionary <- NSManagedObject )
////            NSArray *keys = [[[mo entity] attributesByName] allKeys];
////            NSDictionary *info = [mo dictionaryWithValuesForKeys:keys];
//            NSDictionary *info = _contacts[_currentIdx];
//            NSLog(@"찾는 셀 정보: %@", info);
//            
//            cell.memType = MemberTypeStudent;
//            [(DetailViewCell *)cell setCellInfo:info];
//            
////            UIImage *image = [cell.profileImage image];
//            NSLog(@"상세정보 셀 : (%d), %@", index, info[@"name_en"]);
////            NSLog(@"상세정보 이미지 : %@", image);
//        }
//        
//    }
//#if (0)
//    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 300)];
//    Faculty *faculty = _contacts[index];
//
//    nameLabel.text = faculty.name;
//    [cell addSubview:nameLabel];
//#endif
//    return cell;
//}

//#pragma mark - MMHorizontalListViewDelegate methods
//
//- (void)MMHorizontalListView:(MMHorizontalListView*)horizontalListView didSelectCellAtIndex:(NSInteger)index
//{
//    //do something when a cell is selected
//    NSLog(@"selected cell %d", index);
////    _currentIdx = index;
//
//}
//
//- (void)MMHorizontalListView:(MMHorizontalListView *)horizontalListView didDeselectCellAtIndex:(NSInteger)index
//{
//    // do something when a cell is deselected
//    NSLog(@"deselected cell %d", index);
////    _currentIdx = index;
//
//}



#pragma mark - EasyTableViewDelegate

// These delegate methods support both example views - first delegate method creates the necessary views
- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect
{
    CGFloat yOffset = 0;
    if (!IS_LESS_THEN_IOS7) {
        yOffset = 20.0f;
    }
    DetailViewCell *cellView = [[DetailViewCell alloc] initWithFrame:CGRectMake(0, yOffset, rect.size.width, rect.size.height-yOffset)];
#ifdef USE_SCROLL
    if (IS_LESS_THEN_IOS7 && ([[UIScreen mainScreen] bounds].size.height < 568)) {
        cellView.contentSize = CGSizeMake(320.0f, cellView.frame.size.height + 50.0f);  // iPhone5가 아닌 경우, 화면 내용이 잘릴 수 있어 스크롤 뷰로 변경하고 컨텐츠 사이즈 임의로 조정
    }
#endif
    return cellView;
    
    
	CGRect labelRect		= CGRectMake(10, 10, rect.size.width-20, rect.size.height-20);
	UILabel *label			= [[UILabel alloc] initWithFrame:labelRect];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
	label.textAlignment		= UITextAlignmentCenter;
#else
	label.textAlignment		= NSTextAlignmentCenter;
#endif
	label.textColor			= [UIColor whiteColor];
	label.font				= [UIFont boldSystemFontOfSize:60];
	
	// Use a different color for the two different examples
    label.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
	
//	UIImageView *borderView		= [[UIImageView alloc] initWithFrame:label.bounds];
//	borderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//	borderView.tag				= BORDER_VIEW_TAG;
//	
//	[label addSubview:borderView];
    
	return label;
}


// Second delegate populates the views with data from a data source

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"셀 표시 : %d", indexPath.row);
    
    if ([_contacts count] == 0) {
        return;
    }
    
    DetailViewCell *cell = (DetailViewCell *)view;
#ifdef USE_SCROLL
    cell.contentOffset = CGPointZero;   // 해당 셀이 ScrollView일 경우에 해당
#endif
//    UILabel *label = (UILabel *)view;
//    DetailViewCell *cell = [[DetailViewCell alloc] init];
//    
//    [label addSubview:cell];
//
//    Student *mo = _contacts[indexPath.row];
//    NSLog(@"mo: %@, %@, %@", mo.name, mo.name_en, mo.mobile);
//    
//    // ( NSDictionary <- NSManagedObject )
//    NSArray *keys = [[[mo entity] attributesByName] allKeys];
//    NSDictionary *info = [mo dictionaryWithValuesForKeys:keys];
    NSDictionary *info = _contacts[indexPath.row];
    NSLog(@"상세 정보 : %@", info);

    if ([[UserContext shared].language isEqualToString:kLMKorean]) {
        if (info[@"name"]) {
            self.navigationItem.title = info[@"name"];
        }
    } else {
        if (info[@"name_en"]) {
            self.navigationItem.title = info[@"name_en"];
        }
    }

    
    if (_memType == MemberTypeFaculty) {
        [(DetailViewCell *)cell setMemType:MemberTypeFaculty];
    } else if (_memType == MemberTypeStaff) {
        [(DetailViewCell *)cell setMemType:MemberTypeStaff];
    }
    else if (_memType == MemberTypeStudent)
    {
        [(DetailViewCell *)cell setMemType:MemberTypeStudent];
        
        // 로그인 유저 타입
        MemberType myType = (MemberType)[[[UserContext shared] memberType] integerValue];
        
        // 로그인 교육 과정
        CourseType myClassType = CourseTypeUnknown;
        NSString *myCourseStr = [[UserContext shared] myCourse];
        if ([myCourseStr isEqualToString:@"EMBA"]) {
            myClassType = CourseTypeEMBA;
        } else if ([myCourseStr isEqualToString:@"GMBA"]) {
            myClassType = CourseTypeGMBA;
        } else if ([myCourseStr isEqualToString:@"SMBA"]) {
            myClassType = CourseTypeSMBA;
        }
        
        CourseType cellClassType = CourseTypeUnknown;
        NSString *courseStr = @"";
        
        if ([info[@"course.course"] isKindOfClass:[NSString class]]) {
            courseStr = info[@"course.course"];
        } else if ([info[@"course"] isKindOfClass:[NSString class]]) {
            courseStr = info[@"course"];
        }
        
        if (courseStr.length > 0) {
            //            if (_memType == MemberTypeFaculty) {
            //            } else if (_memType == MemberTypeStaff) {
            //            } else
            if (_memType == MemberTypeStudent)
            {
                if ([courseStr isEqualToString:@"EMBA"]) {
                    cellClassType = CourseTypeEMBA;
                } else if ([courseStr isEqualToString:@"GMBA"]) {
                    cellClassType = CourseTypeGMBA;
                } else if ([courseStr isEqualToString:@"SMBA"]) {
                    cellClassType = CourseTypeSMBA;
                }
            }
        }

        // 이메일 공개 표시
        if (myType == MemberTypeStudent && ([info[@"share_email"] isEqualToString:@"n"] ||
                                            ([info[@"share_email"] isEqualToString:@"q"] && myClassType != cellClassType) ||
                                            ([info[@"share_email"] isEqualToString:@"q"] && myClassType == cellClassType && cellClassType == CourseTypeUnknown))) {
            _toolbar.emailBtn.enabled = NO;
        } else {
            _toolbar.emailBtn.enabled = YES;
        }
        
        if (myType == MemberTypeStudent && ([info[@"share_mobile"] isEqualToString:@"n"] ||
                                            ([info[@"share_mobile"] isEqualToString:@"q"] && myClassType != cellClassType) ||
                                            ([info[@"share_mobile"] isEqualToString:@"q"] && myClassType == cellClassType && cellClassType == CourseTypeUnknown))) {
            _toolbar.telBtn.enabled = NO;
            _toolbar.smsBtn.enabled = NO;
        } else {
            _toolbar.telBtn.enabled = YES;
            _toolbar.smsBtn.enabled = YES;
        }

    } else {
        return;
    }
    [(DetailViewCell *)cell setCellInfo:info];
    

//	UILabel *label	= (UILabel *)view;
//	label.text		= [NSString stringWithFormat:@"%i", indexPath.row];
	
	// selectedIndexPath can be nil so we need to test for that condition
//	BOOL isSelected = (easyTableView.selectedIndexPath) ? ([easyTableView.selectedIndexPath compare:indexPath] == NSOrderedSame) : NO;
//	[self borderIsSelected:isSelected forView:view];
}

// Optional delegate to track the selection of a particular cell

- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView
{
    NSLog(@"셀 : (%d)", indexPath.row);

//	[self borderIsSelected:YES forView:selectedView];
//	
//	if (deselectedView)
//		[self borderIsSelected:NO forView:deselectedView];
	
//	UILabel *label	= (UILabel *)selectedView;
//	bigLabel.text	= label.text;
}

- (void)easyTableView:(EasyTableView *)easyTableView scrolledToOffset:(CGPoint)contentOffset
{
    NSLog(@"셀(스크롤) 정보 : (%f, %f)", contentOffset.x, contentOffset.y);
    if ([_contacts count] > 0)
    {
        NSInteger index = (NSInteger)contentOffset.x / 320;
        if (index < [_contacts count]) {
            _currentIdx = index;
            NSLog(@"셀 index : %d", _currentIdx);
            NSLog(@"셀 정보 : %@", _contacts[_currentIdx]);
        }
    }
}

- (void)easyTableView:(EasyTableView *)easyTableView scrolledToFraction:(CGFloat)fraction
{
    NSLog(@"셀(scroll) 정보 : (%f)", fraction);
}

#pragma mark - EasyTableView delegate methods

// Delivers the number of cells in each section, this must be implemented if numberOfSectionsInEasyTableView is implemented
-(NSUInteger)numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section
{
    NSInteger count = ([_contacts count] > 0)? [_contacts count] : 1;
    return count;
}

//페이지 컨트롤 값이 변경될때, 스크롤뷰 위치 설정
- (void) pageChangeValue:(id)sender {
//    UIPageControl *pControl = (UIPageControl *) sender;
//    [scrollView setContentOffset:CGPointMake(pControl.currentPage*320, 0) animated:YES];
}

//스크롤이 변경될때 page의 currentPage 설정
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    UIScrollView *scrollView = sender;
    CGFloat pageWidth = scrollView.frame.size.width;
    _pageControl.currentPage = floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1;
}


@end
