//
//  Lead.m
//  Saccharin
//
//  Created by Adrian on 1/21/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "Lead.h"

@implementation Lead

@synthesize status = _status;
@synthesize referredBy = _referredBy;

+ (NSString *)serverPath
{
    return @"leads";
}

- (id)initWithCXMLElement:(CXMLElement *)element
{
    if (self = [super initWithCXMLElement:element])
    {
        for(int counter = 0; counter < [element childCount]; ++counter) 
        {
            id obj = [element childAtIndex:counter];
            NSString *nodeName = [obj name];
            if ([nodeName isEqualToString:@"status"])
            {
                _status = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"referred-by"])
            {
                _referredBy = [[obj stringValue] copy];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [_status release];
    [_referredBy release];
    [super dealloc];
}

- (NSString *)description
{
    return _status;
}

@end
