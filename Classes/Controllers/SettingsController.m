//
//  SettingsController.m
//  Saccharin
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "SettingsController.h"
#import "Definitions.h"
#import "FatFreeCRMProxy.h"

@implementation SettingsController

@synthesize navigationController = _navigationController;

#pragma mark -
#pragma mark Init and dealloc

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithNibName:@"IASKAppSettingsView" bundle:nil]) 
    {
        self.showDoneButton = NO;
        self.showCreditsFooter = NO;
        _navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        self.title = @"Settings";
        self.tabBarItem.image = [UIImage imageNamed:@"settings.png"];
        
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
    }
    return self;
}

- (void)dealloc 
{
    [_navigationController release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

@end
