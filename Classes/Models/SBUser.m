//
//  SBUser.m
//  Senbei
//
//  Created by Adrian on 1/21/10.
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

#import "SBUser.h"

@implementation SBUser

@synthesize admin = _admin;
@synthesize aim = _aim;
@synthesize altEmail = _altEmail;
@synthesize company = _company;
@synthesize email = _email;
@synthesize firstName = _firstName;
@synthesize google = _google;
@synthesize lastName = _lastName;
@synthesize mobile = _mobile;
@synthesize phone = _phone;
@synthesize skype = _skype;
@synthesize title = _title;
@synthesize username = _username;
@synthesize yahoo = _yahoo;

- (id)initWithTBXMLElement:(TBXMLElement *)element
{
    if (self = [super initWithTBXMLElement:element])
    {
        self.admin = [[SBBaseEntity stringValueForElement:@"admin" parentElement:element] isEqualToString:@"true"];
        self.altEmail = [SBBaseEntity stringValueForElement:@"alt-email" parentElement:element];
        self.company = [SBBaseEntity stringValueForElement:@"company" parentElement:element];
        self.email = [SBBaseEntity stringValueForElement:@"email" parentElement:element];
        self.firstName = [SBBaseEntity stringValueForElement:@"first-name" parentElement:element];
        self.google = [SBBaseEntity stringValueForElement:@"google" parentElement:element];
        self.lastName = [SBBaseEntity stringValueForElement:@"last-name" parentElement:element];
        self.mobile = [SBBaseEntity stringValueForElement:@"mobile" parentElement:element];
        self.phone = [SBBaseEntity stringValueForElement:@"phone" parentElement:element];
        self.skype = [SBBaseEntity stringValueForElement:@"skype" parentElement:element];
        self.title = [SBBaseEntity stringValueForElement:@"title" parentElement:element];
        self.username = [SBBaseEntity stringValueForElement:@"username" parentElement:element];
        self.yahoo = [SBBaseEntity stringValueForElement:@"yahoo" parentElement:element];
    }
    return self;
}

- (void)dealloc
{
    [_aim release];
    [_altEmail release];
    [_company release];
    [_email release];
    [_firstName release];
    [_google release];
    [_lastName release];
    [_mobile release];
    [_phone release];
    [_skype release];
    [_title release];
    [_username release];
    [_yahoo release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
