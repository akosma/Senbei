//
//  Opportunity.h
//  Senbei
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEntity.h"

@interface Opportunity : BaseEntity 
{
@private
    double _amount;
    double _discount;
    NSInteger _probability;
    NSDate *_closingDate;
    NSString *_source;
    NSString *_stage;
}

@property (nonatomic) double amount;
@property (nonatomic) double discount;
@property (nonatomic) NSInteger probability;
@property (nonatomic, retain) NSDate *closingDate;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *stage;

+ (NSString *)serverPath;
- (id)initWithCXMLElement:(CXMLElement *)element;

@end
