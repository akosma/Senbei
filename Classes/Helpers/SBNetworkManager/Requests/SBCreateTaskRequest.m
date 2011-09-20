//
//  SBCreateTaskRequest.m
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

#import "SBCreateTaskRequest.h"
#import "SBModels.h"
#import "SBNotifications.h"
#import "SBSettingsManager.h"
#import "SBAppDelegate.h"
#import "NSDate+Senbei.h"

@implementation SBCreateTaskRequest

+ (id)requestWithTask:(SBTask *)task
{
    NSString *server = [SBSettingsManager sharedSBSettingsManager].server;
    NSString *urlString = [NSString stringWithFormat:@"%@/tasks", server, task.objectId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSInteger idValue = [SBAppDelegate sharedAppDelegate].currentUser.objectId;
    NSNumber *currentUserID = [NSNumber numberWithInt:idValue];
    
    id request = [self requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:task.name                               forKey:@"task[name]"];
    [request setPostValue:task.category                           forKey:@"task[category]"];
    [request setPostValue:[task.dueDate stringForNewTaskCreation] forKey:@"task[calendar]"];
    [request setPostValue:task.bucket                             forKey:@"task[bucket]"];
    [request setPostValue:currentUserID                           forKey:@"task[user_id]"];
    return request;
}

- (void)processResponse
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SBNetworkManagerDidCreateTaskNotification
                                                        object:self];
}

@end
