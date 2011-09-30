//
//  SBCreateContactRequest.m
//  Senbei
//
//  Created by Adrian on 9/30/11.
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

#import "SBCreateContactRequest.h"
#import "SBModels.h"
#import "SBSettingsManager.h"
#import "SBAppDelegate.h"
#import "SBNotifications.h"

@implementation SBCreateContactRequest

+ (id)requestWithContact:(SBContact *)contact
{
    NSString *server = [SBSettingsManager sharedSBSettingsManager].server;
    NSString *urlString = [NSString stringWithFormat:@"%@/contacts", server];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSInteger idValue = [SBAppDelegate sharedAppDelegate].currentUser.objectId;
    NSNumber *currentUserID = [NSNumber numberWithInt:idValue];
    NSNumber *doNotCall = [NSNumber numberWithInt:0];
    
    id request = [self requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:currentUserID      forKey:@"contact[user_id]"];
    [request setPostValue:contact.firstName  forKey:@"contact[first_name]"];
    [request setPostValue:contact.lastName   forKey:@"contact[last_name]"];
    [request setPostValue:contact.email      forKey:@"contact[email]"];
    [request setPostValue:contact.phone      forKey:@"contact[phone]"];
    [request setPostValue:currentUserID      forKey:@"account[user_id]"];
    [request setPostValue:@""                forKey:@"account[assigned_to]"];
    [request setPostValue:@""                forKey:@"account[name]"];
    [request setPostValue:@""                forKey:@"contact[assigned_to]"];
    [request setPostValue:contact.title      forKey:@"contact[title]"];
    [request setPostValue:contact.department forKey:@"contact[department]"];
    [request setPostValue:@""                forKey:@"contact[alt_email]"];
    [request setPostValue:contact.mobile     forKey:@"contact[mobile]"];
    [request setPostValue:contact.address    forKey:@"contact[address]"];
    [request setPostValue:@""                forKey:@"contact[fax]"];
    [request setPostValue:doNotCall          forKey:@"contact[do_not_call]"];
    [request setPostValue:contact.blog       forKey:@"contact[blog]"];
    [request setPostValue:@""                forKey:@"contact[twitter]"];
    [request setPostValue:@""                forKey:@"contact[linkedin]"];
    [request setPostValue:@""                forKey:@"contact[facebook]"];
    [request setPostValue:@"Public"          forKey:@"contact[access]"];
    return request;
}

- (void)processResponse
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SBNetworkManagerDidCreateContactNotification
                                                        object:self];
}

@end
