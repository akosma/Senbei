//
//  TasksController.m
//  Saccharin
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

- (void)viewDidLoad 
{
    [super viewDidLoad];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    self.title = @"Tasks";
    
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
    
    [[FatFreeCRMProxy sharedFatFreeCRMProxy] loadTasks];
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
    [_tasksOverdue addObjectsFromArray:[userInfo objectForKey:@"tasksOverdue"]];
    [_tasksDueASAP addObjectsFromArray:[userInfo objectForKey:@"tasksDueASAP"]];
    [_tasksDueToday addObjectsFromArray:[userInfo objectForKey:@"tasksDueToday"]];
    [_tasksDueTomorrow addObjectsFromArray:[userInfo objectForKey:@"tasksDueTomorrow"]];
    [_tasksDueThisWeek addObjectsFromArray:[userInfo objectForKey:@"tasksDueThisWeek"]];
    [_tasksDueNextWeek addObjectsFromArray:[userInfo objectForKey:@"tasksDueNextWeek"]];
    [_tasksDueLater addObjectsFromArray:[userInfo objectForKey:@"tasksDueLater"]];
    
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
    [[FatFreeCRMProxy sharedFatFreeCRMProxy] loadTasks];
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
    if (array == _tasksOverdue) text = @"Overdue";
    if (array == _tasksDueASAP) text = @"Due as soon as possible";
    if (array == _tasksDueToday) text = @"Due today";
    if (array == _tasksDueTomorrow) text = @"Due tomorrow";
    if (array == _tasksDueThisWeek) text = @"Due this week";
    if (array == _tasksDueNextWeek) text = @"Due next week";
    if (array == _tasksDueLater) text = @"Due later";
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                    message:@"Do you want to mark this task as done?" 
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel" 
                                          otherButtonTitles:@"OK", nil];
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
