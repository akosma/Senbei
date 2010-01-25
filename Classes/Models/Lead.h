//
//  Lead.h
//  Saccharin
//
//  Created by Adrian on 1/21/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

@interface Lead : Contact 
{
@private
    NSString *_status;
    NSString *_referredBy;
}

@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *referredBy;

+ (NSString *)serverPath;
- (id)initWithCXMLElement:(CXMLElement *)element;

@end
