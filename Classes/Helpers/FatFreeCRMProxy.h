//
//  FatFreeCRMProxy.h
//  Senbei
//
//  Created by Adrian on 1/19/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FatFreeCRMProxyDidFailWithErrorNotification         @"FatFreeCRMProxyDidFailWithErrorNotification"
#define FatFreeCRMProxyDidRetrieveTasksNotification         @"FatFreeCRMProxyDidRetrieveTasksNotification"
#define FatFreeCRMProxyDidMarkTaskAsDoneNotification        @"FatFreeCRMProxyDidMarkTaskAsDoneNotification"
#define FatFreeCRMProxyDidCreateTaskNotification            @"FatFreeCRMProxyDidCreateTaskNotification"
#define FatFreeCRMProxyDidRetrieveAccountsNotification      @"FatFreeCRMProxyDidRetrieveAccountsNotification"
#define FatFreeCRMProxyDidRetrieveOpportunitiesNotification @"FatFreeCRMProxyDidRetrieveOpportunitiesNotification"
#define FatFreeCRMProxyDidRetrieveCampaignsNotification     @"FatFreeCRMProxyDidRetrieveCampaignsNotification"
#define FatFreeCRMProxyDidRetrieveLeadsNotification         @"FatFreeCRMProxyDidRetrieveLeadsNotification"
#define FatFreeCRMProxyDidRetrieveContactsNotification      @"FatFreeCRMProxyDidRetrieveContactsNotification"
#define FatFreeCRMProxyDidRetrieveCommentsNotification      @"FatFreeCRMProxyDidRetrieveCommentsNotification"
#define FatFreeCRMProxyDidPostCommentNotification           @"FatFreeCRMProxyDidPostCommentNotification"
#define FatFreeCRMProxyDidLoginNotification                 @"FatFreeCRMProxyDidLoginNotification"
#define FatFreeCRMProxyDidFailLoginNotification             @"FatFreeCRMProxyDidFailLoginNotification"

#define FatFreeCRMProxyErrorKey @"FatFreeCRMProxyErrorKey"
#define TASKS_OVERDUE_KEY       @"tasksOverdue"
#define TASKS_DUE_ASAP_KEY      @"tasksDueASAP"
#define TASKS_DUE_TODAY_KEY     @"tasksDueToday"
#define TASKS_DUE_TOMORROW_KEY  @"tasksDueTomorrow"
#define TASKS_DUE_THIS_WEEK_KEY @"tasksDueThisWeek"
#define TASKS_DUE_NEXT_WEEK_KEY @"tasksDueNextWeek"
#define TASKS_DUE_LATER_KEY     @"tasksDueLater"

@class ASINetworkQueue;
@class BaseEntity;
@class Task;

@interface FatFreeCRMProxy : NSObject
{
@private
    ASINetworkQueue *_networkQueue;
    NSNotificationCenter *_notificationCenter;
}

+ (FatFreeCRMProxy *)sharedFatFreeCRMProxy;

- (void)login;
- (void)loadList:(Class)klass page:(NSInteger)page;
- (void)searchList:(Class)klass query:(NSString *)search;
- (void)loadCommentsForEntity:(BaseEntity *)entity;
- (void)sendComment:(NSString *)comment forEntity:(BaseEntity *)entity;
- (void)markTaskAsDone:(Task *)task;
- (void)createTask:(Task *)task;
- (void)loadTasks;
- (void)cancelConnections;

@end
