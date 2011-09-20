//
//  SBTasksRequest.m
//  Senbei
//
//  Created by Adrian on 9/20/2011.
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

#import "SBTasksRequest.h"
#import "SBSettingsManager.h"
#import "SBExternals.h"
#import "SBNotifications.h"

static NSString *TASKS_REQUEST = @"tasks";

@implementation SBTasksRequest

+ (id)request
{
    NSString *server = [SBSettingsManager sharedSBSettingsManager].server;
    NSString *path = TASKS_REQUEST;
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", server, path];
    NSURL *url = [NSURL URLWithString:urlString];
    id request = [self requestWithURL:url];
    return request;
}

- (void)processResponse
{
    NSData *response = [self responseData];
    TBXML *tbxml = [TBXML tbxmlWithXMLData:response];
    TBXMLElement *hash = tbxml.rootXMLElement;
    Class klass = NSClassFromString(@"SBTask");
    
    NSArray *tasksOverdue = [self deserializeXMLElement:[TBXML childElementNamed:@"overdue" parentElement:hash] 
                                               forXPath:@"overdue" 
                                               andClass:klass];
    NSArray *tasksDueASAP = [self deserializeXMLElement:[TBXML childElementNamed:@"due-asap" parentElement:hash] 
                                               forXPath:@"due-asap" 
                                               andClass:klass];
    NSArray *tasksDueToday = [self deserializeXMLElement:[TBXML childElementNamed:@"due-today" parentElement:hash] 
                                                forXPath:@"due-today" 
                                                andClass:klass];
    NSArray *tasksDueTomorrow = [self deserializeXMLElement:[TBXML childElementNamed:@"due-tomorrow" parentElement:hash] 
                                                   forXPath:@"due-tomorrow" 
                                                   andClass:klass];
    NSArray *tasksDueThisWeek = [self deserializeXMLElement:[TBXML childElementNamed:@"due-this-week" parentElement:hash] 
                                                   forXPath:@"due-this-week" 
                                                   andClass:klass];
    NSArray *tasksDueNextWeek = [self deserializeXMLElement:[TBXML childElementNamed:@"due-next-week" parentElement:hash] 
                                                   forXPath:@"due-next-week" 
                                                   andClass:klass];
    NSArray *tasksDueLater = [self deserializeXMLElement:[TBXML childElementNamed:@"due-later" parentElement:hash] 
                                                forXPath:@"due-later" 
                                                andClass:klass];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:tasksOverdue, TASKS_OVERDUE_KEY,
                          tasksDueASAP, TASKS_DUE_ASAP_KEY, 
                          tasksDueToday, TASKS_DUE_TODAY_KEY,
                          tasksDueTomorrow, TASKS_DUE_TOMORROW_KEY,
                          tasksDueThisWeek, TASKS_DUE_THIS_WEEK_KEY,
                          tasksDueNextWeek, TASKS_DUE_NEXT_WEEK_KEY,
                          tasksDueLater, TASKS_DUE_LATER_KEY,
                          nil];
    NSNotification *notif = [NSNotification notificationWithName:SBNetworkManagerDidRetrieveTasksNotification
                                                          object:self 
                                                        userInfo:dict];
    [[NSNotificationCenter defaultCenter] postNotification:notif];    
}

@end
