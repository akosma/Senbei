//
//  SBPostCommentRequest.m
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

#import "SBPostCommentRequest.h"
#import "SBModels.h"
#import "SBSettingsManager.h"
#import "SBAppDelegate.h"
#import "SBNotifications.h"


@interface SBPostCommentRequest ()

@property (nonatomic, retain) SBBaseEntity *entity;

@end


@implementation SBPostCommentRequest

@synthesize entity = _entity;

+ (id)requestWithEntity:(SBBaseEntity *)entity comment:(NSString *)comment
{
    NSString *server = [SBSettingsManager sharedSBSettingsManager].server;
    Class klass = [entity class];
    NSString *path = [klass serverPath];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%d/comments", server, path, entity.objectId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSInteger idValue = [SBAppDelegate sharedAppDelegate].currentUser.objectId;
    NSNumber *currentUserID = [NSNumber numberWithInt:idValue];
    
    id request = [self requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setShouldRedirect:NO];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setPostValue:entity.commentableTypeName                forKey:@"comment[commentable_type]"];
    [request setPostValue:[NSNumber numberWithInt:entity.objectId]  forKey:@"comment[commentable_id]"];
    [request setPostValue:currentUserID                             forKey:@"comment[user_id]"];
    [request setPostValue:comment                                   forKey:@"comment[comment]"];
    return request;
}

- (void)processResponse
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.entity, @"entity", nil];
    NSNotification *notif = [NSNotification notificationWithName:SBNetworkManagerDidPostCommentNotification
                                                          object:self 
                                                        userInfo:dict];
    [[NSNotificationCenter defaultCenter] postNotification:notif];    
}

@end
