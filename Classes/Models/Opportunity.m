//
//  Opportunity.m
//  Saccharin
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "Opportunity.h"

@implementation Opportunity

@synthesize amount = _amount;
@synthesize discount = _discount;
@synthesize probability = _probability;
@synthesize closingDate = _closingDate;
@synthesize source = _source;
@synthesize stage = _stage;

+ (NSString *)serverPath
{
    return @"opportunities";
}

- (id)initWithCXMLElement:(CXMLElement *)element
{
    if (self = [super initWithCXMLElement:element])
    {
        for(int counter = 0; counter < [element childCount]; ++counter) 
        {
            id obj = [element childAtIndex:counter];
            NSString *nodeName = [obj name];
            if ([nodeName isEqualToString:@"amount"])
            {
                _amount = [[obj stringValue] doubleValue];
            }
            else if ([nodeName isEqualToString:@"discount"])
            {
                _discount = [[obj stringValue] doubleValue];
            }
            else if ([nodeName isEqualToString:@"probability"])
            {
                _probability = [[obj stringValue] intValue];
            }
            else if ([nodeName isEqualToString:@"closes-on"])
            {
                if ([obj stringValue] != nil)
                {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                    _closingDate = [[formatter dateFromString:[obj stringValue]] retain];
                    [formatter release];
                }
            }
            else if ([nodeName isEqualToString:@"source"])
            {
                _source = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"stage"])
            {
                _stage = [[obj stringValue] copy];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [_closingDate release];
    [_source release];
    [_stage release];
    [super dealloc];
}

- (NSString *)description
{
    return _stage;
}

@end
