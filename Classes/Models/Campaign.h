//
//  Campaign.h
//  Senbei
//
//  Created by Adrian on 1/21/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEntity.h"

@interface Campaign : BaseEntity 
{
@private
    double _budget;
    NSDate *_endsOn;
    NSInteger _leadsCount;
    NSString *_objectives;
    NSInteger _opportunitiesCount;
    double _revenue;
    NSDate *_startsOn;
    NSString *_status;
    float _conversionTarget;
    NSInteger _leadsTarget;
    double _revenueTarget;
}

@property (nonatomic) double budget;
@property (nonatomic, retain) NSDate *endsOn;
@property (nonatomic) NSInteger leadsCount;
@property (nonatomic, copy) NSString *objectives;
@property (nonatomic) NSInteger opportunitiesCount;
@property (nonatomic) double revenue;
@property (nonatomic, retain) NSDate *startsOn;
@property (nonatomic, copy) NSString *status;
@property (nonatomic) float conversionTarget;
@property (nonatomic) NSInteger leadsTarget;
@property (nonatomic) double revenueTarget;

+ (NSString *)serverPath;
- (id)initWithCXMLElement:(CXMLElement *)element;

@end
