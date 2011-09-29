//
//  SBDeleteCommentRequest.m
//  Senbei
//
//  Created by Adrian on 9/29/11.
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

#import "SBDeleteCommentRequest.h"
#import "SBModels.h"
#import "SBSettingsManager.h"
#import "SBNotifications.h"

@interface SBDeleteCommentRequest ()

@property (nonatomic, retain) SBBaseEntity *entity;

@end


@implementation SBDeleteCommentRequest

@synthesize entity = _entity;

+ (id)requestWithEntity:(SBBaseEntity *)entity commentID:(NSInteger)commentID
{
    NSString *server = [SBSettingsManager sharedSBSettingsManager].server;
    NSString *urlString = [NSString stringWithFormat:@"%@/comments/%d", server, commentID];
    NSURL *url = [NSURL URLWithString:urlString];
        
    id request = [self requestWithURL:url];
    [request setEntity:entity];
    [request setRequestMethod:@"POST"];
    [request setShouldRedirect:NO];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setPostValue:@"delete" forKey:@"_method"];
    [request setPostValue:@"" forKey:@"_"];
    
    // This is important, otherwise this request might generate
    // a 500 server error!
    [[request requestHeaders] removeObjectForKey:@"Accept"];
    [request addRequestHeader:@"Accept" value:@"text/javascript"];
    return request;
}

- (void)processResponse
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.entity, @"entity", nil];
    NSNotification *notif = [NSNotification notificationWithName:SBNetworkManagerDidDeleteCommentNotification
                                                          object:self 
                                                        userInfo:dict];
    [[NSNotificationCenter defaultCenter] postNotification:notif];    
}

@end
