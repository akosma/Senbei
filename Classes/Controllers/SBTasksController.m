//
//  SBTasksController.m
//  Senbei
//
//  Created by Adrian on 1/20/10.
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

#import "SBTasksController.h"
#import "SBModels.h"
#import "SBHelpers.h"
#import "SBNewTaskController.h"

@interface SBTasksController ()

@property (nonatomic, retain) NSMutableArray *tasksOverdue;
@property (nonatomic, retain) NSMutableArray *tasksDueASAP;
@property (nonatomic, retain) NSMutableArray *tasksDueToday;
@property (nonatomic, retain) NSMutableArray *tasksDueTomorrow;
@property (nonatomic, retain) NSMutableArray *tasksDueThisWeek;
@property (nonatomic, retain) NSMutableArray *tasksDueNextWeek;
@property (nonatomic, retain) NSMutableArray *tasksDueLater;
@property (nonatomic, retain) NSMutableArray *sections;
@property (nonatomic, retain) NSMutableDictionary *categories;
@property (nonatomic, retain) NSIndexPath *indexPathToDelete;
@property (nonatomic, retain) SBNewTaskController *newTaskController;
@property (nonatomic, getter = isFirstLoad) BOOL firstLoad;

@end


@implementation SBTasksController

@synthesize navigationController = _navigationController;
@synthesize tasksOverdue = _tasksOverdue;
@synthesize tasksDueASAP = _tasksDueASAP;
@synthesize tasksDueToday = _tasksDueToday;
@synthesize tasksDueTomorrow = _tasksDueTomorrow;
@synthesize tasksDueThisWeek = _tasksDueThisWeek;
@synthesize tasksDueNextWeek = _tasksDueNextWeek;
@synthesize tasksDueLater = _tasksDueLater;
@synthesize sections = _sections;
@synthesize categories = _categories;
@synthesize indexPathToDelete = _indexPathToDelete;
@synthesize newTaskController = _newTaskController;
@synthesize firstLoad = _firstLoad;

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tasksOverdue release];
    [_tasksDueASAP release];
    [_tasksDueToday release];
    [_tasksDueTomorrow release];
    [_tasksDueThisWeek release];
    [_tasksDueNextWeek release];
    [_tasksDueLater release];
    [_sections release];
    [_navigationController release];
    [_newTaskController release];
    [_categories release];
    [super dealloc];
}

#pragma mark - Public methods

- (void)refresh
{
    [[FatFreeCRMProxy sharedFatFreeCRMProxy] loadTasks];
}

#pragma mark - UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.firstLoad = YES;
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:self] autorelease];
    self.title = NSLocalizedString(@"TASKS_CONTROLLER_TITLE", @"Title of the Tasks controller");
    
    UIBarButtonItem *reloadItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(refresh)] autorelease];
    self.navigationItem.leftBarButtonItem = reloadItem;
    
    UIBarButtonItem *addTaskItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(addNewTask:)] autorelease];
    self.navigationItem.rightBarButtonItem = addTaskItem;

    self.tasksOverdue = [NSMutableArray arrayWithCapacity:10];
    self.tasksDueASAP = [NSMutableArray arrayWithCapacity:10];
    self.tasksDueToday = [NSMutableArray arrayWithCapacity:10];
    self.tasksDueTomorrow = [NSMutableArray arrayWithCapacity:10];
    self.tasksDueThisWeek = [NSMutableArray arrayWithCapacity:10];
    self.tasksDueNextWeek = [NSMutableArray arrayWithCapacity:10];
    self.tasksDueLater = [NSMutableArray arrayWithCapacity:10];
    
    self.sections = [NSMutableArray arrayWithCapacity:10];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didReceiveTasks:) 
                                                 name:FatFreeCRMProxyDidRetrieveTasksNotification 
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTasks:) 
                                                 name:FatFreeCRMProxyDidMarkTaskAsDoneNotification 
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTasks:) 
                                                 name:FatFreeCRMProxyDidCreateTaskNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TaskCategories" ofType:@"plist"];
    NSArray *categoriesArray = [NSArray arrayWithContentsOfFile:path];
    self.categories = [NSMutableDictionary dictionaryWithCapacity:[categoriesArray count]];
    for (NSDictionary *dict in categoriesArray)
    {
        [self.categories setObject:[dict objectForKey:@"text"] 
                            forKey:[dict objectForKey:@"key"]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.isFirstLoad)
    {
        self.firstLoad = NO;
        [self refresh];
    }
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button handlers

- (void)addNewTask:(id)sender
{
    if (self.newTaskController == nil)
    {
        self.newTaskController = [[[SBNewTaskController alloc] init] autorelease];
    }
    [self.navigationController presentModalViewController:self.newTaskController.navigationController
                                                 animated:YES];
}

#pragma mark - NSNotification handler methods

- (void)didReceiveTasks:(NSNotification *)notification
{
    [self.sections removeAllObjects];
    
    [self.tasksOverdue removeAllObjects];
    [self.tasksDueASAP removeAllObjects];
    [self.tasksDueToday removeAllObjects];
    [self.tasksDueTomorrow removeAllObjects];
    [self.tasksDueThisWeek removeAllObjects];
    [self.tasksDueNextWeek removeAllObjects];
    [self.tasksDueLater removeAllObjects];
    
    NSDictionary *userInfo = [notification userInfo];
    [self.tasksOverdue addObjectsFromArray:[userInfo objectForKey:TASKS_OVERDUE_KEY]];
    [self.tasksDueASAP addObjectsFromArray:[userInfo objectForKey:TASKS_DUE_ASAP_KEY]];
    [self.tasksDueToday addObjectsFromArray:[userInfo objectForKey:TASKS_DUE_TODAY_KEY]];
    [self.tasksDueTomorrow addObjectsFromArray:[userInfo objectForKey:TASKS_DUE_TOMORROW_KEY]];
    [self.tasksDueThisWeek addObjectsFromArray:[userInfo objectForKey:TASKS_DUE_THIS_WEEK_KEY]];
    [self.tasksDueNextWeek addObjectsFromArray:[userInfo objectForKey:TASKS_DUE_NEXT_WEEK_KEY]];
    [self.tasksDueLater addObjectsFromArray:[userInfo objectForKey:TASKS_DUE_LATER_KEY]];
    
    if ([self.tasksOverdue count] > 0) [self.sections addObject:self.tasksOverdue];
    if ([self.tasksDueASAP count] > 0) [self.sections addObject:self.tasksDueASAP];
    if ([self.tasksDueToday count] > 0) [self.sections addObject:self.tasksDueToday];
    if ([self.tasksDueTomorrow count] > 0) [self.sections addObject:self.tasksDueTomorrow];
    if ([self.tasksDueThisWeek count] > 0) [self.sections addObject:self.tasksDueThisWeek];
    if ([self.tasksDueNextWeek count] > 0) [self.sections addObject:self.tasksDueNextWeek];
    if ([self.tasksDueLater count] > 0) [self.sections addObject:self.tasksDueLater];
    
    [self.tableView reloadData];
}

- (void)reloadTasks:(NSNotification *)notification
{
    [self refresh];
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [[self.sections objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBTask *task = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return [task.name sizeWithFont:[UIFont boldSystemFontOfSize:14.0] 
                       constrainedToSize:CGSizeMake(170.0, 4000.0)].height + 20.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableArray *array = [self.sections objectAtIndex:section];
    NSString *text = nil;
    NSString *tasksOverdueTitle = NSLocalizedString(@"TASKS_OVERDUE_TITLE", @"Title of the overdue tasks section");
    NSString *tasksDueASAPTitle = NSLocalizedString(@"TASKS_DUE_ASAP_TITLE", @"Title of the due asap tasks section");
    NSString *tasksDueTodayTitle = NSLocalizedString(@"TASKS_DUE_TODAY_TITLE", @"Title of the due today tasks section");
    NSString *tasksDueTomorrowTitle = NSLocalizedString(@"TASKS_DUE_TOMORROW_TITLE", @"Title of the due tomorrow tasks section");
    NSString *tasksDueThisWeekTitle = NSLocalizedString(@"TASKS_DUE_THIS_WEEK_TITLE", @"Title of the due this week tasks section");
    NSString *tasksDueNextWeekTitle = NSLocalizedString(@"TASKS_DUE_NEXT_WEEK_TITLE", @"Title of the due next week tasks section");
    NSString *tasksDueLaterTitle = NSLocalizedString(@"TASKS_DUE_LATER_TITLE", @"Title of the due later tasks section");
    if (array == self.tasksOverdue) text = tasksOverdueTitle;
    if (array == self.tasksDueASAP) text = tasksDueASAPTitle;
    if (array == self.tasksDueToday) text = tasksDueTodayTitle;
    if (array == self.tasksDueTomorrow) text = tasksDueTomorrowTitle;
    if (array == self.tasksDueThisWeek) text = tasksDueThisWeekTitle;
    if (array == self.tasksDueNextWeek) text = tasksDueNextWeekTitle;
    if (array == self.tasksDueLater) text = tasksDueLaterTitle;
    return text;    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    SBTask *task = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = [self.categories objectForKey:task.category];
    cell.detailTextLabel.text = task.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    self.indexPathToDelete = [indexPath retain];
    NSString *message = NSLocalizedString(@"MARK_TASKS_DONE", @"Confirmation text shown before setting a task as done");
    NSString *ok = NSLocalizedString(@"OK", @"The 'OK' word");
    NSString *cancel = NSLocalizedString(@"CANCEL", @"The 'Cancel' word");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancel
                                          otherButtonTitles:ok, nil];
    [alert show];
    [alert release];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSMutableArray *array = [self.sections objectAtIndex:self.indexPathToDelete.section];
        SBTask *task = [[array objectAtIndex:self.indexPathToDelete.row] retain];
        [array removeObjectAtIndex:self.indexPathToDelete.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathToDelete]
                              withRowAnimation:UITableViewRowAnimationFade];
        [[FatFreeCRMProxy sharedFatFreeCRMProxy] markTaskAsDone:task];
        [task release];
    }
    self.indexPathToDelete = nil;
}

@end
