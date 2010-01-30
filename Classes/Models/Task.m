//
//  Task.m
//  Saccharin
//
//  Created by Adrian on 1/21/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "Task.h"

@implementation Task

@synthesize dueDate = _dueDate;
@synthesize category = _category;
@synthesize bucket = _bucket;

- (id)initWithCXMLElement:(CXMLElement *)element
{
    if (self = [super initWithCXMLElement:element])
    {
        for(int counter = 0; counter < [element childCount]; ++counter) 
        {
            id obj = [element childAtIndex:counter];
            NSString *nodeName = [obj name];
            if ([nodeName isEqualToString:@"category"])
            {
                _category = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"bucket"])
            {
                _bucket = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"due-at"])
            {
                if ([obj stringValue] != nil)
                {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                    _dueDate = [[formatter dateFromString:[obj stringValue]] retain];
                    [formatter release];
                }
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [_bucket release];
    [_dueDate release];
    [_category release];
    [super dealloc];
}

@end
