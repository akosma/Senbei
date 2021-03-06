//
//  SBListRequest.m
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

#import "SBListRequest.h"
#import "SBSettingsManager.h"
#import "SBModels.h"
#import "SBNotifications.h"


@implementation SBListRequest

@synthesize klass = _klass;

+ (id)requestWithClass:(Class)klass page:(NSInteger)page
{
    NSString *server = [SBSettingsManager sharedSBSettingsManager].server;
    NSString *path = [klass serverPath];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?page=%d", server, path, page];
    NSURL *url = [NSURL URLWithString:urlString];
    id request = [self requestWithURL:url];
    [request setKlass:klass];
    return request;
}

- (void)dealloc
{
    [_klass release];
    [super dealloc];
}

- (void)processResponse
{
    NSString *xpath = nil;
    NSString *notificationName = nil;
    if (self.klass == [SBCompanyAccount class])
    {
        xpath = @"account";
        notificationName = SBNetworkManagerDidRetrieveAccountsNotification;
    }
    else if (self.klass == [SBCampaign class])
    {
        xpath = @"campaign";
        notificationName = SBNetworkManagerDidRetrieveCampaignsNotification;
    }
    else if (self.klass == [SBLead class])
    {
        xpath = @"lead";
        notificationName = SBNetworkManagerDidRetrieveLeadsNotification;
    }
    else if (self.klass == [SBOpportunity class])
    {
        xpath = @"opportunity";
        notificationName = SBNetworkManagerDidRetrieveOpportunitiesNotification;
    }
    else if (self.klass == [SBContact class])
    {
        xpath = @"contact";
        notificationName = SBNetworkManagerDidRetrieveContactsNotification;
    }
    
    if (xpath != nil && notificationName != nil)
    {
        NSData *response = [self responseData];
        NSArray *campaigns = [self deserializeXML:response 
                                         forXPath:xpath 
                                         andClass:self.klass];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:campaigns, @"data", nil];
        NSNotification *notif = [NSNotification notificationWithName:notificationName
                                                              object:self 
                                                            userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotification:notif];
    }
}

@end
