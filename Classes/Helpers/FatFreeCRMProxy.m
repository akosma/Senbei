//
//  FatFreeCRMProxy.m
//  Saccharin
//
//  Created by Adrian on 1/19/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "FatFreeCRMProxy.h"
#import "SaccharinAppDelegate.h"
#import "SynthesizeSingleton.h"
#import "NSDate+Saccharin.h"
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

@interface FatFreeCRMProxy ()

- (void)sendGETRequestToURL:(NSURL *)url path:(NSString *)path;
- (BOOL)requestOK:(ASIHTTPRequest *)request;
- (void)notifyError:(NSError *)error;
- (void)processGetAccountsRequest:(ASIHTTPRequest *)request;
- (void)processGetOpportunitiesRequest:(ASIHTTPRequest *)request;
- (void)processGetCampaignsRequest:(ASIHTTPRequest *)request;
- (void)processGetLeadsRequest:(ASIHTTPRequest *)request;
- (void)processGetContactsRequest:(ASIHTTPRequest *)request;
- (void)processGetCommentsRequest:(ASIHTTPRequest *)request;
- (void)processLoginRequest:(ASIHTTPRequest *)request;
- (void)processGetTasksRequest:(ASIHTTPRequest *)request;
- (NSString *)applicationDocumentsDirectory;
- (NSArray *)deserializeXML:(NSString *)xmlString forXPath:(NSString *)xpath andClass:(Class)klass;

@end


@implementation FatFreeCRMProxy

SYNTHESIZE_SINGLETON_FOR_CLASS(FatFreeCRMProxy)

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
    [_networkQueue release];
    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (void)login
{
    NSString *path = @"profile";
    NSString *serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_SERVER_URL];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", serverURL, path];
    NSURL *url = [NSURL URLWithString:urlString];
    [self sendGETRequestToURL:url path:path];
}

- (void)loadList:(Class)klass page:(NSInteger)page
{
    NSString *path = [klass serverPath];
    NSString *serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_SERVER_URL];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?page=%d", serverURL, path, page];
    NSURL *url = [NSURL URLWithString:urlString];
    [self sendGETRequestToURL:url path:path];
}

- (void)searchList:(Class)klass query:(NSString *)query
{
    NSString *path = [klass serverPath];
    NSString *serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_SERVER_URL];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?page=1&query=%@", serverURL, path, query];
    NSURL *url = [NSURL URLWithString:urlString];
    [self sendGETRequestToURL:url path:path];
}

- (void)loadCommentsForEntity:(BaseEntity *)entity
{
    Class klass = [entity class];
    NSString *path = [klass serverPath];
    NSString *serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_SERVER_URL];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%d/comments.xml", serverURL, path, entity.objectId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.username = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_USERNAME];;
    request.password = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_PASSWORD];;
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"comments", SELECTED_API_PATH, 
                              entity, SELECTED_API_ENTITY, 
                              nil];
    request.userInfo = userInfo;
    [_networkQueue addOperation:request];    
}

- (void)sendComment:(NSString *)comment forEntity:(BaseEntity *)entity
{
    Class klass = [entity class];
    NSString *path = [klass serverPath];
    NSString *serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_SERVER_URL];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%d/comments", serverURL, path, entity.objectId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSInteger idValue = [SaccharinAppDelegate sharedAppDelegate].currentUser.objectId;
    NSNumber *currentUserID = [NSNumber numberWithInt:idValue];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:NSStringFromClass([entity class])         forKey:@"comment[commentable_type]"];
    [request setPostValue:[NSNumber numberWithInt:entity.objectId]  forKey:@"comment[commentable_id]"];
    [request setPostValue:currentUserID                             forKey:@"comment[user_id]"];
    [request setPostValue:comment                                   forKey:@"comment[comment]"];
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"new_comment", SELECTED_API_PATH, 
                              entity, SELECTED_API_ENTITY, 
                              nil];
    request.userInfo = userInfo;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    [_networkQueue addOperation:request];
}

- (void)loadTasks
{
    NSString *path = @"tasks";
    NSString *serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_SERVER_URL];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", serverURL, path];
    NSURL *url = [NSURL URLWithString:urlString];
    [self sendGETRequestToURL:url path:path];
}

- (void)markTaskAsDone:(Task *)task
{
    NSString *serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_SERVER_URL];
    NSString *urlString = [NSString stringWithFormat:@"%@/tasks/%d/complete", serverURL, task.objectId];
    NSURL *url = [NSURL URLWithString:urlString];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    request.username = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_USERNAME];
    request.password = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_PASSWORD];
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"task_done", SELECTED_API_PATH, nil];
    request.userInfo = userInfo;
    [_networkQueue addOperation:request];    
}

- (void)createTask:(Task *)task
{
    NSString *serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_SERVER_URL];
    NSString *urlString = [NSString stringWithFormat:@"%@/tasks", serverURL, task.objectId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSInteger idValue = [SaccharinAppDelegate sharedAppDelegate].currentUser.objectId;
    NSNumber *currentUserID = [NSNumber numberWithInt:idValue];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    request.username = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_USERNAME];
    request.password = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_PASSWORD];
    [request setPostValue:task.name                               forKey:@"task[name]"];
    [request setPostValue:task.category                           forKey:@"task[category]"];
    [request setPostValue:[task.dueDate stringForNewTaskCreation] forKey:@"task[calendar]"];
    [request setPostValue:task.bucket                             forKey:@"task[bucket]"];
    [request setPostValue:currentUserID                           forKey:@"task[user_id]"];
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"task_new", SELECTED_API_PATH, nil];
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
        else if ([selectedAPIPath isEqualToString:@"comments"])
        {
            [self processGetCommentsRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:@"new_comment"])
        {
            NSDictionary *userInfo = request.userInfo;
            BaseEntity *entity = [userInfo objectForKey:SELECTED_API_ENTITY];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:entity, @"entity", nil];
            NSNotification *notif = [NSNotification notificationWithName:FatFreeCRMProxyDidPostCommentNotification
                                                                  object:self 
                                                                userInfo:dict];
            [_notificationCenter postNotification:notif];    
        }
        else if ([selectedAPIPath isEqualToString:@"profile"])
        {
            [self processLoginRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:@"tasks"])
        {
            [self processGetTasksRequest:request];
        }
        else if ([selectedAPIPath isEqualToString:@"task_done"])
        {
            [_notificationCenter postNotificationName:FatFreeCRMProxyDidMarkTaskAsDoneNotification
                                               object:self];
        }
        else if ([selectedAPIPath isEqualToString:@"task_new"])
        {
            [_notificationCenter postNotificationName:FatFreeCRMProxyDidCreateTaskNotification
                                               object:self];
        }
    }
    else 
    {
        // Create an error object and notify
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
    return (request.responseStatusCode == 200) || (request.responseStatusCode == 201);
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
                                    andClass:NSClassFromString(@"Account")];
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

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:tasksOverdue, @"tasksOverdue",
                          tasksDueASAP, @"tasksDueASAP", 
                          tasksDueToday, @"tasksDueToday",
                          tasksDueTomorrow, @"tasksDueTomorrow",
                          tasksDueThisWeek, @"tasksDueThisWeek",
                          tasksDueNextWeek, @"tasksDueNextWeek",
                          tasksDueLater, @"tasksDueLater",
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
    request.username = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_USERNAME];
    request.password = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_PASSWORD];
    [request addRequestHeader:@"Accept" value:@"text/xml"];
    request.shouldRedirect = NO;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = REQUEST_TIMEOUT;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:path, SELECTED_API_PATH, nil];
    request.userInfo = userInfo;
    [_networkQueue addOperation:request];    
}

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
