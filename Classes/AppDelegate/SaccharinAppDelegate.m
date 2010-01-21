//
//  SaccharinAppDelegate.m
//  Saccharin
//
//  Created by Adrian on 1/19/10.
//  Copyright akosma software 2010. All rights reserved.
//

#import "SaccharinAppDelegate.h"
#import "ListController.h"
#import "SettingsController.h"
#import "CommentsController.h"
#import "TasksController.h"
#import "FatFreeCRMProxy.h"
#import "Account.h"
#import "Opportunity.h"
#import "Contact.h"
#import "User.h"

@implementation SaccharinAppDelegate

@synthesize currentUser = _currentUser;

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:_accountsController];
    [_commentsController release];
    [_currentUser release];
    [super dealloc];
}

#pragma mark -
#pragma mark Static methods

+ (SaccharinAppDelegate *)sharedAppDelegate
{
    return (SaccharinAppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark -
#pragma mark UIApplicationDelegate methods

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didLogin:) 
                                                 name:FatFreeCRMProxyDidLoginNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    
    [[FatFreeCRMProxy sharedFatFreeCRMProxy] login];

    [_window addSubview:_tabBarController.view];
    [_window makeKeyAndVisible];
}

#pragma mark -
#pragma mark NSNotification handler methods

- (void)didLogin:(NSNotification *)notification
{
    _currentUser = [[[notification userInfo] objectForKey:@"user"] retain];

    [[NSNotificationCenter defaultCenter] addObserver:_accountsController 
                                             selector:@selector(didReceiveAccounts:) 
                                                 name:FatFreeCRMProxyDidRetrieveAccountsNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    _accountsController.listedClass = [Account class];
    _accountsController.tabBarItem.image = [UIImage imageNamed:@"accounts.png"];
    
    [[NSNotificationCenter defaultCenter] addObserver:_opportunitiesController 
                                             selector:@selector(didReceiveAccounts:) 
                                                 name:FatFreeCRMProxyDidRetrieveOpportunitiesNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    _opportunitiesController.listedClass = [Opportunity class];
    _opportunitiesController.tabBarItem.image = [UIImage imageNamed:@"opportunities.png"];
    
    [[NSNotificationCenter defaultCenter] addObserver:_contactsController 
                                             selector:@selector(didReceiveAccounts:) 
                                                 name:FatFreeCRMProxyDidRetrieveContactsNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    _contactsController.listedClass = [Contact class];
    _contactsController.tabBarItem.image = [UIImage imageNamed:@"contacts.png"];
    
    
    _leadsController.tabBarItem.image = [UIImage imageNamed:@"leads.png"];
    _campaignsController.tabBarItem.image = [UIImage imageNamed:@"campaigns.png"];
    _tasksController.tabBarItem.image = [UIImage imageNamed:@"tasks.png"];
    
    NSArray *controllers = [[NSArray alloc] initWithObjects:_accountsController.navigationController,
                            _contactsController.navigationController,
                            _opportunitiesController.navigationController, 
                            _tasksController.navigationController,
                            _leadsController.navigationController,
                            _campaignsController.navigationController,
                            _settingsController.navigationController,
                            nil];
    _tabBarController.viewControllers = controllers;
    [controllers release];
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

-         (void)tabBarController:(UITabBarController *)tabBarController 
didEndCustomizingViewControllers:(NSArray *)viewControllers 
                         changed:(BOOL)changed
{
    
}

#pragma mark -
#pragma mark BaseListControllerDelegate methods

- (void)listController:(ListController *)controller didSelectEntity:(BaseEntity *)entity
{
    if (_commentsController == nil)
    {
        _commentsController = [[CommentsController alloc] init];
    }
    _commentsController.entity = entity;
    [controller.navigationController pushViewController:_commentsController animated:YES];
}

- (void)listController:(ListController *)controller didTapAccessoryForEntity:(BaseEntity *)entity
{
}

@end
