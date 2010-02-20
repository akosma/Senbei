//
//  SenbeiAppDelegate.m
//  Senbei
//
//  Created by Adrian on 1/19/10.
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

#import "SenbeiAppDelegate.h"
#import "FatFreeCRMProxy.h"
#import "Definitions.h"
#import "AKOImageCache.h"
#import "Reachability.h"
#import "RootController.h"

@implementation SenbeiAppDelegate

@synthesize currentUser = _currentUser;

- (void)dealloc 
{
    [_currentUser release];
    [super dealloc];
}

#pragma mark -
#pragma mark Static methods

+ (SenbeiAppDelegate *)sharedAppDelegate
{
    return (SenbeiAppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark -
#pragma mark UIApplicationDelegate methods

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
#if TARGET_IPHONE_SIMULATOR
    [[AKOImageCache sharedAKOImageCache] removeAllImages];
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didLogin:) 
                                                 name:FatFreeCRMProxyDidLoginNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didFailWithError:) 
                                                 name:FatFreeCRMProxyDidFailWithErrorNotification 
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didFailLogin:) 
                                                 name:FatFreeCRMProxyDidFailLoginNotification 
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    
    // Set some defaults for the first run of the application
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults stringForKey:PREFERENCES_SERVER_URL] == nil)
    {
        [defaults setObject:@"http://demo.fatfreecrm.com" forKey:PREFERENCES_SERVER_URL];
    }
    if ([defaults stringForKey:PREFERENCES_USERNAME] == nil || [defaults stringForKey:PREFERENCES_PASSWORD] == nil)
    {
        // Use a random username from those used in the Fat Free CRM wiki
        // http://wiki.github.com/michaeldv/fat_free_crm/loading-demo-data
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DemoLogins" ofType:@"plist"];
        NSArray *usernames = [NSArray arrayWithContentsOfFile:path];
        NSInteger index = floor(arc4random() % [usernames count]);
        NSString *username = [usernames objectAtIndex:index];
        [defaults setObject:username forKey:PREFERENCES_USERNAME];
        [defaults setObject:username forKey:PREFERENCES_PASSWORD];
    }
    [defaults synchronize];
    
    NSString *server = [defaults stringForKey:PREFERENCES_SERVER_URL];
    NSURL *url = [NSURL URLWithString:server];
    NSString *host = [url host];
    Reachability *reachability = [Reachability reachabilityWithHostName:host];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == NotReachable)
    {
        NSString *message = NSLocalizedString(@"NETWORK_REQUIRED", @"Message shown when the device does not have a network connection");
        NSString *ok = NSLocalizedString(@"OK", @"The 'OK' word");
        [_spinningWheel stopAnimating];
        _statusLabel.text = message;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                        message:message
                                                       delegate:nil 
                                              cancelButtonTitle:ok
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else 
    {
        NSString *username = [defaults stringForKey:PREFERENCES_USERNAME];
        NSString *password = [defaults stringForKey:PREFERENCES_PASSWORD];
        NSString *server = [defaults stringForKey:PREFERENCES_SERVER_URL];
        NSString *logging = NSLocalizedString(@"LOGGING_IN", @"Text shown while the user logs in");
        _statusLabel.text = [NSString stringWithFormat:logging, username, host];
        
        [FatFreeCRMProxy sharedFatFreeCRMProxy].username = username;
        [FatFreeCRMProxy sharedFatFreeCRMProxy].password = password;
        [FatFreeCRMProxy sharedFatFreeCRMProxy].server = server;
        [[FatFreeCRMProxy sharedFatFreeCRMProxy] login];
    }

    _applicationCredits.alpha = 0.0;
    [_window makeKeyAndVisible];
    
    [UIView beginAnimations:nil context:NULL];
    _applicationCredits.alpha = 1.0;
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark NSNotification handler methods

- (void)didFailLogin:(NSNotification *)notification
{
    [_spinningWheel stopAnimating];
    _statusLabel.text = @"Failed login";

    NSString *message = NSLocalizedString(@"CREDENTIALS_REJECTED", @"Message shown when the login credentials are rejected");
    NSString *ok = NSLocalizedString(@"OK", @"The 'OK' word");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                    message:message
                                                   delegate:nil 
                                          cancelButtonTitle:ok
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)didFailWithError:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:FatFreeCRMProxyErrorKey];
    NSString *msg = [error localizedDescription];

    [_spinningWheel stopAnimating];
    NSString *errorMessage = NSLocalizedString(@"ERROR_MESSAGE", @"Message shown when any error occurs");
    NSString *ok = NSLocalizedString(@"OK", @"The 'OK' word");
    _statusLabel.text = [NSString stringWithFormat:errorMessage, [error code]];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                    message:msg 
                                                   delegate:nil 
                                          cancelButtonTitle:ok 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)didLogin:(NSNotification *)notification
{
    _currentUser = [[[notification userInfo] objectForKey:@"user"] retain];
    _statusLabel.text = NSLocalizedString(@"LOADING_CONTROLLERS", @"Message shown when the controllers are loading");

    _tabBarController.view.alpha = 0.0;
    [_window addSubview:_tabBarController.view];
    
    [UIView beginAnimations:nil context:NULL];
    _tabBarController.view.alpha = 1.0;
    [UIView commitAnimations];
}

@end
