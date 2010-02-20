//
//  SenbeiAppDelegate.m
//  Senbei
//
//  Created by Adrian on 1/19/10.
//  Copyright akosma software 2010. All rights reserved.
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
        NSString *logging = NSLocalizedString(@"LOGGING_IN", @"Text shown while the user logs in");
        _statusLabel.text = [NSString stringWithFormat:logging, username, host];
        
        [[FatFreeCRMProxy sharedFatFreeCRMProxy] login];
    }

    [_window makeKeyAndVisible];
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

    [_window addSubview:_tabBarController.view];
}

@end
