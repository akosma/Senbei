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
#import "SBAppDelegate.h"
#import "SynthesizeSingleton.h"
#import "NSDate+Senbei.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Definitions.h"
#import "TBXML.h"
#import "SBModels.h"
#import "SettingsManager.h"

#define PROFILE_REQUEST @"profile"
#define COMMENTS_REQUEST @"comments"
#define TASKS_REQUEST @"tasks"
#define NEW_TASK_REQUEST @"task_new"
#define TASK_DONE_REQUEST @"task_done"
#define NEW_COMMENT_REQUEST @"new_comment"

@interface FatFreeCRMProxy ()

@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property (nonatomic, assign) NSNotificationCenter *notificationCenter;
@property (nonatomic, assign) SettingsManager *settingsManager;

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
- (NSArray *)deserializeXML:(NSData *)xmlData forXPath:(NSString *)xpath andClass:(Class)klass;
- (NSArray *)deserializeXMLElement:(TBXMLElement *)element forXPath:(NSString *)xpath andClass:(Class)klass;

@end


@implementation FatFreeCRMProxy

SYNTHESIZE_SINGLETON_FOR_CLASS(FatFreeCRMProxy)

@synthesize server = _server;
@synthesize username = _username;
@synthesize password = _password;
@synthesize networkQueue = _networkQueue;
@synthesize notificationCenter = _notificationCenter;
@synthesize settingsManager = _settingsManager;

#pragma mark -
#pragma mark Init and dealloc

- (id)init
{
    if (self = [super init])
    {
        self.notificationCenter = [NSNotificationCenter defaultCenter];
        self.settingsManager = [SettingsManager sharedSettingsManager];

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
    self.server = nil;
    self.username = nil;
    self.password = nil;
    self.notificationCenter = nil;
    self.settingsManager = nil;
    self.networkQueue = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (void)login
{
    NSString *path = PROFILE_REQUEST;
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", self.server, path];
    NSURL *url = [NSURL URLWithString:urlString];
    [self sendGETRequestToURL:url path:path];
}

- (void)loadList:(Class)klass page:(NSInteger)page
{
    NSString *path = [klass serverPath];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?page=%d", self.server, path, page];
    NSURL *url = [NSURL URLWithString:urlString];
    [self sendGETRequestToURL:url path:path];
}

- (void)searchList:(Class)klass query:(NSString *)query
{
    NSString *path = [klass serverPath];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?page=1&query=%@", self.server, path, query];
    NSURL *url = [NSURL URLWithString:urlString];
    [self sendGETRequestToURL:url path:path];
}

- (void)loadCommentsForEntity:(SBBaseEntity *)entity
{
    Class klass = [entity class];
    NSString *path = [klass serverPath];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%d/comments.xml", self.server, path, entity.objectId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.validatesSecureCertificate = !self.settingsManager.useSelfSignedSSLCertificates;
    request.username = self.username;
    request.password = self.password;
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:COMMENTS_REQUEST, SELECTED_API_PATH, 
                              entity, SELECTED_API_ENTITY, nil];
    request.userInfo = userInfo;
    [self.networkQueue addOperation:request];    
}

- (void)sendComment:(NSString *)comment forEntity:(SBBaseEntity *)entity
{
    Class klass = [entity class];
    NSString *path = [klass serverPath];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%d/comments", self.server, path, entity.objectId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSInteger idValue = [SBAppDelegate sharedAppDelegate].currentUser.objectId;
    NSNumber *currentUserID = [NSNumber numberWithInt:idValue];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.username = self.username;
    request.password = self.password;
    request.requestMethod = @"POST";
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:NEW_COMMENT_REQUEST, SELECTED_API_PATH, 
                              entity, SELECTED_API_ENTITY, nil];
    request.userInfo = userInfo;
    [request setPostValue:entity.commentableTypeName                forKey:@"comment[commentable_type]"];
    [request setPostValue:[NSNumber numberWithInt:entity.objectId]  forKey:@"comment[commentable_id]"];
    [request setPostValue:currentUserID                             forKey:@"comment[user_id]"];
    [request setPostValue:comment                                   forKey:@"comment[comment]"];
    [self.networkQueue addOperation:request];
}

- (void)loadTasks
{
    NSString *path = TASKS_REQUEST;
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", self.server, path];
    NSURL *url = [NSURL URLWithString:urlString];
    [self sendGETRequestToURL:url path:path];
}

- (void)markTaskAsDone:(SBTask *)task
{
    NSString *urlString = [NSString stringWithFormat:@"%@/tasks/%d/complete", self.server, task.objectId];
    NSURL *url = [NSURL URLWithString:urlString];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.validatesSecureCertificate = !self.settingsManager.useSelfSignedSSLCertificates;
    request.requestMethod = @"PUT";
    request.username = self.username;
    request.password = self.password;
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:TASK_DONE_REQUEST, SELECTED_API_PATH, nil];
    [self.networkQueue addOperation:request];    
}

- (void)createTask:(SBTask *)task
{
    NSString *urlString = [NSString stringWithFormat:@"%@/tasks", self.server, task.objectId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSInteger idValue = [SBAppDelegate sharedAppDelegate].currentUser.objectId;
    NSNumber *currentUserID = [NSNumber numberWithInt:idValue];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.requestMethod = @"POST";
    request.username = self.username;
    request.password = self.password;
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:NEW_TASK_REQUEST, SELECTED_API_PATH, nil];
    [request setPostValue:task.name                               forKey:@"task[name]"];
    [request setPostValue:task.category                           forKey:@"task[category]"];
    [request setPostValue:[task.dueDate stringForNewTaskCreation] forKey:@"task[calendar]"];
    [request setPostValue:task.bucket                             forKey:@"task[bucket]"];
    [request setPostValue:currentUserID                           forKey:@"task[user_id]"];
    [self.networkQueue addOperation:request];    
}

- (void)cancelConnections
{
    [self.networkQueue cancelAllOperations];
}

#pragma mark -
#pragma mark ASINetworkQueue delegate methods

- (void)requestDone:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = request.userInfo;
    NSString *selectedAPIPath = [userInfo objectForKey:SELECTED_API_PATH];
    if ([self requestOK:request])
    {
        if ([selectedAPIPath isEqualToString:[SBCompanyAccount serverPath]])
        {
            [self processGetAccountsRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:[SBOpportunity serverPath]])
        {
            [self processGetOpportunitiesRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:[SBContact serverPath]])
        {
            [self processGetContactsRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:[SBCampaign serverPath]])
        {
            [self processGetCampaignsRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:[SBLead serverPath]])
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
            SBBaseEntity *entity = [userInfo objectForKey:SELECTED_API_ENTITY];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:entity, @"entity", nil];
            NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidPostCommentNotification
                                                                  object:self 
                                                                userInfo:dict];
            [self.notificationCenter postNotification:notif];    
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
            [self.notificationCenter postNotificationName:FatFreeCRMProxyDidMarkTaskAsDoneNotification
                                               object:self];
        }
        else if ([selectedAPIPath isEqualToString:NEW_TASK_REQUEST])
        {
            [self.notificationCenter postNotificationName:FatFreeCRMProxyDidCreateTaskNotification
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
            [self.notificationCenter postNotification:notif];            
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
    [self.notificationCenter postNotification:notif];    
}

#pragma mark -
#pragma mark Request processing methods

- (NSArray *)deserializeXMLElement:(TBXMLElement *)element forXPath:(NSString *)xpath andClass:(Class)klass
{
    NSMutableArray *objects = [NSMutableArray array];
    if (element)
    {
        TBXMLElement *child = [TBXML childElementNamed:xpath parentElement:element];
        
        while (child != nil)
        {
            id item = [[klass alloc] initWithTBXMLElement:child];
            [objects addObject:item];
            [item release];
            
            child = [TBXML nextSiblingNamed:xpath searchFromElement:child];
        }
    }
    return objects;
}

- (NSArray *)deserializeXML:(NSData *)xmlData forXPath:(NSString *)xpath andClass:(Class)klass
{
    TBXML *tbxml = [TBXML tbxmlWithXMLData:xmlData];
    TBXMLElement *root = tbxml.rootXMLElement;
    return [self deserializeXMLElement:root forXPath:xpath andClass:klass];
}

- (void)processGetAccountsRequest:(ASIHTTPRequest *)request
{
    NSData *response = [request responseData];
    NSArray *accounts = [self deserializeXML:response 
                                    forXPath:@"account" 
                                    andClass:NSClassFromString(@"SBCompanyAccount")];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:accounts, @"data", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveAccountsNotification
                                                          object:self 
                                                        userInfo:dict];
    [self.notificationCenter postNotification:notif];
}

- (void)processGetCampaignsRequest:(ASIHTTPRequest *)request
{
    NSData *response = [request responseData];
    NSArray *campaigns = [self deserializeXML:response 
                                     forXPath:@"campaign" 
                                     andClass:NSClassFromString(@"SBCampaign")];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:campaigns, @"data", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveCampaignsNotification
                                                          object:self 
                                                        userInfo:dict];
    [self.notificationCenter postNotification:notif];
}

- (void)processGetLeadsRequest:(ASIHTTPRequest *)request
{
    NSData *response = [request responseData];
    NSArray *leads = [self deserializeXML:response 
                                 forXPath:@"lead" 
                                 andClass:NSClassFromString(@"SBLead")];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:leads, @"data", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveLeadsNotification
                                                          object:self 
                                                        userInfo:dict];
    [self.notificationCenter postNotification:notif];
}

- (void)processGetOpportunitiesRequest:(ASIHTTPRequest *)request
{
    NSData *response = [request responseData];
    NSArray *opportunities = [self deserializeXML:response 
                                         forXPath:@"opportunity" 
                                         andClass:NSClassFromString(@"SBOpportunity")];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:opportunities, @"data", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveOpportunitiesNotification
                                                          object:self 
                                                        userInfo:dict];
    [self.notificationCenter postNotification:notif];
}

- (void)processGetContactsRequest:(ASIHTTPRequest *)request
{
    NSData *response = [request responseData];
    NSArray *contacts = [self deserializeXML:response 
                                    forXPath:@"contact" 
                                    andClass:NSClassFromString(@"SBContact")];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:contacts, @"data", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveContactsNotification
                                                          object:self 
                                                        userInfo:dict];
    [self.notificationCenter postNotification:notif];    
}

- (void)processGetCommentsRequest:(ASIHTTPRequest *)request
{
    NSData *response = [request responseData];
    NSArray *comments = [self deserializeXML:response 
                                    forXPath:@"comment" 
                                    andClass:NSClassFromString(@"SBComment")];

    SBBaseEntity *entity = [request.userInfo objectForKey:SELECTED_API_ENTITY];

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:comments, @"data", entity, @"entity", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveCommentsNotification
                                                          object:self 
                                                        userInfo:dict];
    [self.notificationCenter postNotification:notif];    
}

- (void)processLoginRequest:(ASIHTTPRequest *)request
{
    NSData *response = [request responseData];
    TBXML *tbxml = [TBXML tbxmlWithXMLData:response];
    TBXMLElement *root = tbxml.rootXMLElement;
    SBUser *user = [[[SBUser alloc] initWithTBXMLElement:root] autorelease];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:user, @"user", nil];
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidLoginNotification
                                                          object:self 
                                                        userInfo:dict];
    [self.notificationCenter postNotification:notif];    
}

- (void)processGetTasksRequest:(ASIHTTPRequest *)request
{
    NSData *response = [request responseData];
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
    NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidRetrieveTasksNotification
                                                          object:self 
                                                        userInfo:dict];
    [self.notificationCenter postNotification:notif];    
}

#pragma mark -
#pragma mark Private methods

- (void)sendGETRequestToURL:(NSURL *)url path:(NSString *)path
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.validatesSecureCertificate = !self.settingsManager.useSelfSignedSSLCertificates;
    request.username = self.username;
    request.password = self.password;
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:path, SELECTED_API_PATH, nil];
    [request addRequestHeader:@"Accept" value:@"text/xml"];
    [self.networkQueue addOperation:request];    
}

@end
