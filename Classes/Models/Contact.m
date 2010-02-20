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

@dynamic person;

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

- (id)initWithCXMLElement:(CXMLElement *)element
{
    if (self = [super initWithCXMLElement:element])
    {
        _photoURL = nil;
        for(int counter = 0; counter < [element childCount]; ++counter) 
        {
            id obj = [element childAtIndex:counter];
            NSString *nodeName = [obj name];
            if ([nodeName isEqualToString:@"address"])
            {
                _address = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"alt-email"])
            {
                _altEmail = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"blog"])
            {
                _blog = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"born-on"])
            {
                if ([obj stringValue] != nil)
                {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                    _birthDate = [[formatter dateFromString:[obj stringValue]] retain];
                    [formatter release];
                }
            }
            else if ([nodeName isEqualToString:@"department"])
            {
                _department = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"do-not-call"])
            {
                _doNotCall = [[obj stringValue] isEqualToString:@"true"];
            }
            else if ([nodeName isEqualToString:@"email"])
            {
                _email = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"facebook"])
            {
                _facebook = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"fax"])
            {
                _fax = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"first-name"])
            {
                _firstName = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"last-name"])
            {
                _lastName = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"linkedin"])
            {
                _linkedIn = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"mobile"])
            {
                _mobile = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"phone"])
            {
                _phone = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"source"])
            {
                _source = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"title"])
            {
                _title = [[obj stringValue] copy];
            }
            else if ([nodeName isEqualToString:@"twitter"])
            {
                _twitter = [[obj stringValue] copy];
            }
        }
        
        NSString *serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_SERVER_URL];
        NSString *defaultImage = [NSString stringWithFormat:@"%@/images/avatar.jpg", serverURL];
        _photoURL = [[NSURL alloc] initWithString:defaultImage];
        
        if (_email != nil)
        {
            NSString *emailHash = [_email md5];
            NSString *base = @"http://www.gravatar.com/avatar";
            defaultImage = [_photoURL cacheKey];
            NSString *stringURL = [NSString stringWithFormat:@"%@/%@.png?d=%@&s=50", base, emailHash, defaultImage];
            _photoURL = [[NSURL alloc] initWithString:stringURL];
        }        
    }
    return self;
}

- (void)dealloc
{
    [_photoURL release];
    [_address release];
    [_altEmail release];
    [_blog release];
    [_department release];
    [_email release];
    [_facebook release];
    [_fax release];
    [_firstName release];
    [_lastName release];
    [_linkedIn release];
    [_mobile release];
    [_phone release];
    [_source release];
    [_title release];
    [_twitter release];
    [_birthDate release];
    [super dealloc];
}

#pragma mark -
#pragma mark Overridden methods

- (NSString *)description
{
    NSMutableString *result = [[NSMutableString alloc] init];
    if ([_title length] > 0)
    {
        [result appendString:_title];
    }
    if ([_department length] > 0)
    {
        if ([result length] > 0)
        {
            [result appendString:@" - "];
        }
        [result appendString:_department];
    }
    if ([_phone length] > 0)
    {
        if ([result length] > 0)
        {
            [result appendString:@" - "];
        }
        [result appendString:_phone];
    }
    if ([_email length] > 0)
    {
        if ([result length] > 0)
        {
            [result appendString:@" - "];
        }
        [result appendString:_email];
    }
    
    return [result autorelease];
}

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@ %@", _firstName, _lastName];
}

#pragma mark -
#pragma mark Dynamic properties

- (ABRecordRef)person
{
    ABRecordRef person = ABPersonCreate();
    ABRecordSetValue(person, kABPersonFirstNameProperty, _firstName, nil);
    ABRecordSetValue(person, kABPersonLastNameProperty, _lastName, nil);
    ABRecordSetValue(person, kABPersonJobTitleProperty, _title, nil);
    ABRecordSetValue(person, kABPersonDepartmentProperty, _department, nil);
    
    ABRecordSetValue(person, kABPersonBirthdayProperty, [_birthDate stringWithDateFormattedWithCurrentLocale], nil);
    
    setPersonPropertyValue(person, kABPersonPhoneProperty, kABPersonPhoneMobileLabel, _mobile);
    setPersonPropertyValue(person, kABPersonPhoneProperty, kABPersonPhoneMainLabel, _phone);
    setPersonPropertyValue(person, kABPersonPhoneProperty, kABPersonPhoneWorkFAXLabel, _fax);
    setPersonPropertyValue(person, kABPersonURLProperty, kABPersonHomePageLabel, _blog);
    setPersonPropertyValue(person, kABPersonEmailProperty, kABWorkLabel, _email);
    setPersonPropertyValue(person, kABPersonEmailProperty, kABHomeLabel, _altEmail);

    NSString *key = [self.photoURL cacheKey];
    UIImage *image = [[AKOImageCache sharedAKOImageCache] imageForKey:key];
    if (image != nil)
    {
        NSData *data = UIImagePNGRepresentation(image);
        CFDataRef cfdata = (CFDataRef)data;
        CFErrorRef error;
        ABPersonSetImageData(person, cfdata, &error);
    }
    
    return person;
}

- (NSURL *)photoURL
{
    return _photoURL;
}

@end
