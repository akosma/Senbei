//
//  User.h
//  Senbei
//
//  Created by Adrian on 1/21/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEntity.h"

@interface User : BaseEntity 
{
@private
    BOOL _admin;
    NSString *_aim;
    NSString *_altEmail;
    NSString *_company;
    NSString *_email;
    NSString *_firstName;
    NSString *_google;
    NSString *_lastName;
    NSString *_mobile;
    NSString *_phone;
    NSString *_skype;
    NSString *_title;
    NSString *_username;
    NSString *_yahoo;
}

@property (nonatomic) BOOL admin;
@property (nonatomic, copy) NSString *aim;
@property (nonatomic, copy) NSString *altEmail;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *google;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *skype;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *yahoo;

- (id)initWithCXMLElement:(CXMLElement *)element;

@end
