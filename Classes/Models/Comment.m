//
//  Comment.m
//  Saccharin
//
//  Created by Adrian on 1/21/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@synthesize comment = _comment;

- (id)initWithCXMLElement:(CXMLElement *)element
{
    if (self = [super initWithCXMLElement:element])
    {
        for(int counter = 0; counter < [element childCount]; ++counter) 
        {
            id obj = [element childAtIndex:counter];
            NSString *nodeName = [obj name];
            if ([nodeName isEqualToString:@"comment"])
            {
                _comment = [[obj stringValue] copy];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [_comment release];
    [super dealloc];
}

@end
