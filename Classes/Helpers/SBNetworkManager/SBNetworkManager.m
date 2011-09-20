//
//  SBNetworkManager.m
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

#import "SBNetworkManager.h"
#import "SBModels.h"
#import "SBRequests.h"
#import "SBNotifications.h"
#import "ASIHTTPRequest+Senbei.h"


@interface SBNetworkManager ()

@property (nonatomic, retain) ASINetworkQueue *networkQueue;

- (NSError *)createErrorWithMessage:(NSString *)string code:(NSInteger)code;
- (void)notifyError:(NSError *)error;

@end


@implementation SBNetworkManager

SYNTHESIZE_SINGLETON_FOR_CLASS(SBNetworkManager)

@synthesize networkQueue = _networkQueue;

#pragma mark -
#pragma mark Init and dealloc

- (id)init
{
    if (self = [super init])
    {
        self.networkQueue = [[[ASINetworkQueue alloc] init] autorelease];
        self.networkQueue.shouldCancelAllRequestsOnFailure = NO;
        self.networkQueue.delegate = self;
        self.networkQueue.requestDidFinishSelector = @selector(requestDone:);
        self.networkQueue.requestDidFailSelector = @selector(requestWentWrong:);
        self.networkQueue.queueDidFinishSelector = @selector(queueFinished:);
        [self.networkQueue go];
    }
    return self;
}

- (void)dealloc
{
    [_networkQueue release];
    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (void)login
{
    SBLoginRequest *request = [SBLoginRequest request];
    [self.networkQueue addOperation:request];    
}

- (void)loadList:(Class)klass page:(NSInteger)page
{
    SBListRequest *request = [SBListRequest requestWithClass:klass 
                                                        page:page];
    [self.networkQueue addOperation:request];
}

- (void)searchList:(Class)klass query:(NSString *)query
{
    SBSearchRequest *request = [SBSearchRequest requestWithClass:klass
                                                           query:query];
    [self.networkQueue addOperation:request];
}

- (void)loadCommentsForEntity:(SBBaseEntity *)entity
{
    SBCommentsRequest *request = [SBCommentsRequest requestWithEntity:entity];
    [self.networkQueue addOperation:request];
}

- (void)sendComment:(NSString *)comment forEntity:(SBBaseEntity *)entity
{
    SBPostCommentRequest *request = [SBPostCommentRequest requestWithEntity:entity 
                                                                    comment:comment];
    [self.networkQueue addOperation:request];
}

- (void)loadTasks
{
    SBTasksRequest *request = [SBTasksRequest request];
    [self.networkQueue addOperation:request];
}

- (void)markTaskAsDone:(SBTask *)task
{
    SBMarkTaskAsDoneRequest *request = [SBMarkTaskAsDoneRequest requestWithTask:task];
    [self.networkQueue addOperation:request];    
}

- (void)createTask:(SBTask *)task
{
    SBCreateTaskRequest *request = [SBCreateTaskRequest requestWithTask:task];
    [self.networkQueue addOperation:request];    
}

- (void)cancelConnections
{
    [self.networkQueue cancelAllOperations];
}

#pragma mark -
#pragma mark ASINetworkQueue delegate methods

- (void)requestDone:(SBBaseRequest *)request
{
    NSString *errorMessage = [request validateResponse];
    if (errorMessage == nil)
    {
        [request processResponse];
    }
    else if (request.responseStatusCode == 302)
    {
        NSNotification *notif = [NSNotification notificationWithName:SBNetworkManagerDidFailLoginNotification 
                                                              object:self 
                                                            userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notif];
    }
    else
    {
        NSError *error = [self createErrorWithMessage:errorMessage code:request.responseStatusCode];
        [self notifyError:error];
    }
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    [self notifyError:error];
}

- (void)queueFinished:(ASINetworkQueue *)queue
{
}

#pragma mark -
#pragma mark Error management

- (NSError *)createErrorWithMessage:(NSString *)text code:(NSInteger)code
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:text, NSLocalizedDescriptionKey, nil];
    NSError *error = [NSError errorWithDomain:@"Server"
                                         code:code
                                     userInfo:userInfo];
    return error;
}

- (void)notifyError:(NSError *)error
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, SBNetworkManagerErrorKey, nil];
    NSNotification *notif = [NSNotification notificationWithName:SBNetworkManagerDidFailWithErrorNotification 
                                                          object:self 
                                                        userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notif];    
}

@end
