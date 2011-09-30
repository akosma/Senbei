//
//  SBActivitiesController.m
//  Senbei
//
//  Created by Adrian on 9/29/11.
//  Copyright (c) 2011, akosma software / Adrian Kosmaczewski
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

#import "SBActivitiesController.h"
#import "SBModels.h"
#import "SBHelpers.h"
#import "SBCommentsController.h"

@interface SBActivitiesController ()

@property (nonatomic, retain) NSArray *activities;

@end


@implementation SBActivitiesController

@synthesize activities = _activities;

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_activities release];
    [super dealloc];
}

#pragma mark - Public methods

- (void)refresh
{
    [[SBNetworkManager sharedSBNetworkManager] loadActivities];
}

#pragma mark - UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"ACTIVITIES_TITLE", @"Title of the activities controller");
    self.tableView.rowHeight = 70.0;
    
    UIBarButtonItem *reloadItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(refresh)] autorelease];
    self.navigationItem.rightBarButtonItem = reloadItem;
        
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didReceiveActivities:) 
                                                 name:SBNetworkManagerDidRetrieveActivitiesNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh) 
                                                 name:SBNetworkManagerDidPostCommentNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh) 
                                                 name:SBNetworkManagerDidDeleteCommentNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh) 
                                                 name:SBNetworkManagerDidCreateTaskNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh) 
                                                 name:SBNetworkManagerDidMarkTaskAsDoneNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh) 
                                                 name:SBNetworkManagerDidCreateContactNotification 
                                               object:nil];

    [self refresh];
}

#pragma mark - NSNotification handler methods

- (void)didReceiveActivities:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    self.activities = [userInfo objectForKey:@"data"];
    [self.tableView reloadData];
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self.activities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    SBActivity *activity = [self.activities objectAtIndex:indexPath.row];
    cell.textLabel.text = activity.info;
    NSString *date = [activity.createdAt stringFormattedWithCurrentLocale];
    NSString *info = [[NSString stringWithFormat:@"%@ %@", activity.action, activity.subjectType] capitalizedString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", info, date];
    
    if ([activity.action isEqualToString:@"deleted"] || [activity.subjectType isEqualToString:@"Task"])
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    SBActivity *activity = [self.activities objectAtIndex:indexPath.row];
    if (![activity.action isEqualToString:@"deleted"] && ![activity.subjectType isEqualToString:@"Task"])
    {
        NSString *subjectType = activity.subjectType;
        Class modelClass = [SBBaseEntity classForSubjectType:subjectType];
        SBBaseEntity *entity = [[[modelClass alloc] init] autorelease];
        entity.objectId = activity.subjectId;
        entity.name = @"";
        
        SBCommentsController *commentsController = [[[SBCommentsController alloc] init] autorelease];
        commentsController.entity = entity;
        [self.navigationController pushViewController:commentsController
                                             animated:YES];
    }
}

@end
