//
//  User.m
//  Saccharin
//
//  Created by Adrian on 1/21/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "User.h"

@implementation User

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

- (id)initWithCXMLElement:(CXMLElement *)element
{
    if (self = [super initWithCXMLElement:element])
    {
        for(int counter = 0; counter < [element childCount]; ++counter) 
        {
            id obj = [element childAtIndex:counter];
            NSString *nodeName = [obj name];
            if ([nodeName isEqualToString:@"admin"])
            {
                _admin = [[obj stringValue] isEqualToString:@"true"];
            }
            else if ([nodeName isEqualToString:@"alt-email"])
            {
                _altEmail = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"company"])
            {
                _company = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"email"])
            {
                _email = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"first-name"])
            {
                _firstName = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"google"])
            {
                _google = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"last-name"])
            {
                _lastName = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"mobile"])
            {
                _mobile = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"phone"])
            {
                _phone = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"skype"])
            {
                _skype = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"title"])
            {
                _title = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"username"])
            {
                _username = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"yahoo"])
            {
                _yahoo = [[obj stringValue] copy];
            }
        }
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
    return [NSString stringWithFormat:@"%@ %@", _firstName, _lastName];
}

@end
