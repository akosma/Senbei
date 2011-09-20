//
//  SBCompanyAccount.m
//  Senbei
//
//  Created by Adrian on 1/20/10.
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

#import "SBCompanyAccount.h"

@implementation SBCompanyAccount

@synthesize billingAddress = _billingAddress;
@synthesize fax = _fax;
@synthesize phone = _phone;
@synthesize shippingAddress = _shippingAddress;
@synthesize tollFreePhone = _tollFreePhone;
@synthesize website = _website;

+ (NSString *)serverPath
{
    return @"accounts";
}

- (id)initWithTBXMLElement:(TBXMLElement *)element
{
    if (self = [super initWithTBXMLElement:element])
    {
        self.billingAddress = [SBBaseEntity stringValueForElement:@"billing-address" parentElement:element];
        self.fax = [SBBaseEntity stringValueForElement:@"fax" parentElement:element];
        self.phone = [SBBaseEntity stringValueForElement:@"phone" parentElement:element];
        self.shippingAddress = [SBBaseEntity stringValueForElement:@"shipping-address" parentElement:element];
        self.tollFreePhone = [SBBaseEntity stringValueForElement:@"toll-free-phone" parentElement:element];
        self.website = [SBBaseEntity stringValueForElement:@"website" parentElement:element];
    }
    return self;
}

- (void)dealloc
{
    self.billingAddress = nil;
    self.fax = nil;
    self.phone = nil;
    self.shippingAddress = nil;
    self.tollFreePhone = nil;
    self.website = nil;
    [super dealloc];
}

- (NSString *)description
{
    return self.website;
}

#pragma mark - Overridable properties

- (NSString *)commentableTypeName
{
    return @"Account";
}

@end
