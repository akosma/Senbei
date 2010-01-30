//
//  Task.h
//  Saccharin
//
//  Created by Adrian on 1/21/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEntity.h"

@interface Task : BaseEntity
{
@private
    NSDate *_dueDate;
    NSString *_category;
    NSString *_bucket;
}

@property (nonatomic, retain) NSDate *dueDate;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *bucket;

- (id)initWithCXMLElement:(CXMLElement *)element;

@end
