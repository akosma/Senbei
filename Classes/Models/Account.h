//
//  Account.h
//  Saccharin
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEntity.h"

@interface Account : BaseEntity 
{
@private
    NSString *_billingAddress;
    NSString *_fax;
    NSString *_phone;
    NSString *_shippingAddress;
    NSString *_tollFreePhone;
    NSString *_website;
}

@property (nonatomic, copy) NSString *billingAddress;
@property (nonatomic, copy) NSString *fax;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *shippingAddress;
@property (nonatomic, copy) NSString *tollFreePhone;
@property (nonatomic, copy) NSString *website;

+ (NSString *)serverPath;
- (id)initWithCXMLElement:(CXMLElement *)element;

@end
