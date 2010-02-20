//
//  FatFreeCRMProxy.m
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

#import "FatFreeCRMProxy.h"
#import "SenbeiAppDelegate.h"
#import "SynthesizeSingleton.h"
#import "NSDate+Senbei.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Definitions.h"
#import "TouchXML.h"
#import "CompanyAccount.h"
#import "Opportunity.h"
#import "Contact.h"
#import "Comment.h"
#import "User.h"
#import "Task.h"
#import "Campaign.h"
#import "Lead.h"

#define PROFILE_REQUEST @"profile"
#define COMMENTS_REQUEST @"comments"
#define TASKS_REQUEST @"tasks"
#define NEW_TASK_REQUEST @"task_new"
#define TASK_DONE_REQUEST @"task_done"
#define NEW_COMMENT_REQUEST @"new_comment"

@interface FatFreeCRMProxy ()

- (void)sendGETRequestToURL:(NSURL *)url path:(NSString *)path;
- (BOOL)requestOK:(ASIHTTPRequest *)request;
- (NSError *)createErrorWithMessage:(NSString *)string code:(NSInteger)code;
- (void)notifyError:(NSError *)error;
- (void)processGetAccountsRequest:(ASIHTTPRequest *)request;
- (void)processGetOpportunitiesRequest:(ASIHTTPRequest *)request;
- (void)processGetCampaignsRequest:(ASIHTTPRequest *)request;
- (void)processGetLeadsRequest:(ASIHTTPRequest *)request;
- (void)processGetContactsRequest:(ASIHTTPRequest *)request;
- (void)processGetCommentsRequest:(ASIHTTPRequest *)request;
- (void)processLoginRequest:(ASIHTTPRequest *)request;
- (void)processGetTasksRequest:(ASIHTTPRequest *)request;
- (NSArray *)deserializeXML:(NSString *)xmlString forXPath:(NSString *)xpath andClass:(Class)klass;

@end


@implementation FatFreeCRMProxy

SYNTHESIZE_SINGLETON_FOR_CLASS(FatFreeCRMProxy)

@synthesize server = _server;
@synthesize username = _username;
@synthesize password = _password;

#pragma mark -
#pragma mark Init and dealloc

- (id)init
{
    if (self = [super init])
    {
        _notificationCenter = [NSNotificationCenter defaultCenter];

        _networkQueue = [[ASINetworkQueue alloc] init];
        _networkQueue.shouldCancelAllRequestsOnFailure = NO;
        _networkQueue.delegate = self;
        _networkQueue.requestDidFinishSelector = @selector(requestDone:);
        _networkQueue.requestDidFailSelector = @selector(requestWentWrong:);
        _networkQueue.queueDidFinishSelector = @selector(queueFinished:);
        [_networkQueue go];
    }
    return self;
}

- (void)dealloc
{
    [_server release];
    [_username release];
    [_password release];
    [_networkQueue release];
    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (void)login
{
    NSString *path = PROFILE_REQUEST;
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", _server, path];
    NSURL *url = [NSURL URLWithString:urlString];
    [self sendGETRequestToURL:url path:path];
}

- (void)loadList:(Class)klass page:(NSInteger)page
{
    NSString *path = [klass serverPath];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?page=%d", _server, path, page];
    NSURL *url = [NSURL URLWithString:urlString];
    [self sendGETRequestToURL:url path:path];
}

- (void)searchList:(Class)klass query:(NSString *)query
{
    NSString *path = [klass serverPath];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?page=1&query=%@", _server, path, query];
    NSURL *url = [NSURL URLWithString:urlString];
    [self sendGETRequestToURL:url path:path];
}

- (void)loadCommentsForEntity:(BaseEntity *)entity
{
    Class klass = [entity class];
    NSString *path = [klass serverPath];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%d/comments.xml", _server, path, entity.objectId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.username = _username;
    request.password = _password;
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:COMMENTS_REQUEST, SELECTED_API_PATH, 
                              entity, SELECTED_API_ENTITY, 
                              nil];
    request.userInfo = userInfo;
    [_networkQueue addOperation:request];    
}

- (void)sendComment:(NSString *)comment forEntity:(BaseEntity *)entity
{
    Class klass = [entity class];
    NSString *path = [klass serverPath];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%d/comments", _server, path, entity.objectId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSInteger idValue = [SenbeiAppDelegate sharedAppDelegate].currentUser.objectId;
    NSNumber *currentUserID = [NSNumber numberWithInt:idValue];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:entity.commentableTypeName                forKey:@"comment[commentable_type]"];
    [request setPostValue:[NSNumber numberWithInt:entity.objectId]  forKey:@"comment[commentable_id]"];
    [request setPostValue:currentUserID                             forKey:@"comment[user_id]"];
    [request setPostValue:comment                                   forKey:@"comment[comment]"];
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:NEW_COMMENT_REQUEST, SELECTED_API_PATH, 
                              entity, SELECTED_API_ENTITY, 
                              nil];
    request.userInfo = userInfo;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    [_networkQueue addOperation:request];
}

- (void)loadTasks
{
    NSString *path = TASKS_REQUEST;
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", _server, path];
    NSURL *url = [NSURL URLWithString:urlString];
    [self sendGETRequestToURL:url path:path];
}

- (void)markTaskAsDone:(Task *)task
{
    NSString *urlString = [NSString stringWithFormat:@"%@/tasks/%d/complete", _server, task.objectId];
    NSURL *url = [NSURL URLWithString:urlString];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    request.username = _username;
    request.password = _password;
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:TASK_DONE_REQUEST, SELECTED_API_PATH, nil];
    request.userInfo = userInfo;
    [_networkQueue addOperation:request];    
}

- (void)createTask:(Task *)task
{
    NSString *urlString = [NSString stringWithFormat:@"%@/tasks", _server, task.objectId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSInteger idValue = [SenbeiAppDelegate sharedAppDelegate].currentUser.objectId;
    NSNumber *currentUserID = [NSNumber numberWithInt:idValue];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    request.username = _username;
    request.password = _password;
    [request setPostValue:task.name                               forKey:@"task[name]"];
    [request setPostValue:task.category                           forKey:@"task[category]"];
    [request setPostValue:[task.dueDate stringForNewTaskCreation] forKey:@"task[calendar]"];
    [request setPostValue:task.bucket                             forKey:@"task[bucket]"];
    [request setPostValue:currentUserID                           forKey:@"task[user_id]"];
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:NEW_TASK_REQUEST, SELECTED_API_PATH, nil];
    request.userInfo = userInfo;
    [_networkQueue addOperation:request];    
}

- (void)cancelConnections
{
    [_networkQueue cancelAllOperations];
}

#pragma mark -
#pragma mark ASINetworkQueue delegate methods

- (void)requestDone:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = request.userInfo;
    NSString *selectedAPIPath = [userInfo objectForKey:SELECTED_API_PATH];
    if ([self requestOK:request])
    {
        if ([selectedAPIPath isEqualToString:[CompanyAccount serverPath]])
        {
            [self processGetAccountsRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:[Opportunity serverPath]])
        {
            [self processGetOpportunitiesRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:[Contact serverPath]])
        {
            [self processGetContactsRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:[Campaign serverPath]])
        {
            [self processGetCampaignsRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:[Lead serverPath]])
        {
            [self processGetLeadsRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:COMMENTS_REQUEST])
        {
            [self processGetCommentsRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:NEW_COMMENT_REQUEST])
        {
            NSDictionary *userInfo = request.userInfo;
            BaseEntity *entity = [userInfo objectForKey:SELECTED_API_ENTITY];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:entity, @"entity", nil];
            NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidPostCommentNotification
                                                                  object:self 
                                                                userInfo:dict];
            [_notificationCenter postNotification:notif];    
        }
        else if ([selectedAPIPath isEqualToString:PROFILE_REQUEST])
        {
            [self processLoginRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:TASKS_REQUEST])
        {
            [self processGetTasksRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:TASK_DONE_REQUEST])
        {
            [_notificationCenter postNotificationName:FatFreeCRMProxyDidMarkTaskAsDoneNotification
                                               object:self];
        }
        else if ([selectedAPIPath isEqualToString:NEW_TASK_REQUEST])
        {
            [_notificationCenter postNotificationName:FatFreeCRMProxyDidCreateTaskNotification
                                               object:self];
        }
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

- (BOOL)requestOK:(ASIHTTPRequest *)request
{
    NSInteger statusCode = request.responseStatusCode;
    BOOL ok = NO;
    NSString *text = @"";
    NSError *error = nil;

    switch (statusCode) 
    {
        case 200:
        case 201:
        {
            ok = YES;
            break;
        }
            
        case 302:
        case 401:
        {
            // In the case of FFCRM, bad login API requests receive a 302,
            // with a redirection body taking to the login form
            NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidFailLoginNotification 
                                                                  object:self 
                                                                userInfo:nil];
            [_notificationCenter postNotification:notif];            
            break;
        }

        case 404:
        {
            text = @"The specified path cannot be found (404)";
            error = [self createErrorWithMessage:text code:statusCode];
            break;
        }
            
        case 500:
        {
            text = @"The server experienced an error (500)";
            error = [self createErrorWithMessage:text code:statusCode];
            break;
        }
            
        default:
        {
            text = [NSString stringWithFormat:@"The communication with the server failed with error %d", statusCode];
            error = [self createErrorWithMessage:text code:statusCode];
            break;
        }
    }
    
    if (error != nil)
    {
        [self notifyError:error];
    }
    
    return ok;
}

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
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, FatFreeCRMProxyErrorKey, nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidFailWithErrorNotification 
                                                          object:self 
                                                        userInfo:userInfo];
    [_notificationCenter postNotification:notif];    
}

#pragma mark -
#pragma mark Request processing methods

- (NSArray *)deserializeXML:(NSString *)xmlString forXPath:(NSString *)xpath andClass:(Class)klass
{
    CXMLDocument *xml = [[CXMLDocument alloc] initWithXMLString:xmlString 
                                                        options:0 
                                                          error:nil];
    NSArray *xmlNodes = [xml nodesForXPath:xpath error:nil];
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[xmlNodes count]];
    for (CXMLElement *element in xmlNodes) 
    {
        id item = [[klass alloc] initWithCXMLElement:element];
        [objects addObject:item];
        [item release];
    }
    [xml release];
    return objects;
}

- (void)processGetAccountsRequest:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    NSArray *accounts = [self deserializeXML:response 
                                    forXPath:@"//account" 
                                    andClass:NSClassFromString(@"CompanyAccount")];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:accounts, @"data", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveAccountsNotification
                                                          object:self 
                                                        userInfo:dict];
    [_notificationCenter postNotification:notif];
}

- (void)processGetCampaignsRequest:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    NSArray *campaigns = [self deserializeXML:response 
                                     forXPath:@"//campaign" 
                                     andClass:NSClassFromString(@"Campaign")];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:campaigns, @"data", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveCampaignsNotification
                                                          object:self 
                                                        userInfo:dict];
    [_notificationCenter postNotification:notif];
}

- (void)processGetLeadsRequest:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    NSArray *leads = [self deserializeXML:response 
                                 forXPath:@"//lead" 
                                 andClass:NSClassFromString(@"Lead")];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:leads, @"data", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveLeadsNotification
                                                          object:self 
                                                        userInfo:dict];
    [_notificationCenter postNotification:notif];
}

- (void)processGetOpportunitiesRequest:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    NSArray *opportunities = [self deserializeXML:response 
                                         forXPath:@"//opportunity" 
                                         andClass:NSClassFromString(@"Opportunity")];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:opportunities, @"data", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveOpportunitiesNotification
                                                          object:self 
                                                        userInfo:dict];
    [_notificationCenter postNotification:notif];
}

- (void)processGetContactsRequest:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    NSArray *contacts = [self deserializeXML:response 
                                    forXPath:@"//contact" 
                                    andClass:NSClassFromString(@"Contact")];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:contacts, @"data", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveContactsNotification
                                                          object:self 
                                                        userInfo:dict];
    [_notificationCenter postNotification:notif];    
}

- (void)processGetCommentsRequest:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    NSArray *comments = [self deserializeXML:response 
                                    forXPath:@"/comments/comment" 
                                    andClass:NSClassFromString(@"Comment")];

    NSDictionary *userInfo = request.userInfo;
    BaseEntity *entity = [userInfo objectForKey:SELECTED_API_ENTITY];

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:comments, @"data", entity, @"entity", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveCommentsNotification
                                                          object:self 
                                                        userInfo:dict];
    [_notificationCenter postNotification:notif];    
}

- (void)processLoginRequest:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    NSArray *users = [self deserializeXML:response 
                                 forXPath:@"/user" 
                                 andClass:NSClassFromString(@"User")];

    User *user = [users objectAtIndex:0];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:user, @"user", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidLoginNotification
                                                          object:self 
                                                        userInfo:dict];
    [_notificationCenter postNotification:notif];    
}

- (void)processGetTasksRequest:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    NSArray *tasksOverdue = [self deserializeXML:response 
                                        forXPath:@"/hash/overdue/overdue" 
                                        andClass:NSClassFromString(@"Task")];
    NSArray *tasksDueASAP = [self deserializeXML:response 
                                        forXPath:@"/hash/due-asap/due-asap" 
                                        andClass:NSClassFromString(@"Task")];
    NSArray *tasksDueToday = [self deserializeXML:response 
                                         forXPath:@"/hash/due-today/due-today" 
                                         andClass:NSClassFromString(@"Task")];
    NSArray *tasksDueTomorrow = [self deserializeXML:response 
                                            forXPath:@"/hash/due-tomorrow/due-tomorrow" 
                                            andClass:NSClassFromString(@"Task")];
    NSArray *tasksDueThisWeek = [self deserializeXML:response 
                                            forXPath:@"/hash/due-this-week/due-this-week" 
                                            andClass:NSClassFromString(@"Task")];
    NSArray *tasksDueNextWeek = [self deserializeXML:response 
                                            forXPath:@"/hash/due-next-week/due-next-week" 
                                            andClass:NSClassFromString(@"Task")];
    NSArray *tasksDueLater = [self deserializeXML:response 
                                         forXPath:@"/hash/due-later/due-later" 
                                         andClass:NSClassFromString(@"Task")];

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:tasksOverdue, TASKS_OVERDUE_KEY,
                          tasksDueASAP, TASKS_DUE_ASAP_KEY, 
                          tasksDueToday, TASKS_DUE_TODAY_KEY,
                          tasksDueTomorrow, TASKS_DUE_TOMORROW_KEY,
                          tasksDueThisWeek, TASKS_DUE_THIS_WEEK_KEY,
                          tasksDueNextWeek, TASKS_DUE_NEXT_WEEK_KEY,
                          tasksDueLater, TASKS_DUE_LATER_KEY,
                          nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveTasksNotification
                                                          object:self 
                                                        userInfo:dict];
    [_notificationCenter postNotification:notif];    
}

#pragma mark -
#pragma mark Private methods

- (void)sendGETRequestToURL:(NSURL *)url path:(NSString *)path
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.username = _username;
    request.password = _password;
    [request addRequestHeader:@"Accept" value:@"text/xml"];
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:path, SELECTED_API_PATH, nil];
    request.userInfo = userInfo;
    [_networkQueue addOperation:request];    
}

@end
