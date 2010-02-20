//
//  Contact.h
//  Senbei
//
//  Created by Adrian on 1/20/10.
//  Copyright (c) 2010, akosma software / Adrian Kosmaczewski
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. All advertising materials mentioning features or use of this software
//  must display the following acknowledgement:
//  This product includes software developed by akosma software.
//  4. Neither the name of the akosma software nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ADRIAN KOSMACZEWSKI ''AS IS'' AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL ADRIAN KOSMACZEWSKI BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
