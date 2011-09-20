//
//  ASIHTTPRequest+Senbei.m
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

#import "ASIHTTPRequest+Senbei.h"
#import "SBNotifications.h"
#import "SBModels.h"

@implementation ASIHTTPRequest (ASIHTTPRequest_Senbei)

- (void)processResponse
{
    // To be overridden by subclasses
}

- (NSString *)validateResponse
{
    NSInteger statusCode = self.responseStatusCode;
    NSString *errorMessage = nil;
    
    switch (statusCode) 
    {
        case 200:
        case 201:
        {
            break;
        }
            
        case 302:
        case 401:
        {
            // In the case of FFCRM, bad login API requests receive a 302,
            // with a redirection body taking to the login form
            errorMessage = @"Unauthorized";
            break;
        }
            
        case 404:
        {
            errorMessage = @"The specified path cannot be found (404)";
            break;
        }
            
        case 500:
        {
            errorMessage = @"The server experienced an error (500)";
            break;
        }
            
        default:
        {
            errorMessage = [NSString stringWithFormat:@"The communication with the server failed with error %d", statusCode];
            break;
        }
    }
    
    return errorMessage;
}

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

@end
