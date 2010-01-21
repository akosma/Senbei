//
//  BaseEntity.m
//  Saccharin
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "BaseEntity.h"

@implementation BaseEntity

@synthesize name = _name;
@synthesize objectId = _objectId;
@synthesize createdAt = _createdAt;
@synthesize updatedAt = _updatedAt;

- (id)initWithCXMLElement:(CXMLElement *)element
{
    if (self = [super init])
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        for(int counter = 0; counter < [element childCount]; ++counter) 
        {
            id obj = [element childAtIndex:counter];
            NSString *nodeName = [obj name];
            if ([nodeName isEqualToString:@"id"])
            {
                _objectId = [[obj stringValue] intValue];
            }
            else if ([nodeName isEqualToString:@"created-at"])
            {
                _createdAt = [[formatter dateFromString:[obj stringValue]] retain];
            }
            else if ([nodeName isEqualToString:@"updated-at"])
            {
                _updatedAt = [[formatter dateFromString:[obj stringValue]] retain];
            }
            else if ([nodeName isEqualToString:@"name"])
            {
                _name = [[obj stringValue] copy];
            }
        }
        [formatter release];
    }
    return self;
}

- (void)dealloc
{
    [_createdAt release];
    [_updatedAt release];
    [_name release];
    [super dealloc];
}

@end
