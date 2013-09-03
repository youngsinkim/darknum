//
//  StudentAddressViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "StudentAddressViewController.h"
#import "AppDelegate.h"
#import "StudentCell.h"
#import "Course.h"
#import "Student.h"

@interface StudentAddressViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *studentTableView;    //< 학생 테이블
@property (strong, nonatomic) NSMutableArray *students;         //< 기수 학생 목록
@property (strong, nonatomic) NSDictionary *info;               //< db 조회를 위해 넘겨받은 해당 기수 정보

@end

@implementation StudentAddressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self)
    {
        _students = [[NSMutableArray alloc] init];
        
        _info = [NSDictionary dictionaryWithDictionary:info];
        
        self.navigationItem.title = _info[@"title"];
        NSLog(@"학생 정보 : %@", _info);
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
    
    // 기수 학생목록 화면 구성
    [self setupStudentAddressUI];
    
    // 학생 목록 DB에서 가져오기
    [_students setArray:[self loadDBFilteredStudents]];

    [_studentTableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 해당 기수별 학생 목록 화면
- (void)setupStudentAddressUI
{
    // 학생 테이블 뷰
    _studentTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
//    _studentTableView = [UIColor greenColor];
    _studentTableView.dataSource = self;
    _studentTableView.delegate = self;
    
    [self.view addSubview:_studentTableView];

}

#pragma mark - DB methods

/// 동일 기수의 학생 목록 DB에서 가져오기.
- (NSArray *)loadDBFilteredStudents
{
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSLog(@"찾을 기수 : %@", _info[@"courseclass"]);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"courseclass == %@", _info[@"courseclass"]];
    [fetchRequest setPredicate:predicate];
    
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"courseclass" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"DB data count : %d", [fetchedObjects count]);
    
    if (fetchedObjects && [fetchedObjects count] > 0)
    {
//        for (Course *info in fetchedObjects) {
//            NSLog(@"Name: %@", info.courseclass);
//            Student * = info.students;
//            NSLog(@"Zip: %@", details.zip);
//        }
        
//        Course *class = fetchedObjects[0];
//        if (class) {
//            NSMutableArray *classStudents = [[class.students allObjects] mutableCopy];
//            NSLog(@"student count : %d, %d", [class.students count], [classStudents count]);
//
//            return classStudents;
//        }
//        return fetchedObjects;
    }
    return nil;
}


#pragma mark - UITableView DataSources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([_students count] > 0)? [_students count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([_students count] > 0)? kStudentCellH : self.view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_students count] == 0)
    {
        static NSString *identifier = @"NoStudentCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"StudentCell";
    StudentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[StudentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        //        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    if ([_students count] > 0)
    {
//#if (1)
//        NSDictionary *majorInfo = _majors[indexPath.row];
//        
//        //        cell.titleLabel.text = major.title;
//        //        [cell setMemType:[course.type integerValue] WidhCount:[course.count integerValue]];
//        cell.textLabel.text = majorInfo[@"title"];
//#else
//        // db에서 가져오면 managedObject로 받음
//        Major *major = _majors[indexPath.row];
//        NSLog(@"major (%d) : %@, %@", indexPath.row, major.title, major);
//        cell.textLabel.text = major.title;
//#endif
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"선택한 셀 => (%i / %i)", indexPath.row, indexPath.section);
    
    NSDictionary *majorInfo = [_students[indexPath.row] mutableCopy];
    if ([majorInfo isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"선택된 셀 정보 : %@", majorInfo);
        
        // 전공에 해당하는 교수 목록 화면으로, (type = faculty, dict = 전공 정보)
        
        //        FacultyAddressViewController *facultyAddressVC = [[FacultyAddressViewController alloc] init];
//        AddressViewController *addressVC = [[AddressViewController alloc] initWithType:MemberTypeFaculty info:majorInfo];
//        [self.navigationController pushViewController:addressVC animated:YES];
    }
}

@end
