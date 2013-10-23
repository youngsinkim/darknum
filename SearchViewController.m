//
//  SearchViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 7..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultViewController.h"
#import "Course.h"
#import <ActionSheetPicker.h>

@interface SearchViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (strong, nonatomic) NSMutableArray *courses;
//@property (strong, nonatomic) NSMutableArray *classes;
@property (strong, nonatomic) NSMutableArray *courseArray;
//@property (retain, nonatomic) NSString *selectedText;
//@property (assign, nonatomic) NSInteger selectedTextTag;
@property (assign, nonatomic) NSInteger selectedCourseIdx;      // 선택된 과정 index

@property (strong, nonatomic) UILabel *courseLabel;
@property (strong, nonatomic) UILabel *classLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *optionLabel;
@property (strong, nonatomic) UITextField *courseTextField;
@property (strong, nonatomic) UITextField *classTextField;
@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UIButton *courseDelBtn;
@property (strong, nonatomic) UIButton *classDelBtn;
@property (strong, nonatomic) UIButton *optionBtn;
@property (strong, nonatomic) UIButton *searchBtn;
//@property (strong, nonatomic) UIActionSheet *actionSheet;
//@property (strong, nonatomic) UIPickerView *pickerView;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = LocalizedString(@"Search", @"검색");
        
//        _courses = [[NSMutableArray alloc] init];
//        _classes = [[NSMutableArray alloc] init];
        _courseArray = [[NSMutableArray alloc] init];
        _selectedCourseIdx = -1;
//        _selectedTextTag = 0;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // CoreData 컨텍스트 지정
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (self.managedObjectContext == nil)
    {
        self.managedObjectContext = [appDelegate managedObjectContext];
        NSLog(@"After managedObjectContext: %@",  self.managedObjectContext);
    }

    // 과정 목록 db에서 읽어오기
    NSArray *courses = [self loadDBCourses];
    
    // 기수 목록 db에서 읽어오기
    for (NSDictionary *courseInfo in courses)
    {
        NSMutableDictionary *subInfo = [[NSMutableDictionary alloc] init];
        NSMutableArray *classArray = [[NSMutableArray alloc] init];

        [subInfo setValuesForKeysWithDictionary:courseInfo];
        NSLog(@"과정 : %@", courseInfo);
        
        NSArray *tmpClass = [self loadDBCourseClasses:courseInfo[@"course"]];
        for (NSDictionary *classInfo in tmpClass)
        {
            NSLog(@"기수 : %@ (%@)", classInfo[@"title"], classInfo[@"title_en"]);
            if ([[UserContext shared].language isEqualToString:kLMKorean]) {
                [classArray addObject:classInfo[@"title"]];
            } else {
                [classArray addObject:classInfo[@"title_en"]];
            }
        }
        
        [subInfo setValue:classArray forKey:@"sub"];
        
        [_courseArray addObject:subInfo];
        NSLog(@"과정 추가 : %@", subInfo);
    }
    
    // 과정/기수 목록으로 검색 UI 구성
    [self setupSearchUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSearchUI
{
    CGRect rect = self.view.bounds;
    CGFloat yOffset = 15.0f;
    CGFloat xOffset = 75.0f;
    
    if (!IS_LESS_THEN_IOS7) {
        yOffset += 64.0f;
    }
    
    // 검색 조건 배경 뷰
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, 205.0f)];
    bgView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1f];
    
    [self.view addSubview:bgView];
    
    // 과정 text
    _courseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, yOffset, 70.0f, 22.0f)];
    [_courseLabel setTextColor:[UIColor blackColor]];
    [_courseLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
    [_courseLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [_courseLabel setTextAlignment:NSTextAlignmentCenter];
    [_courseLabel setText:LocalizedString(@"course", @"과정")];
    
    [bgView addSubview:_courseLabel];
    

    // 과정 선택
    _courseTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, yOffset, 200.0f, 22.0f)];
    _courseTextField.tag = 300;
    _courseTextField.background = [[UIImage imageNamed:@"input_text_border"] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    _courseTextField.delegate = self;
    _courseTextField.placeholder = LocalizedString(@" 과정을 선택하세요", @"과정을 선택하세요");
    _courseTextField.text = @"";
    [_courseTextField setTextColor:[UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f]];
    [_courseTextField setTextAlignment:NSTextAlignmentLeft];
    [_courseTextField setFont:[UIFont systemFontOfSize:14.0f]];
    [_courseTextField addTarget:self action:@selector(onCourseTextFieldTouched:) forControlEvents:UIControlEventTouchDown];
    
    [bgView addSubview:_courseTextField];
    
    
    // 과정명 삭제 버튼
    _courseDelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_courseDelBtn setFrame:CGRectMake(_courseTextField.frame.origin.x + _courseTextField.frame.size.width - 18, yOffset + 4, 14, 14.0f)];
    [_courseDelBtn setBackgroundImage:[UIImage imageNamed:@"search_xbtn"] forState:UIControlStateNormal];
    [_courseDelBtn addTarget:self action:@selector(onCourseDelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_courseDelBtn];
    [_courseDelBtn setHidden:YES];
    yOffset += 30.0f;

    
    // 기수 text
    _classLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, yOffset, 70.0f, 22.0f)];
    [_classLabel setTextColor:[UIColor blackColor]];
    [_classLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
    [_classLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [_classLabel setTextAlignment:NSTextAlignmentCenter];
    [_classLabel setText:LocalizedString(@"classes", @"기수")];
    
    [bgView addSubview:_classLabel];

    
    // 기수 선택
    _classTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, yOffset, 200.0f, 22.0f)];
    _classTextField.tag = 301;
    _classTextField.background = [[UIImage imageNamed:@"input_text_border"] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    _classTextField.delegate = self;
    _classTextField.placeholder = LocalizedString(@"All classes", @"기수 선택 안내");
    _classTextField.text = @"";
    [_classTextField setTextColor:[UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f]];
    [_classTextField setTextAlignment:NSTextAlignmentLeft];
    [_classTextField setFont:[UIFont systemFontOfSize:14.0f]];
    [_classTextField addTarget:self action:@selector(onClassTextFieldTouched:) forControlEvents:UIControlEventTouchDown];
    
    [bgView addSubview:_classTextField];
    
    // 과정명 삭제 버튼
    _classDelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_classDelBtn setFrame:CGRectMake(_classTextField.frame.origin.x + _classTextField.frame.size.width - 18, yOffset + 4, 14, 14.0f)];
    [_classDelBtn setBackgroundImage:[UIImage imageNamed:@"search_xbtn"] forState:UIControlStateNormal];
    [_classDelBtn addTarget:self action:@selector(onClassDelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_classDelBtn];
    [_classDelBtn setHidden:YES];
    yOffset += 30.0f;

    
//    _coursePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(xOffset, yOffset + 10.0f, 200.0f, 40.0f)];
//    _coursePicker.dataSource = self;
//    _coursePicker.delegate = self;
//    _coursePicker.tag = 300;
//
//    
//    [bgView addSubview:_coursePicker];
//    yOffset += 40.0f;
//    
//    // 기수 선택
//    _classPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(xOffset, yOffset + 10.0f, 200.0f, 40.0f)];
//    _classPicker.dataSource = self;
//    _classPicker.delegate = self;
//    _classPicker.tag = 301;
//    
//    [bgView addSubview:_classPicker];
//    yOffset += 40.0f;
    
    // 이름 text
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, yOffset, 70.0f, 22.0f)];
    [_nameLabel setTextColor:[UIColor blackColor]];
    [_nameLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
    [_nameLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [_nameLabel setTextAlignment:NSTextAlignmentCenter];
    [_nameLabel setText:LocalizedString(@"name", @"이름")];
    
    [bgView addSubview:_nameLabel];

    
    // 이름
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, yOffset, 200.0f, 22.0f)];
    _nameTextField.tag = 400;
    _nameTextField.background = [[UIImage imageNamed:@"input_text_border"] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    _nameTextField.delegate = self;
    _nameTextField.placeholder = LocalizedString(@"Search name", @"이름 검색");
    _nameTextField.text = @"";
    [_nameTextField setTextColor:[UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f]];
    [_nameTextField setTextAlignment:NSTextAlignmentLeft];
    [_nameTextField setFont:[UIFont systemFontOfSize:14.0f]];
//    [_nameTextField addTarget:self action:@selector(onClassTextFieldTouched:) forControlEvents:UIControlEventTouchDown];
    
    [bgView addSubview:_nameTextField];
    yOffset += 30.0f;
    
    
    // 옵션 text
    _optionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, yOffset, 70.0f, 27.0f)];
    [_optionLabel setTextColor:[UIColor blackColor]];
    [_optionLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1f]];
    [_optionLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [_optionLabel setTextAlignment:NSTextAlignmentCenter];
    [_optionLabel setText:LocalizedString(@"option", @"옵션")];
    
    [bgView addSubview:_optionLabel];

    
    // 옵션 버튼
    _optionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _optionBtn.frame = CGRectMake(xOffset, yOffset, 200.0f, 27.0f);
    [_optionBtn setTitle:LocalizedString(@"option string", @"즐겨찾기 내에서 검색") forState:UIControlStateNormal];
    [_optionBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_optionBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_optionBtn.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [_optionBtn setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    [_optionBtn setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateSelected];
    [_optionBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_optionBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [_optionBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];

    [_optionBtn addTarget:self action:@selector(onOptionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [bgView addSubview:_optionBtn];
    yOffset += 50.0f;

    
    // 검색 버튼
    _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_searchBtn setFrame:CGRectMake((rect.size.width - 100.0f) / 2.0f, yOffset, 100.0f, 26.0f)];
    [_searchBtn setBackgroundImage:[[UIImage imageNamed:@"btn_white"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f] forState:UIControlStateNormal];
    [_searchBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_searchBtn setTitle:LocalizedString(@"Search", @"검색") forState:UIControlStateNormal];
    [_searchBtn addTarget:self action:@selector(onSearchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_searchBtn];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"Touched!");
    [self.view endEditing:YES];
//    [textField resignFirstResponder];
}

- (void)viewDidUnload
{
    self.courseTextField = nil;
    self.classTextField = nil;
    self.nameTextField = nil;
    self.optionBtn = nil;
    self.searchBtn = nil;

    [super viewDidUnload];
}


#pragma mark - DB methods

// 전체 과정 목록 가져오기 (group by)
- (NSArray *)loadDBCourses
{
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // select
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // * (column)
    NSAttributeDescription *type = [entity.attributesByName objectForKey:@"course"];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:type, nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:type]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    // where
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(courseclass != '')"];
    [fetchRequest setPredicate:predicate];
    
    // order by (ZCOURSECLASS)
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
        return fetchedObjects;
    }
    return nil;
}

/// 과정별 기수 목록
- (NSArray *)loadDBCourseClasses:(NSString *)courseName//:(NSInteger)tabIndex
{
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSAttributeDescription *type = [entity.attributesByName objectForKey:@"title"];
    NSAttributeDescription *type2 = [entity.attributesByName objectForKey:@"title_en"];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:type, type2, nil]];
//    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:type]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    // where
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(course == %@)", courseName];
    [fetchRequest setPredicate:predicate];
    
    // order by (ZCOURSECLASS)
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
        return fetchedObjects;
    }
    return nil;
}

#pragma mark - UI Control Events

- (void)onCourseTextFieldTouched:(UITextField *)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        }
        NSLog(@"text field : (%d)%@", selectedIndex, _courseTextField.text);
        _selectedCourseIdx = selectedIndex;
        _classTextField.text = nil;
        [_courseDelBtn setHidden:NO];
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    

    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in _courseArray) {
        [items addObject:dict[@"course"]];
    }

    if ([items count] > 0) {
        [ActionSheetStringPicker showPickerWithTitle:nil rows:items initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    }
}

- (void)onClassTextFieldTouched:(UITextField *)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        }
        NSLog(@"text field : %@ == %@", selectedValue, _courseTextField.text);
        [_classDelBtn setHidden:NO];
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    
    
//    NSMutableArray *items = [[NSMutableArray alloc] init];
//    for (NSDictionary *dict in _courseArray) {
//        [items addObject:dict[@"sub"]];
//    }
    if (_selectedCourseIdx < 0)
    {
        NSLog(@"Course Index Error !!");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"과정을 먼저 선택하시오.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];

        [alertView show];
        
        return;
    }
    
    NSDictionary *itemInfo = _courseArray[_selectedCourseIdx];
    NSLog(@"기수 리스트 구성 정보 : %@", itemInfo);
    
    if ([itemInfo isKindOfClass:[NSDictionary class]]) {
        [ActionSheetStringPicker showPickerWithTitle:nil rows:itemInfo[@"sub"] initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    }
}

/// 과정명 삭제
- (void)onCourseDelBtnClicked:(UIButton *)sender
{
    _courseTextField.text = @"";
    [sender setHidden:YES];
}

/// 기수명 삭제
- (void)onClassDelBtnClicked:(id)sender
{
    _classTextField.text = @"";
    [sender setHidden:YES];
}

- (void)onOptionBtnClicked:(id)sender
{
    [(UIButton *)sender setSelected:![(UIButton *)sender isSelected]];
    NSLog(@"cell selected(%d)", [sender isSelected]);
    
//    if ([_delegate respondsToSelector:@selector(onFavoriteCheckTouched:)]) {
//        [_delegate onFavoriteCheckTouched:self];
//    }
}

// 검색 버튼
- (void)onSearchBtnClicked:(id)sender
{
    if ([_nameTextField.text length] == 0) {
        if ([_courseTextField.text length] == 0 || [_classTextField.text length] == 0 )
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"(과정+기수) 또는 (이름)을 검색조건에\n    설정하여 주세요.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
            
            [alertView show];
            
            return;
        }
    }
    // 검색 조건 구성
//    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    NSDictionary *info = @{@"course":_courseTextField.text, @"courseclass":_classTextField.text, @"name":_nameTextField.text, @"islocal":[NSNumber numberWithInteger:_optionBtn.selected]};
    
    SearchResultViewController *viewController = [[SearchResultViewController alloc] initWithInfo:info];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag != 400) {
        return NO;
    }
    
//    _selectedTextTag = textField.tag;
//    NSLog(@"선택된 컨트롤 tag : %d", _selectedTextTag);
//    
//    [self ShowPicker:textField];
    
    return YES;
}


/// 리턴 키를 누를 때 실행
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // keyboard 감추기
	[textField resignFirstResponder];
    
//    if (textField == _nameTextField) {
//        // 다음(비밀번호) 컨트롤 focus
//        [_pwdTextField becomeFirstResponder];
//    }
    
	return YES;
}

/// textField의 내용이 변경될 때 실행
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    NSLog(@"이름 : %@", string);
    //    NSInteger length = [textField.text length] + string.length;
    //
    //    if (length > 20)
    //    {
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"long_name", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"okay", nil) otherButtonTitles:nil];
    //
    //        [alertView show];
    //
    //        return NO;
    //    }
    return YES;     // NO를 리턴할 경우 변경내용이 반영되지 않는다
}

/// textField의 내용이 삭제될 때 실행
// clearButtonMode 속성값이 UITextFieldViewModeNever가 아닌 경우에만 실행
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;    // NO를 리턴할 경우 변경내용이 반영되지 않는다.
}

//- (void)doneClicked:(id)sender
//{
//    if ([_courseTextField isFirstResponder]) {
//        [_courseTextField resignFirstResponder];
//    } else if ([_classTextField isFirstResponder]) {
//        [_classTextField resignFirstResponder];
//    }
////    [self dismissModalViewControllerAnimated:YES];
//    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
//}

//- (void)ShowPicker:(UITextField *)textField
//{
//    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                               delegate:nil
//                                      cancelButtonTitle:nil
//                                 destructiveButtonTitle:nil
//                                      otherButtonTitles:nil];
//	
//    [_actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
//    
//	// Add the picker
//    CGRect pickerFrame = CGRectMake(0, 40, 320, 60);
//	_pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
//    _pickerView.dataSource = self;
//	_pickerView.delegate = self;
//	_pickerView.showsSelectionIndicator = YES;    // note this is default to NO
//    [_pickerView selectRow:0 inComponent:0 animated:YES];
//	[_pickerView reloadComponent:0];
//	
//	[_actionSheet addSubview:_pickerView];
//    
//    
//    // add done button
//    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"확인"]];
//    closeButton.momentary = YES;
//    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
//    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
//    closeButton.tintColor = [UIColor blackColor];
//    [closeButton addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventValueChanged];
//    
//    [_actionSheet addSubview:closeButton];
//    
//    
//    NSLog(@"actionSheet 뷰 위치 : %f", self.view.bounds.size.height);
//	[_actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
//	[_actionSheet setBounds:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//	
//}

#pragma mark - UIActionSheet delegates
// 프로필 사진 설정(사진 및 앨범) 메뉴
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == actionSheet.cancelButtonIndex) {
//        return;
//    }
//}

#pragma mark - UIPickerView DataSource

//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
//{
//    return 1;
//}

//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
//{
//    NSInteger count = 0;
//    if (_selectedTextTag == 300) {
//        count = [_courses count];
//    } else {
//        count = [_classes count];
//    }
//    return count;
//}

#pragma mark - UIPickerView Delegate

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    NSString *value = nil;
//    NSLog(@"%d", row);
//    
//    if (_selectedTextTag == 300) {
//        value = _courses[row][@"course"];
//    }
//    else {
//        value = _classes[row];
//    }
//
//    return value;
//}

//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
//{
//    NSLog(@"피커 선택 : %d / %d", row, component);
//    if (_selectedTextTag == 300) {
//        _courseTextField.text = _courses[row][@"course"];
////        _selectedText = _courseTextField.text;
//    }
//    else {
//        _classTextField.text = _courses[row];
////        _selectedText = _courseTextField.text;
//    }
//
//}

@end
