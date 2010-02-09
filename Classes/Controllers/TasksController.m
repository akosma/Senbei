//
//  TasksController.m
//  Senbei
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "TasksController.h"
#import "FatFreeCRMProxy.h"
#import "NewTaskController.h"
#import "Task.h"

@implementation TasksController

@synthesize navigationController = _navigationController;

#pragma mark -
#pragma mark Dealloc

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

#pragma mark -
#pragma mark Public methods

- (void)refresh
{
    [[FatFreeCRMProxy sharedFatFreeCRMProxy] loadTasks];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    _firstLoad = YES;
    _navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    self.title = NSLocalizedString(@"TASKS_CONTROLLER_TITLE", @"Title of the Tasks controller");
    
    UIBarButtonItem *reloadItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                target:self
                                                                                action:@selector(refresh)];
    self.navigationItem.leftBarButtonItem = reloadItem;
    [reloadItem release];
    
    UIBarButtonItem *addTaskItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                 target:self
                                                                                 action:@selector(addNewTask:)];
    self.navigationItem.rightBarButtonItem = addTaskItem;
    [addTaskItem release];

    _tasksOverdue = [[NSMutableArray alloc] initWithCapacity:10];
    _tasksDueASAP = [[NSMutableArray alloc] initWithCapacity:10];
    _tasksDueToday = [[NSMutableArray alloc] initWithCapacity:10];
    _tasksDueTomorrow = [[NSMutableArray alloc] initWithCapacity:10];
    _tasksDueThisWeek = [[NSMutableArray alloc] initWithCapacity:10];
    _tasksDueNextWeek = [[NSMutableArray alloc] initWithCapacity:10];
    _tasksDueLater = [[NSMutableArray alloc] initWithCapacity:10];
    
    _sections = [[NSMutableArray alloc] initWithCapacity:10];
    
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
    NSArray *categoriesArray = [[NSArray alloc] initWithContentsOfFile:path];
    _categories = [[NSMutableDictionary alloc] initWithCapacity:[categoriesArray count]];
    for (NSDictionary *dict in categoriesArray)
    {
        [_categories setObject:[dict objectForKey:@"text"] 
                        forKey:[dict objectForKey:@"key"]];
    }
    [categoriesArray release];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_firstLoad)
    {
        _firstLoad = NO;
        [self refresh];
    }
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Button handlers

- (void)addNewTask:(id)sender
{
    if (_newTaskController == nil)
    {
        _newTaskController = [[NewTaskController alloc] init];
    }
    [self.navigationController presentModalViewController:_newTaskController.navigationController
                                                 animated:YES];
}

#pragma mark -
#pragma mark NSNotification handler methods

- (void)didReceiveTasks:(NSNotification *)notification
{
    [_sections removeAllObjects];
    
    [_tasksOverdue removeAllObjects];
    [_tasksDueASAP removeAllObjects];
    [_tasksDueToday removeAllObjects];
    [_tasksDueTomorrow removeAllObjects];
    [_tasksDueThisWeek removeAllObjects];
    [_tasksDueNextWeek removeAllObjects];
    [_tasksDueLater removeAllObjects];
    
    NSDictionary *userInfo = [notification userInfo];
    [_tasksOverdue addObjectsFromArray:[userInfo objectForKey:TASKS_OVERDUE_KEY]];
    [_tasksDueASAP addObjectsFromArray:[userInfo objectForKey:TASKS_DUE_ASAP_KEY]];
    [_tasksDueToday addObjectsFromArray:[userInfo objectForKey:TASKS_DUE_TODAY_KEY]];
    [_tasksDueTomorrow addObjectsFromArray:[userInfo objectForKey:TASKS_DUE_TOMORROW_KEY]];
    [_tasksDueThisWeek addObjectsFromArray:[userInfo objectForKey:TASKS_DUE_THIS_WEEK_KEY]];
    [_tasksDueNextWeek addObjectsFromArray:[userInfo objectForKey:TASKS_DUE_NEXT_WEEK_KEY]];
    [_tasksDueLater addObjectsFromArray:[userInfo objectForKey:TASKS_DUE_LATER_KEY]];
    
    if ([_tasksOverdue count] > 0) [_sections addObject:_tasksOverdue];
    if ([_tasksDueASAP count] > 0) [_sections addObject:_tasksDueASAP];
    if ([_tasksDueToday count] > 0) [_sections addObject:_tasksDueToday];
    if ([_tasksDueTomorrow count] > 0) [_sections addObject:_tasksDueTomorrow];
    if ([_tasksDueThisWeek count] > 0) [_sections addObject:_tasksDueThisWeek];
    if ([_tasksDueNextWeek count] > 0) [_sections addObject:_tasksDueNextWeek];
    if ([_tasksDueLater count] > 0) [_sections addObject:_tasksDueLater];
    
    [self.tableView reloadData];
}

- (void)reloadTasks:(NSNotification *)notification
{
    [self refresh];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [[_sections objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return [task.name sizeWithFont:[UIFont boldSystemFontOfSize:14.0] 
                       constrainedToSize:CGSizeMake(170.0, 4000.0)].height + 20.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableArray *array = [_sections objectAtIndex:section];
    NSString *text = nil;
    NSString *tasksOverdueTitle = NSLocalizedString(@"TASKS_OVERDUE_TITLE", @"Title of the overdue tasks section");
    NSString *tasksDueASAPTitle = NSLocalizedString(@"TASKS_DUE_ASAP_TITLE", @"Title of the due asap tasks section");
    NSString *tasksDueTodayTitle = NSLocalizedString(@"TASKS_DUE_TODAY_TITLE", @"Title of the due today tasks section");
    NSString *tasksDueTomorrowTitle = NSLocalizedString(@"TASKS_DUE_TOMORROW_TITLE", @"Title of the due tomorrow tasks section");
    NSString *tasksDueThisWeekTitle = NSLocalizedString(@"TASKS_DUE_THIS_WEEK_TITLE", @"Title of the due this week tasks section");
    NSString *tasksDueNextWeekTitle = NSLocalizedString(@"TASKS_DUE_NEXT_WEEK_TITLE", @"Title of the due next week tasks section");
    NSString *tasksDueLaterTitle = NSLocalizedString(@"TASKS_DUE_LATER_TITLE", @"Title of the due later tasks section");
    if (array == _tasksOverdue) text = tasksOverdueTitle;
    if (array == _tasksDueASAP) text = tasksDueASAPTitle;
    if (array == _tasksDueToday) text = tasksDueTodayTitle;
    if (array == _tasksDueTomorrow) text = tasksDueTomorrowTitle;
    if (array == _tasksDueThisWeek) text = tasksDueThisWeekTitle;
    if (array == _tasksDueNextWeek) text = tasksDueNextWeekTitle;
    if (array == _tasksDueLater) text = tasksDueLaterTitle;
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
    
    Task *task = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = [_categories objectForKey:task.category];
    cell.detailTextLabel.text = task.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    _indexPathToDelete = [indexPath retain];
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

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSMutableArray *array = [_sections objectAtIndex:_indexPathToDelete.section];
        Task *task = [[array objectAtIndex:_indexPathToDelete.row] retain];
        [array removeObjectAtIndex:_indexPathToDelete.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_indexPathToDelete]
                              withRowAnimation:UITableViewRowAnimationFade];
        [[FatFreeCRMProxy sharedFatFreeCRMProxy] markTaskAsDone:task];
        [task release];
    }
    [_indexPathToDelete release];
}

@end
