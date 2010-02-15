//
//  Contact.h
//  Senbei
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "BaseEntity.h"

@interface Contact : BaseEntity 
{
@private
    NSString *_address;
    NSString *_altEmail;
    NSString *_blog;
    NSString *_department;
    NSString *_email;
    NSString *_facebook;
    NSString *_fax;
    NSString *_firstName;
    NSString *_lastName;
    NSString *_linkedIn;
    NSString *_mobile;
    NSString *_phone;
    NSString *_source;
    NSString *_title;
    NSString *_twitter;
    NSDate *_birthDate;
    BOOL _doNotCall;
    
    NSURL *_photoURL;
}

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *altEmail;
@property (nonatomic, copy) NSString *blog;
@property (nonatomic, copy) NSString *department;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *facebook;
@property (nonatomic, copy) NSString *fax;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *linkedIn;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *twitter;
@property (nonatomic, retain) NSDate *birthDate;
@property (nonatomic) BOOL doNotCall;
@property (nonatomic, readonly) ABRecordRef person;

+ (NSString *)serverPath;
+ (NSArray *)displayedProperties;

- (id)initWithCXMLElement:(CXMLElement *)element;

@end
