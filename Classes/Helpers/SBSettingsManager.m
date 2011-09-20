//
//  SBSettingsManager.m
//  Senbei
//
//  Created by Adrian on 7/23/10.
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

#import "SBSettingsManager.h"
#import "SynthesizeSingleton.h"

#define SETTING_SERVER @"SETTING_SERVER"
#define SETTING_USERNAME @"SETTING_USERNAME"
#define SETTING_PASSWORD @"SETTING_PASSWORD"
#define SETTING_FIRST_TIME_RUN @"SETTING_FIRST_TIME_RUN"
#define SETTING_VERSION_NUMBER @"SETTING_VERSION_NUMBER"
#define SETTING_TAB_ORDER @"SETTING_TAB_ORDER"
#define SETTING_CURRENT_TAB @"SETTING_CURRENT_TAB"
#define SETTING_USE_SELF_SIGNED_CERTIFICATE @"SETTING_USE_SELF_SIGNED_CERTIFICATE"

#define OLD_PREFERENCES_SERVER_URL @"server_url"
#define OLD_PREFERENCES_USERNAME @"username"
#define OLD_PREFERENCES_PASSWORD @"password"

@interface SBSettingsManager ()

@property (nonatomic, retain) NSUserDefaults *userDefaults;

@end

@implementation SBSettingsManager

SYNTHESIZE_SINGLETON_FOR_CLASS(SBSettingsManager)

@dynamic server;
@dynamic username;
@dynamic password;
@dynamic useSelfSignedSSLCertificates;
@dynamic versionNumber;
@dynamic tabOrder;
@dynamic currentTab;
@synthesize userDefaults = _userDefaults;

- (id)init
{
    if (self = [super init])
    {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        self.versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        NSObject *setting = [self.userDefaults objectForKey:SETTING_FIRST_TIME_RUN];
        if (setting == nil)
        {
            [self.userDefaults setObject:[NSNumber numberWithInt:10] forKey:SETTING_FIRST_TIME_RUN];
            self.useSelfSignedSSLCertificates = NO;
            self.currentTab = 0;
            
            // Migrate values from the old preferences to the new preferences keys, if required
            self.server = [self.userDefaults objectForKey:OLD_PREFERENCES_SERVER_URL];
            self.username = [self.userDefaults objectForKey:OLD_PREFERENCES_USERNAME];
            self.password = [self.userDefaults objectForKey:OLD_PREFERENCES_PASSWORD];

            // Set some defaults for the first run of the application
            if (self.server == nil)
            {
                self.server = @"http://demo.fatfreecrm.com";
            }
            if (self.username == nil || self.password == nil)
            {
                // Use a random username from those used in the Fat Free CRM wiki
                // http://wiki.github.com/michaeldv/fat_free_crm/loading-demo-data
                NSString *path = [[NSBundle mainBundle] pathForResource:@"DemoLogins" ofType:@"plist"];
                NSArray *usernames = [NSArray arrayWithContentsOfFile:path];
                NSInteger index = floor(arc4random() % [usernames count]);
                NSString *username = [usernames objectAtIndex:index];
                self.username = username;
                self.password = username;
            }
            
            [self.userDefaults synchronize];
        }
    }
    return self;
}

- (void)dealloc
{
    self.userDefaults = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (NSString *)server
{
    return [self.userDefaults stringForKey:SETTING_SERVER];
}

- (void)setServer:(NSString *)value
{
    [self.userDefaults setObject:value forKey:SETTING_SERVER];
    [self.userDefaults synchronize];
}

- (NSString *)username
{
    return [self.userDefaults stringForKey:SETTING_USERNAME];
}

- (void)setUsername:(NSString *)value
{
    [self.userDefaults setObject:value forKey:SETTING_USERNAME];
    [self.userDefaults synchronize];
}

- (NSString *)password
{
    return [self.userDefaults stringForKey:SETTING_PASSWORD];
}

- (void)setPassword:(NSString *)value
{
    [self.userDefaults setObject:value forKey:SETTING_PASSWORD];
    [self.userDefaults synchronize];
}

- (BOOL)useSelfSignedSSLCertificates
{
    return [self.userDefaults boolForKey:SETTING_USE_SELF_SIGNED_CERTIFICATE];
}

- (void)setUseSelfSignedSSLCertificates:(BOOL)value
{
    [self.userDefaults setBool:value forKey:SETTING_USE_SELF_SIGNED_CERTIFICATE];
    [self.userDefaults synchronize];
}

- (NSString *)versionNumber
{
    return [self.userDefaults stringForKey:SETTING_VERSION_NUMBER];
}

- (void)setVersionNumber:(NSString *)value
{
    [self.userDefaults setObject:value forKey:SETTING_VERSION_NUMBER];
    [self.userDefaults synchronize];
}

- (NSArray *)tabOrder
{
    return [self.userDefaults arrayForKey:SETTING_TAB_ORDER];
}

- (void)setTabOrder:(NSArray *)value
{
    [self.userDefaults setObject:value forKey:SETTING_TAB_ORDER];
    [self.userDefaults synchronize];
}

- (NSInteger)currentTab
{
    return [self.userDefaults integerForKey:SETTING_CURRENT_TAB];
}

- (void)setCurrentTab:(NSInteger)value
{
    [self.userDefaults setInteger:value forKey:SETTING_CURRENT_TAB];
    [self.userDefaults synchronize];
}

@end
