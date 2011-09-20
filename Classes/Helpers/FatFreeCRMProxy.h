//
//  FatFreeCRMProxy.h
//  Senbei
//
//  Created by Adrian on 1/19/10.
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
@class SettingsManager;

@interface FatFreeCRMProxy : NSObject
{
@private
    ASINetworkQueue *_networkQueue;
    NSNotificationCenter *_notificationCenter;
    NSString *_server;
    NSString *_username;
    NSString *_password;
}

@property (nonatomic, copy) NSString *server;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

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
