//
//  Contact.m
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

#import "Contact.h"
#import "NSDate+Senbei.h"
#import "NSString+Senbei.h"
#import "NSURL+AKOCacheKey.h"
#import "Definitions.h"
#import "AKOImageCache.h"

void setPersonPropertyValue(ABRecordRef person, ABPropertyID property, CFStringRef label, NSString *value)
{
    if (value != nil && ![value isEqualToString:@""])
    {
        ABMutableMultiValueRef items = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        CFIndex index = ABMultiValueGetCount(items);
        ABMultiValueInsertValueAndLabelAtIndex(items, (CFStringRef)value, label, index, nil);
        ABRecordSetValue(person, property, items, nil);
        CFRelease(items);
    }
}

@implementation Contact

@synthesize address = _address;
@synthesize altEmail = _altEmail;
@synthesize blog = _blog;
@synthesize department = _department;
@synthesize email = _email;
@synthesize facebook = _facebook;
@synthesize fax = _fax;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize linkedIn = _linkedIn;
@synthesize mobile = _mobile;
@synthesize phone = _phone;
@synthesize source = _source;
@synthesize title = _title;
@synthesize twitter = _twitter;
@synthesize birthDate = _birthDate;
@synthesize doNotCall = _doNotCall;

#pragma mark -
#pragma mark Static methods

+ (NSString *)serverPath
{
    return @"contacts";
}

+ (NSArray *)displayedProperties
{
    static NSArray *properties;
    if (properties == nil)
    {
        properties = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:kABPersonFirstNameProperty],
                      [NSNumber numberWithInt:kABPersonLastNameProperty], 
                      [NSNumber numberWithInt:kABPersonJobTitleProperty],
                      [NSNumber numberWithInt:kABPersonDepartmentProperty],
                      [NSNumber numberWithInt:kABPersonBirthdayProperty],
                      [NSNumber numberWithInt:kABPersonPhoneProperty],
                      [NSNumber numberWithInt:kABPersonURLProperty],
                      [NSNumber numberWithInt:kABPersonEmailProperty],
                      nil];
    }
    return properties;
}

#pragma mark -
#pragma mark Init and dealloc

- (id)initWithTBXMLElement:(TBXMLElement *)element
{
    if (self = [super initWithTBXMLElement:element])
    {
        self.photoURL = nil;
        self.address = [BaseEntity stringValueForElement:@"address" parentElement:element];
        self.altEmail = [BaseEntity stringValueForElement:@"alt-email" parentElement:element];
        self.blog = [BaseEntity stringValueForElement:@"blog" parentElement:element];
        self.birthDate = [self.formatter dateFromString:[BaseEntity stringValueForElement:@"born-on" 
                                                                            parentElement:element]];
        self.department = [BaseEntity stringValueForElement:@"department" parentElement:element];
        self.doNotCall = [[BaseEntity stringValueForElement:@"do-not-call" parentElement:element] isEqualToString:@"true"];
        self.email = [BaseEntity stringValueForElement:@"email" parentElement:element];
        self.facebook = [BaseEntity stringValueForElement:@"facebook" parentElement:element];
        self.fax = [BaseEntity stringValueForElement:@"fax" parentElement:element];
        self.firstName = [BaseEntity stringValueForElement:@"first-name" parentElement:element];
        self.lastName = [BaseEntity stringValueForElement:@"last-name" parentElement:element];
        self.linkedIn = [BaseEntity stringValueForElement:@"linkedin" parentElement:element];
        self.mobile = [BaseEntity stringValueForElement:@"mobile" parentElement:element];
        self.phone = [BaseEntity stringValueForElement:@"phone" parentElement:element];
        self.source = [BaseEntity stringValueForElement:@"source" parentElement:element];
        self.title = [BaseEntity stringValueForElement:@"title" parentElement:element];
        self.twitter = [BaseEntity stringValueForElement:@"twitter" parentElement:element];
        
        NSString *serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_SERVER_URL];
        NSString *defaultImage = [NSString stringWithFormat:@"%@/images/avatar.jpg", serverURL];
        self.photoURL = [[[NSURL alloc] initWithString:defaultImage] autorelease];
        
        if (self.email != nil)
        {
            NSString *emailHash = [self.email md5];
            NSString *base = @"http://www.gravatar.com/avatar";
            defaultImage = [self.photoURL cacheKey];
            NSString *stringURL = [NSString stringWithFormat:@"%@/%@.png?d=%@&s=50", base, emailHash, defaultImage];
            self.photoURL = [[[NSURL alloc] initWithString:stringURL] autorelease];
        }        
    }
    return self;
}

- (void)dealloc
{
    self.photoURL = nil;
    self.address = nil;
    self.altEmail = nil;
    self.blog = nil;
    self.department = nil;
    self.email = nil;
    self.facebook = nil;
    self.fax = nil;
    self.firstName = nil;
    self.lastName = nil;
    self.linkedIn = nil;
    self.mobile = nil;
    self.phone = nil;
    self.source = nil;
    self.title = nil;
    self.twitter = nil;
    self.birthDate = nil;
    if (_person != NULL)
    {
        CFRelease(_person);
    }
    [super dealloc];
}

#pragma mark -
#pragma mark Overridden methods

- (NSString *)description
{
    NSMutableString *result = [[NSMutableString alloc] init];
    if ([self.title length] > 0)
    {
        [result appendString:self.title];
    }
    if ([self.department length] > 0)
    {
        if ([result length] > 0)
        {
            [result appendString:@" - "];
        }
        [result appendString:self.department];
    }
    if ([self.phone length] > 0)
    {
        if ([result length] > 0)
        {
            [result appendString:@" - "];
        }
        [result appendString:self.phone];
    }
    if ([self.email length] > 0)
    {
        if ([result length] > 0)
        {
            [result appendString:@" - "];
        }
        [result appendString:self.email];
    }
    
    return [result autorelease];
}

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

#pragma mark -
#pragma mark Dynamic properties

- (ABRecordRef)getPerson
{
    if (_person == NULL)
    {
        _person = ABPersonCreate();
        ABRecordSetValue(_person, kABPersonFirstNameProperty, self.firstName, nil);
        ABRecordSetValue(_person, kABPersonLastNameProperty, self.lastName, nil);
        
        if ([self.title length] > 0)
        {
            ABRecordSetValue(_person, kABPersonJobTitleProperty, self.title, nil);
        }
        
        if ([self.department length] > 0)
        {
            ABRecordSetValue(_person, kABPersonDepartmentProperty, self.department, nil);
        }
        
        ABRecordSetValue(_person, kABPersonBirthdayProperty, [self.birthDate stringWithDateFormattedWithCurrentLocale], nil);
        
        setPersonPropertyValue(_person, kABPersonPhoneProperty, kABPersonPhoneMobileLabel, self.mobile);
        setPersonPropertyValue(_person, kABPersonPhoneProperty, kABPersonPhoneMainLabel, self.phone);
        setPersonPropertyValue(_person, kABPersonPhoneProperty, kABPersonPhoneWorkFAXLabel, self.fax);
        setPersonPropertyValue(_person, kABPersonURLProperty, kABPersonHomePageLabel, self.blog);
        setPersonPropertyValue(_person, kABPersonEmailProperty, kABWorkLabel, self.email);
        setPersonPropertyValue(_person, kABPersonEmailProperty, kABHomeLabel, self.altEmail);

        NSString *key = [self.photoURL cacheKey];
        UIImage *image = [[AKOImageCache sharedAKOImageCache] imageForKey:key];
        if (image != nil)
        {
            NSData *data = UIImagePNGRepresentation(image);
            CFDataRef cfdata = (CFDataRef)data;
            CFErrorRef error;
            ABPersonSetImageData(_person, cfdata, &error);
        }
    }

    return _person;
}

@end
