//
//  Account.m
//  Senbei
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "CompanyAccount.h"

@implementation CompanyAccount

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

- (id)initWithCXMLElement:(CXMLElement *)element
{
    if (self = [super initWithCXMLElement:element])
    {
        for(int counter = 0; counter < [element childCount]; ++counter) 
        {
            id obj = [element childAtIndex:counter];
            NSString *nodeName = [obj name];
            if ([nodeName isEqualToString:@"billing-address"])
            {
                _billingAddress = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"fax"])
            {
                _fax = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"phone"])
            {
                _phone = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"shipping-address"])
            {
                _shippingAddress = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"toll-free-phone"])
            {
                _tollFreePhone = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"website"])
            {
                _website = [[obj stringValue] copy];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [_billingAddress release];
    [_fax release];
    [_phone release];
    [_shippingAddress release];
    [_tollFreePhone release];
    [_website release];
    [super dealloc];
}

- (NSString *)description
{
    return _website;
}

@end
