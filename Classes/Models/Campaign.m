//
//  Campaign.m
//  Saccharin
//
//  Created by Adrian on 1/21/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "Campaign.h"

@implementation Campaign

@synthesize budget = _budget;
@synthesize endsOn = _endsOn;
@synthesize leadsCount = _leadsCount;
@synthesize objectives = _objectives;
@synthesize opportunitiesCount = _opportunitiesCount;
@synthesize revenue = _revenue;
@synthesize startsOn = _startsOn;
@synthesize status = _status;
@synthesize conversionTarget = _conversionTarget;
@synthesize leadsTarget = _leadsTarget;
@synthesize revenueTarget = _revenueTarget;

+ (NSString *)serverPath
{
    return @"campaigns";
}

- (id)initWithCXMLElement:(CXMLElement *)element
{
    if (self = [super initWithCXMLElement:element])
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        for(int counter = 0; counter < [element childCount]; ++counter) 
        {
            id obj = [element childAtIndex:counter];
            NSString *nodeName = [obj name];
            if ([nodeName isEqualToString:@"budget"])
            {
                _budget = [[obj stringValue] doubleValue];
            }
            else if ([nodeName isEqualToString:@"ends-on"])
            {
                if ([obj stringValue] != nil)
                {
                    _endsOn = [[formatter dateFromString:[obj stringValue]] retain];
                }
            }
            else if ([nodeName isEqualToString:@"leads-count"])
            {
                _leadsCount = [[obj stringValue] intValue];
            }
            else if ([nodeName isEqualToString:@"objectives"])
            {
                _objectives = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"opportunities-count"])
            {
                _opportunitiesCount = [[obj stringValue] intValue];
            }
            else if ([nodeName isEqualToString:@"revenue"])
            {
                _revenue = [[obj stringValue] doubleValue];
            }
            else if ([nodeName isEqualToString:@"starts-on"])
            {
                if ([obj stringValue] != nil)
                {
                    _startsOn = [[formatter dateFromString:[obj stringValue]] retain];
                }
            }
            else if ([nodeName isEqualToString:@"status"])
            {
                _status = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"target-conversion"])
            {
                _conversionTarget = [[obj stringValue] floatValue];
            }
            else if ([nodeName isEqualToString:@"target-leads"])
            {
                _leadsTarget = [[obj stringValue] intValue];
            }
            else if ([nodeName isEqualToString:@"target-revenue"])
            {
                _revenueTarget = [[obj stringValue] doubleValue];
            }
        }
        [formatter release];
    }
    return self;
}

- (void)dealloc
{
    [_endsOn release];
    [_objectives release];
    [_startsOn release];
    [_status release];
    [super dealloc];
}

- (NSString *)description
{
    return _status;
}

@end
