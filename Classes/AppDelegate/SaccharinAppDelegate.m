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
#import "Campaign.h"

#define TAB_ORDER_PREFERENCE @"TAB_ORDER_PREFERENCE"
#define CURRENT_TAB_PREFERENCE @"CURRENT_TAB_PREFERENCE"

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
                                             selector:@selector(didReceiveData:) 
                                                 name:FatFreeCRMProxyDidRetrieveAccountsNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    _accountsController.listedClass = [Account class];
    _accountsController.tabBarItem.image = [UIImage imageNamed:@"accounts.png"];
    
    [[NSNotificationCenter defaultCenter] addObserver:_opportunitiesController 
                                             selector:@selector(didReceiveData:) 
                                                 name:FatFreeCRMProxyDidRetrieveOpportunitiesNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    _opportunitiesController.listedClass = [Opportunity class];
    _opportunitiesController.tabBarItem.image = [UIImage imageNamed:@"opportunities.png"];
    
    [[NSNotificationCenter defaultCenter] addObserver:_contactsController 
                                             selector:@selector(didReceiveData:) 
                                                 name:FatFreeCRMProxyDidRetrieveContactsNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    _contactsController.listedClass = [Contact class];
    _contactsController.tabBarItem.image = [UIImage imageNamed:@"contacts.png"];

    _leadsController.tabBarItem.image = [UIImage imageNamed:@"leads.png"];
    _tasksController.tabBarItem.image = [UIImage imageNamed:@"tasks.png"];
    
    [[NSNotificationCenter defaultCenter] addObserver:_campaignsController
                                             selector:@selector(didReceiveData:)
                                                 name:FatFreeCRMProxyDidRetrieveCampaignsNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    _campaignsController.listedClass = [Campaign class];
    _campaignsController.tabBarItem.image = [UIImage imageNamed:@"campaigns.png"];
    
    // Restore the order of the tab bars following the preferences of the user
    NSArray *order = [[NSUserDefaults standardUserDefaults] objectForKey:TAB_ORDER_PREFERENCE];
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:7];
    if (order == nil)
    {
        // Probably first run, or never reordered controllers
        [controllers addObject:_accountsController.navigationController];
        [controllers addObject:_contactsController.navigationController];
        [controllers addObject:_opportunitiesController.navigationController];
        [controllers addObject:_tasksController.navigationController];
        [controllers addObject:_leadsController.navigationController];
        [controllers addObject:_campaignsController.navigationController];
        [controllers addObject:_settingsController.navigationController];
    }
    else 
    {
        for (id number in order)
        {
            switch ([number intValue]) 
            {
                case SaccharinViewControllerAccounts:
                    [controllers addObject:_accountsController.navigationController];
                    break;

                case SaccharinViewControllerCampaigns:
                    [controllers addObject:_campaignsController.navigationController];
                    break;

                case SaccharinViewControllerContacts:
                    [controllers addObject:_contactsController.navigationController];
                    break;

                case SaccharinViewControllerLeads:
                    [controllers addObject:_leadsController.navigationController];
                    break;

                case SaccharinViewControllerOpportunities:
                    [controllers addObject:_opportunitiesController.navigationController];
                    break;

                case SaccharinViewControllerSettings:
                    [controllers addObject:_settingsController.navigationController];
                    break;

                case SaccharinViewControllerTasks:
                    [controllers addObject:_tasksController.navigationController];
                    break;
                default:
                    break;
            }
        }
    }

    _tabBarController.viewControllers = controllers;
    [controllers release];
    
    // Jump to the last selected view controller in the tab bar
    SaccharinViewController controllerNumber = [[NSUserDefaults standardUserDefaults] integerForKey:CURRENT_TAB_PREFERENCE];
    switch (controllerNumber) 
    {
        case SaccharinViewControllerAccounts:
            _tabBarController.selectedViewController = _accountsController.navigationController;
            break;
            
        case SaccharinViewControllerCampaigns:
            _tabBarController.selectedViewController = _campaignsController.navigationController;
            break;
            
        case SaccharinViewControllerContacts:
            _tabBarController.selectedViewController = _contactsController.navigationController;
            break;
            
        case SaccharinViewControllerLeads:
            _tabBarController.selectedViewController = _leadsController.navigationController;
            break;
            
        case SaccharinViewControllerOpportunities:
            _tabBarController.selectedViewController = _opportunitiesController.navigationController;
            break;
            
        case SaccharinViewControllerSettings:
            _tabBarController.selectedViewController = _settingsController.navigationController;
            break;
            
        case SaccharinViewControllerTasks:
            _tabBarController.selectedViewController = _tasksController.navigationController;
            break;
            
        case SaccharinViewControllerMore:
            _tabBarController.selectedViewController = _tabBarController.moreNavigationController;
        default:
            break;
    }    
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController 
 didSelectViewController:(UIViewController *)viewController
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (viewController == _accountsController.navigationController)
    {
        [defaults setInteger:SaccharinViewControllerAccounts forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _contactsController.navigationController)
    {
        [defaults setInteger:SaccharinViewControllerContacts forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _opportunitiesController.navigationController)
    {
        [defaults setInteger:SaccharinViewControllerOpportunities forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _tasksController.navigationController)
    {
        [defaults setInteger:SaccharinViewControllerTasks forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _leadsController.navigationController)
    {
        [defaults setInteger:SaccharinViewControllerLeads forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _campaignsController.navigationController)
    {
        [defaults setInteger:SaccharinViewControllerCampaigns forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _settingsController.navigationController)
    {
        [defaults setInteger:SaccharinViewControllerSettings forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _tabBarController.moreNavigationController)
    {
        [defaults setInteger:SaccharinViewControllerMore forKey:CURRENT_TAB_PREFERENCE];
    }
}

-         (void)tabBarController:(UITabBarController *)tabBarController 
didEndCustomizingViewControllers:(NSArray *)viewControllers 
                         changed:(BOOL)changed
{
    if (changed)
    {
        NSMutableArray *order = [[NSMutableArray alloc] initWithCapacity:7];
        for (id controller in viewControllers)
        {
            if (controller == _accountsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SaccharinViewControllerAccounts]];
            }
            else if (controller == _contactsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SaccharinViewControllerContacts]];
            }
            else if (controller == _opportunitiesController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SaccharinViewControllerOpportunities]];
            }
            else if (controller == _tasksController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SaccharinViewControllerTasks]];
            }
            else if (controller == _leadsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SaccharinViewControllerLeads]];
            }
            else if (controller == _campaignsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SaccharinViewControllerCampaigns]];
            }
            else if (controller == _settingsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SaccharinViewControllerSettings]];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:order forKey:TAB_ORDER_PREFERENCE];
        [order release];
    }
}

#pragma mark -
#pragma mark BaseListControllerDelegate methods

- (void)listController:(ListController *)controller didSelectEntity:(BaseEntity *)entity
{
}

- (void)listController:(ListController *)controller didTapAccessoryForEntity:(BaseEntity *)entity
{
    if (_commentsController == nil)
    {
        _commentsController = [[CommentsController alloc] init];
    }
    _commentsController.entity = entity;
    [controller.navigationController pushViewController:_commentsController animated:YES];
}

@end
