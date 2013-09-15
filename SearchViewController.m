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
@property (strong, nonatomic) NSMutableArray *courses;
@property (strong, nonatomic) NSMutableArray *classes;
@property (retain, nonatomic) NSString *selectedText;
@property (assign, nonatomic) NSInteger selectedTextTag;

@property (strong, nonatomic) UITextField *courseTextField;
@property (strong, nonatomic) UITextField *classTextField;

@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIPickerView *coursePicker;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"검색";
        
        _courses = [[NSMutableArray alloc] init];
        _classes = [[NSMutableArray alloc] init];
        _selectedTextTag = 0;

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
    [_courses setArray:[self loadDBCourses]];
    
    // 기수 목록 db에서 읽어오기
    
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
    CGFloat yOffset = 10.0f;
    CGFloat xOffset = 60.0f;
    
    if (!IS_LESS_THEN_IOS7) {
        yOffset += 44.0f;
    }
    
    // 검색 조건 배경 뷰
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, yOffset, 300.0f, 200.0f)];
    bgView.backgroundColor = UIColorFromRGB(0xFFEBD8);
    
    [self.view addSubview:bgView];
    
    
    // 과정 선택
//    UIImage *inputBoxBg = [UIImage imageNamed:@"input_text_border"];
    _courseTextField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, yOffset, 200.0f, 30.0f)];
    _courseTextField.tag = 300;
    _courseTextField.background = [[UIImage imageNamed:@"input_text_border"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    _courseTextField.delegate = self;
    _courseTextField.placeholder = LocalizedString(@"과정을 선택하세요", @"과정을 선택하세요");
//    _courseTextField.text = @;
    [_courseTextField setTextColor:[UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f]];
    [_courseTextField setTextAlignment:NSTextAlignmentCenter];
//    [_courseTextField setReturnKeyType:UIReturnKeyNext];
//    [_courseTextField setKeyboardType:UIKeyboardTypeDefault];
//    [_courseTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//    _courseTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _courseTextField.font = [UIFont systemFontOfSize:16.0f];
    
    [bgView addSubview:_courseTextField];
    
    

    
    
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
    
    // 이름
    
    // 옵션 버튼
    
    // 검색 버튼
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setFrame:CGRectMake((rect.size.width - 100.0f) / 2.0f, yOffset + bgView.frame.size.height + 10.0f, 100.0f, 30.0f)];
    [searchBtn setBackgroundImage:[[UIImage imageNamed:@"btn_white"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f] forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [searchBtn setTitle:@"검색" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(onSearchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:searchBtn];
}


//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"Touched!");
//}


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
    
    for (NSDictionary *info in fetchedObjects) {
        NSLog(@"title : %@", info);
    }
    
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
    
    //    NSAttributeDescription *type = [entity.attributesByName objectForKey:@"course"];
    //    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:type, nil]];
    //    [fetchRequest setResultType:NSDictionaryResultType];
    
    // where
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(course == %@)", courseName];
    [fetchRequest setPredicate:predicate];
    
    // order by (ZCOURSECLASS)
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    for (Course *class in fetchedObjects) {
        NSLog(@"title : %@", class.title);
    }
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
        return fetchedObjects;
    }
    return nil;
}

#pragma mark - UI Control Events

// 검색 버튼
- (void)onSearchBtnClicked:(id)sender
{
    SearchResultViewController *viewController = [[SearchResultViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _selectedTextTag = textField.tag;
    NSLog(@"선택된 컨트롤 tag : %d", _selectedTextTag);
    
    [self ShowPicker:textField];
    
    return YES;
}

- (void)doneClicked:(id)sender
{
    if ([_courseTextField isFirstResponder]) {
        [_courseTextField resignFirstResponder];
    } else if ([_classTextField isFirstResponder]) {
        [_classTextField resignFirstResponder];
    }
//    [self dismissModalViewControllerAnimated:YES];
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)ShowPicker:(UITextField *)textField
{
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                               delegate:nil
                                      cancelButtonTitle:nil
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:nil];
	
    [_actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
	// Add the picker
    CGRect pickerFrame = CGRectMake(0, 40, 320, 60);
	UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.dataSource = self;
	pickerView.delegate = self;
	pickerView.showsSelectionIndicator = YES;    // note this is default to NO
//    [pickerView selectRow:0 inComponent:0 animated:YES];
//	[pickerView reloadComponent:0];
	
	[_actionSheet addSubview:pickerView];
    
    
    // add done button
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"확인"]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventValueChanged];
    
    [_actionSheet addSubview:closeButton];
    
    
    NSLog(@"actionSheet 뷰 위치 : %f", self.view.bounds.size.height);
	[_actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
	[_actionSheet setBounds:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
	
}

#pragma mark - UIActionSheet delegates
// 프로필 사진 설정(사진 및 앨범) 메뉴
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
}

#pragma mark - UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger count = 0;
    if (_selectedTextTag == 300) {
        count = [_courses count];
    } else {
        count = [_classes count];
    }
    return count;
}

#pragma mark - UIPickerView Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *value = nil;
    NSLog(@"%d", row);
    
    if (_selectedTextTag == 300) {
        value = _courses[row][@"course"];
    }
    else {
        value = _classes[row];
    }

    return value;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"피커 선택 : %d / %d", row, component);
    if (_selectedTextTag == 300) {
        _courseTextField.text = _courses[row][@"course"];
//        _selectedText = _courseTextField.text;
    }
    else {
        _classTextField.text = _courses[row];
//        _selectedText = _courseTextField.text;
    }

}

@end
