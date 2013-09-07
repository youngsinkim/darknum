//
//  FacultyAddressViewController.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 1..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "FacultyAddressViewController.h"
#import "DetailViewController.h"
#import "AddressCell.h"
#import "Faculty.h"

@interface FacultyAddressViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *facultyTableView;    //< 주소록 테이블 뷰
@property (strong, nonatomic) NSMutableArray *faculties;        //< 주소록 목록
@property (strong, nonatomic) NSDictionary *majorInfo;          //< 셀 구성을 위한 정보

@end

@implementation FacultyAddressViewController

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
    if (self) {
        
        self.navigationItem.title = LocalizedString(@"faculty_text", @"교수진");

        _majorInfo = [NSDictionary dictionaryWithDictionary:info];
        NSLog(@"교수의 전공 정보 : %@", _majorInfo);

        _faculties = [[NSMutableArray alloc] init];        
        
        }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
