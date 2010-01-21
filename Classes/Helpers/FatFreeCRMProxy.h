//
//  FatFreeCRMProxy.h
//  Saccharin
//
//  Created by Adrian on 1/19/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FatFreeCRMProxyDidFailWithErrorNotification @"FatFreeCRMProxyDidFailWithErrorNotification"
#define FatFreeCRMProxyDidRetrieveTasksNotification @"FatFreeCRMProxyDidRetrieveTasksNotification"
#define FatFreeCRMProxyDidRetrieveAccountsNotification @"FatFreeCRMProxyDidRetrieveAccountsNotification"
#define FatFreeCRMProxyDidRetrieveOpportunitiesNotification @"FatFreeCRMProxyDidRetrieveOpportunitiesNotification"
#define FatFreeCRMProxyDidRetrieveContactsNotification @"FatFreeCRMProxyDidRetrieveContactsNotification"
#define FatFreeCRMProxyDidRetrieveCommentsNotification @"FatFreeCRMProxyDidRetrieveCommentsNotification"
#define FatFreeCRMProxyDidPostCommentNotification @"FatFreeCRMProxyDidPostCommentNotification"
#define FatFreeCRMProxyDidLoginNotification @"FatFreeCRMProxyDidLoginNotification"
#define FatFreeCRMProxyDidFailLoginNotification @"FatFreeCRMProxyDidFailLoginNotification"

#define FatFreeCRMProxyErrorKey @"FatFreeCRMProxyErrorKey"

@class ASINetworkQueue;
@class BaseEntity;

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
- (void)loadTasks;
- (void)cancelConnections;

@end
