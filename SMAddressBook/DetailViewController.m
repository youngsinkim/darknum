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


#define kDetailViewH    60.0f

@interface DetailViewController ()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) DetailToolView *toolbar;
@property (strong, nonatomic) UITableView *contactTableView;
@property (strong, nonatomic) MMHorizontalListView *horListView;    //< 세로 주소록 테이블 뷰
@property (assign) NSInteger currentIdx;
@property (assign) MemberType memType;
@property (strong, nonatomic) UIImage *photo;


@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

// 상세정보 생성 타입별 구분
- (id)initWithType:(MemberType)type
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];

        _memType = type;
        _currentIdx = -1;
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    self.view.backgroundColor = [UIColor lightGrayColor];
    if (!IS_LESS_THEN_IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // 세로 테이블 뷰
    [self setupContactTableView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 주소록 테이블 뷰
- (void)setupContactTableView
{
    //    _contactTableView = [[ContactTableView alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 200.0f, 200.0f) style:UITableViewStylePlain];
    //    _contactTableView.dataSource = self;
    //    _contactTableView.delegate = self;
    //    _contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //
    //    [parentView addSubview:_contactTableView];
    
    CGFloat height = self.view.frame.size.height - 64.0f - kDetailViewH;
    NSLog(@"sub 뷰 생성 높이 : %f", height);
    
    // 툴바 뷰
    _toolbar = [[DetailToolView alloc] initWithFrame:CGRectMake(0.0f, height, 320.0f, kDetailViewH)];
    _toolbar.delegate = self;
    
    [self.view addSubview:_toolbar];
    
    
    // 배경 뷰
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, height)];
    _bgView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_bgView];
    

    // 세로 테이블 뷰
    _horListView = [[MMHorizontalListView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, _bgView.frame.size.height)];
    _horListView.backgroundColor = [UIColor orangeColor];
//    _horListView.backgroundColor = [UIColor whiteColor];// colorWithAlphaComponent:0.6];
    //    _horListView.alpha = 1;
    //    _horListView.opaque = YES;
    _horListView.dataSource = self;
    _horListView.delegate = self;
    _horListView.cellSpacing = 0;
    _horListView.pagingEnabled = YES;
//    _horListView.showsHorizontalScrollIndicator = NO;
//    _horListView.showsVerticalScrollIndicator = NO;
    _horListView.contentSize = CGSizeMake(_horListView.frame.size.width * _contacts.count, _bgView.frame.size.height);
    
//    _horListView.pageControl.currentPage = 0;
//    _horListView.pageControl.numberOfPages = _contacts.count;
    
//    [UIView roundedLayer:_horContactTableView radius:5.0f shadow:YES];
    
    [self.view addSubview:_horListView];
    
    [self.horListView reloadData];
    
    //    UILabel *label = [[UILabel alloc] init];
    //    label.text = @"Modal View";
    //    label.textColor = [UIColor whiteColor];
    //    label.backgroundColor = [UIColor blackColor];
    //    label.opaque = YES;
    //    [label setFrame:_horListView.frame];
    //    [_horListView addSubview:label];
}

- (void)setContacts:(NSMutableArray *)contacts
{
    _contacts = contacts;
    
    [self.horListView reloadData];
    
    // 해당 셀로 이동.
    [self.horListView scrollToIndex:3 animated:YES];

}

#pragma mark - Callback 
- (void)didSelectedToolTag:(NSNumber *)type
{
    if (_memType == MemberTypeFaculty)
    {
        switch ([type intValue])
        {
            case 0:     break;
                
            default:    break;
        }
    }
    else if (_memType == MemberTypeStaff)
    {
        
    }
    else if (_memType == MemberTypeStudent)
    {
        Student *mo = _contacts[_currentIdx];
        NSLog(@"선택된 셀 : %d, %@", _currentIdx, mo);

        // ( NSDictionary <- NSManagedObject )
        NSArray *keys = [[[mo entity] attributesByName] allKeys];
        NSDictionary *info = [mo dictionaryWithValuesForKeys:keys];

        [self onSavedToAddress:info];
        
        switch ([type intValue])
        {
            case 0:     break;
                
            default:    break;
        }
    }
}

- (void)onSavedToAddress:(NSDictionary *)info
{
    NSLog(@"연락처에 저장할 정보 : %@", info);

    [self showPersonViewController];

}

#pragma mark -
#pragma mark Address Book Access
- (void)searchForPersonInAddressBook:(ABAddressBookRef )ab
                            withName:(NSString *)fn
{
    NSMutableDictionary *info = nil;
    if (_memType == MemberTypeStudent)
    {
        Student *mo = _contacts[_currentIdx];
        NSLog(@"선택된 셀 : %d, %@", _currentIdx, mo);
        
        // ( NSDictionary <- NSManagedObject )
        NSArray *keys = [[[mo entity] attributesByName] allKeys];
        info = [[mo dictionaryWithValuesForKeys:keys] mutableCopy];
    }
    
    if (info == nil) {
        return;
    }
    
    // Search for the person in the address book
//    CFArrayRef persons = ABAddressBookCopyPeopleWithName(ab, (__bridge CFStringRef)fn);
    NSArray *people = (NSArray *)CFBridgingRelease(ABAddressBookCopyPeopleWithName(ab, CFSTR("Appleseed")));
    
    
    // Display message if person not found in the address book
    if ((people != nil) && (people.count == 0))
    {
        // Creating new entry
        ABRecordRef newPerson = ABPersonCreate();
        CFErrorRef error = NULL;
        
        // Add Person Image

//        UIImage *image = [UIImage imageNamed:@"icon.png"];
//        NSData *dataRef=UIImagePNGRepresentation(image);
//        CFDataRef dr = CFDataCreate(NULL, [data bytes], [data length]);
//        NSData *dataRef = UIImagePNGRepresentation(personImageView.image);
//        ABPersonSetImageData(newPerson, (CFDataRef)dataRef, nil);
        
        // Setting basic properties
        ABRecordSetValue(newPerson, kABPersonFirstNameProperty,  (__bridge CFStringRef)info[@"name"], &error);
//        ABRecordSetValue(newPerson, kABPersonLastNameProperty, CFSTR("Smith"), &error);
        ABRecordSetValue(newPerson, kABPersonOrganizationProperty, (__bridge CFStringRef)info[@"company"], &error);
        ABRecordSetValue(newPerson, kABPersonJobTitleProperty, (__bridge CFStringRef)info[@"department"], &error);
        NSAssert( !error, @"Something bad happened here." );
        
        // Adding phone numbers
        ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFStringRef)info[@"mobile"], kABPersonPhoneMobileLabel, NULL);
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

-(void)showPersonViewController
{
    // Fetch the address book
    NSString *fullName = @"";
    NSMutableDictionary *info = nil;
    if (_memType == MemberTypeStudent)
    {
        Student *mo = _contacts[_currentIdx];
        NSLog(@"선택된 셀 : %d, %@", _currentIdx, mo);
        
        // ( NSDictionary <- NSManagedObject )
        NSArray *keys = [[[mo entity] attributesByName] allKeys];
        info = [[mo dictionaryWithValuesForKeys:keys] mutableCopy];
        
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
        ABAddressBookRef addressBook = ABAddressBookCreate();
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
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Menu" ofType:@"plist"];
//	self.menuArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
//    [self.tableView reloadData];
}


- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    [[self navigationController] popViewControllerAnimated:YES];
    [newPersonView dismissModalViewControllerAnimated:YES];
}

#pragma mark - MMHorizontalListViewDatasource methods

- (NSInteger)MMHorizontalListViewNumberOfCells:(MMHorizontalListView *)horizontalListView
{
    NSInteger count = ([_contacts count] > 0)? [_contacts count] : 1;
    return count;
}

- (CGFloat)MMHorizontalListView:(MMHorizontalListView *)horizontalListView widthForCellAtIndex:(NSInteger)index
{
    return 320;
}

- (MMHorizontalListViewCell*)MMHorizontalListView:(MMHorizontalListView *)horizontalListView cellAtIndex:(NSInteger)index
{
    // dequeue cell for reusability
    DetailViewCell *cell = (DetailViewCell *)[horizontalListView dequeueCellWithReusableIdentifier:@"test"];

    if (!cell) {
//        CGFloat height = [[UIScreen mainScreen] applicationFrame].size.height - 44.0f;
        CGFloat height = _bgView.frame.size.height;
        NSLog(@"셀 생성 높이 : %f", height);
        
        cell = [[DetailViewCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, height)];
        cell.reusableIdentifier = @"test";  // assign the cell identifier for reusability
    }

    [cell setBackgroundColor:[UIColor colorWithRed:(arc4random() % 255)/255.0 green:(arc4random() % 255)/255.0 blue:(arc4random() % 255)/255.0 alpha:0.5]];

    if ([_contacts count] > 0)
    {
        _currentIdx = index;
        NSLog(@"현재 셀 인덱스 : %d", _currentIdx);
        
        if (_memType == MemberTypeFaculty) {
            Faculty *faculty = _contacts[index];

            // ( NSDictionary <- NSManagedObject )
            NSArray *keys = [[[faculty entity] attributesByName] allKeys];
            NSDictionary *info = [faculty dictionaryWithValuesForKeys:keys];
        
            cell.memType = MemberTypeFaculty;
            [(DetailViewCell *)cell setCellInfo:info];
        }
        else if (_memType == MemberTypeStaff) {
            
        }
        else if (_memType == MemberTypeStudent)
        {
            Student *mo = _contacts[index];
            
            // ( NSDictionary <- NSManagedObject )
            NSArray *keys = [[[mo entity] attributesByName] allKeys];
            NSDictionary *info = [mo dictionaryWithValuesForKeys:keys];
            
            cell.memType = MemberTypeStudent;
            [(DetailViewCell *)cell setCellInfo:info];
        }
        
    }
#if (0)
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 300)];
    Faculty *faculty = _contacts[index];

    nameLabel.text = faculty.name;
    [cell addSubview:nameLabel];
#endif
    return cell;
}

#pragma mark - MMHorizontalListViewDelegate methods

- (void)MMHorizontalListView:(MMHorizontalListView*)horizontalListView didSelectCellAtIndex:(NSInteger)index
{
    //do something when a cell is selected
    NSLog(@"selected cell %d", index);

}

- (void)MMHorizontalListView:(MMHorizontalListView *)horizontalListView didDeselectCellAtIndex:(NSInteger)index
{
    // do something when a cell is deselected
    NSLog(@"deselected cell %d", index);
}


@end
