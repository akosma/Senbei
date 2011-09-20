//
//  SBNewTaskController.m
//  Senbei
//
//  Created by Adrian on 1/30/10.
//  Copyright (c) 2010, akosma software / Adrian Kosmaczewski
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. All advertising materials mentioning features or use of this software
//  must display the following acknowledgement:
//  This product includes software developed by akosma software.
//  4. Neither the name of the akosma software nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ADRIAN KOSMACZEWSKI ''AS IS'' AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL ADRIAN KOSMACZEWSKI BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SBNewTaskController.h"
#import "SBModels.h"
#import "SBHelpers.h"

@interface SBNewTaskController ()

@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *bucketField;
@property (nonatomic, retain) UITextField *categoryField;
@property (nonatomic, retain) UIBarButtonItem *doneButtonItem;
@property (nonatomic, copy) NSString *selectedBucket;
@property (nonatomic, retain) UIPickerView *bucketPicker;
@property (nonatomic, retain) NSArray *buckets;
@property (nonatomic, copy) NSString *selectedCategory;
@property (nonatomic, retain) UIPickerView *categoryPicker;
@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, retain) UIDatePicker *datePicker;

@end


@implementation SBNewTaskController

@synthesize navigationController = _navigationController;
@synthesize nameField = _nameField;
@synthesize bucketField = _bucketField;
@synthesize categoryField = _categoryField;
@synthesize doneButtonItem = _doneButtonItem;
@synthesize selectedBucket = _selectedBucket;
@synthesize bucketPicker = _bucketPicker;
@synthesize buckets = _buckets;
@synthesize selectedCategory = _selectedCategory;
@synthesize categoryPicker = _categoryPicker;
@synthesize categories = _categories;
@synthesize selectedDate = _selectedDate;
@synthesize datePicker = _datePicker;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) 
    {
        self.navigationController = [[[UINavigationController alloc] initWithRootViewController:self] autorelease];
        NSString *controllerTitle = NSLocalizedString(@"NEW_TASK_TITLE", @"Title of the new task screen");
        self.title = controllerTitle;

        self.doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(done:)] autorelease];
        self.navigationItem.rightBarButtonItem = self.doneButtonItem;

        UIBarButtonItem *cancelItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(close:)] autorelease];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(close:) 
                                                     name:FatFreeCRMProxyDidCreateTaskNotification
                                                   object:[SBNetworkManager sharedSBNetworkManager]];
        
        self.nameField = [[[UITextField alloc] initWithFrame:CGRectMake(90.0, 12.0, 200.0, 20.0)] autorelease];
        self.nameField.delegate = self;
        
        self.bucketField = [[[UITextField alloc] initWithFrame:CGRectMake(90.0, 12.0, 200.0, 20.0)] autorelease];
        self.bucketField.delegate = self;
        
        self.categoryField = [[[UITextField alloc] initWithFrame:CGRectMake(90.0, 12.0, 200.0, 20.0)] autorelease];
        self.categoryField.delegate = self;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"TaskCategories" ofType:@"plist"];
        self.categories = [NSArray arrayWithContentsOfFile:path];
        self.selectedCategory = [[self.categories objectAtIndex:0] objectForKey:@"key"];
        
        path = [[NSBundle mainBundle] pathForResource:@"TaskBuckets" ofType:@"plist"];
        self.buckets = [NSArray arrayWithContentsOfFile:path];
        self.selectedBucket = [[self.buckets objectAtIndex:0] objectForKey:@"key"];
    }
    return self;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_navigationController release];
    [_doneButtonItem release];
    [_nameField release];
    [_bucketField release];
    [_categoryField release];
    [_selectedDate release];
    [_selectedBucket release];
    [_selectedCategory release];
    [_categories release];
    [_buckets release];
    [_datePicker release];
    [_bucketPicker release];
    [_categoryPicker release];
    [super dealloc];
}

#pragma mark - Event handlers

- (void)done:(id)sender
{
    if ([self.nameField.text length] > 0)
    {
        self.doneButtonItem.enabled = NO;
        SBTask *task = [[SBTask alloc] init];
        task.name = self.nameField.text;
        task.category = self.selectedCategory;
        task.bucket = self.selectedBucket;
        task.dueDate = self.selectedDate;
        [[SBNetworkManager sharedSBNetworkManager] createTask:task];
        [task release];
    }
    else
    {
        NSString *message = NSLocalizedString(@"NEW_TASK_SPECIFY_NAME", @"Text shown when trying to create a task without name");
        NSString *ok = NSLocalizedString(@"OK", @"The 'OK' word");
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:ok
                                               otherButtonTitles:nil] autorelease];
        [alert show];
        [self.nameField becomeFirstResponder];
    }
}

- (void)close:(id)sender
{
    self.doneButtonItem.enabled = NO;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dateSelected:(id)sender
{
    self.selectedDate = [self.datePicker date];
    self.bucketField.text = [self.selectedDate stringWithDateFormattedWithCurrentLocale];
}

#pragma mark - UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    self.nameField.text = @"";
    self.doneButtonItem.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.nameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"NewTaskCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *name = NSLocalizedString(@"NEW_TASK_NAME_FIELD", @"Title of the 'name' form field");
    NSString *due = NSLocalizedString(@"NEW_TASK_DUE_FIELD", @"Title of the 'due' form field");
    NSString *category = NSLocalizedString(@"NEW_TASK_CATEGORY_FIELD", @"Title of the 'category' form field");
    
    switch (indexPath.row) 
    {
        case 0:
            cell.textLabel.text = name;
            self.nameField.text = @"";
            [cell.contentView addSubview:self.nameField];
            break;

        case 1:
            cell.textLabel.text = due;
            self.bucketField.text = [[self.buckets objectAtIndex:0] objectForKey:@"text"];
            [cell.contentView addSubview:self.bucketField];
            break;
            
        case 2:
            cell.textLabel.text = category;
            self.categoryField.text = [[self.categories objectAtIndex:0] objectForKey:@"text"];
            [cell.contentView addSubview:self.categoryField];

        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    switch (indexPath.row) 
    {
        case 0:
            [self.nameField becomeFirstResponder];
            break;
            
        case 1:
            [self.bucketField becomeFirstResponder];
            break;
            
        case 2:
            [self.categoryField becomeFirstResponder];
            break;

        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.nameField)
    {
        return YES;
    }

    [self.nameField resignFirstResponder];

    if (textField == self.categoryField)
    {
        if (self.categoryPicker == nil)
        {
            self.categoryPicker = [[[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 264.0, 320.0, 216.0)] autorelease];
            self.categoryPicker.delegate = self;
            self.categoryPicker.showsSelectionIndicator = YES;
            [self.categoryPicker selectRow:0 inComponent:0 animated:NO];
            [self.navigationController.view addSubview:self.categoryPicker];
        }
        [self.navigationController.view bringSubviewToFront:self.categoryPicker];
    }
    else if (textField == self.bucketField)
    {
        if (self.bucketPicker == nil)
        {
            self.bucketPicker = [[[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 264.0, 320.0, 216.0)] autorelease];
            self.bucketPicker.delegate = self;
            self.bucketPicker.showsSelectionIndicator = YES;
            [self.bucketPicker selectRow:0 inComponent:0 animated:NO];
            [self.navigationController.view addSubview:self.bucketPicker];
        }
        [self.navigationController.view bringSubviewToFront:self.bucketPicker];
    }
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == self.categoryPicker)
    {
        return 1;
    }
    if (pickerView == self.bucketPicker)
    {
        return 1;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.categoryPicker)
    {
        return [self.categories count];
    }
    if (pickerView == self.bucketPicker)
    {
        return [self.buckets count];
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.categoryPicker)
    {
        return [[self.categories objectAtIndex:row] objectForKey:@"text"];
    }
    if (pickerView == self.bucketPicker)
    {
        return [[self.buckets objectAtIndex:row] objectForKey:@"text"];
    }
    return 0;    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.categoryPicker)
    {
        self.selectedCategory = [[self.categories objectAtIndex:row] objectForKey:@"key"];
        self.categoryField.text = [[self.categories objectAtIndex:row] objectForKey:@"text"];
    }
    else if (pickerView == self.bucketPicker)
    {
        self.selectedBucket = [[self.buckets objectAtIndex:row] objectForKey:@"key"];
        self.bucketField.text = [[self.buckets objectAtIndex:row] objectForKey:@"text"];
        
        if ([self.selectedBucket isEqualToString:@"specific_time"])
        {
            if (self.datePicker == nil)
            {
                self.datePicker = [[[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 264.0, 320.0, 216.0)] autorelease];
                self.datePicker.datePickerMode = UIDatePickerModeDate;
                [self.datePicker addTarget:self 
                                action:@selector(dateSelected:) 
                      forControlEvents:UIControlEventValueChanged];
                [self.navigationController.view addSubview:self.datePicker];
            }
            self.selectedDate = [self.datePicker date];
            self.bucketField.text = [self.selectedDate stringWithDateFormattedWithCurrentLocale];
            [self.navigationController.view bringSubviewToFront:self.datePicker];
        }
    }
}

@end
