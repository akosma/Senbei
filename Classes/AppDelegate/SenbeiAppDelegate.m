//
//  SenbeiAppDelegate.m
//  Senbei
//
//  Created by Adrian on 1/19/10.
//  Copyright akosma software 2010. All rights reserved.
//

#import "SenbeiAppDelegate.h"
#import "ListController.h"
#import "SettingsController.h"
#import "CommentsController.h"
#import "TasksController.h"
#import "FatFreeCRMProxy.h"
#import "CompanyAccount.h"
#import "Opportunity.h"
#import "Contact.h"
#import "User.h"
#import "Campaign.h"
#import "Lead.h"
#import "WebBrowserController.h"
#import "Definitions.h"

#define TAB_ORDER_PREFERENCE @"TAB_ORDER_PREFERENCE"
#define CURRENT_TAB_PREFERENCE @"CURRENT_TAB_PREFERENCE"

NSString *getValueForPropertyFromPerson(ABRecordRef person, ABPropertyID property, ABMultiValueIdentifier identifierForValue)
{
    ABMultiValueRef items = ABRecordCopyValue(person, property);
    NSString *value = (NSString *)ABMultiValueCopyValueAtIndex(items, identifierForValue);
    CFRelease(items);
    return [value autorelease];
}

@implementation SenbeiAppDelegate

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

+ (SenbeiAppDelegate *)sharedAppDelegate
{
    return (SenbeiAppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark -
#pragma mark UIApplicationDelegate methods

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
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
    
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCES_USERNAME];
    NSString *logging = NSLocalizedString(@"LOGGING_IN", @"Text shown while the user logs in");
    _statusLabel.text = [NSString stringWithFormat:logging, username];

    [[FatFreeCRMProxy sharedFatFreeCRMProxy] login];

    [_window makeKeyAndVisible];
}

#pragma mark -
#pragma mark NSNotification handler methods

- (void)didFailLogin:(NSNotification *)notification
{
    [_spinningWheel stopAnimating];
    _statusLabel.text = @"Failed login";

    NSString *message = NSLocalizedString(@"CREDENTIALS_REJECTED", @"Message shown when the login credentials are rejected");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                    message:message
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
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

    [[NSNotificationCenter defaultCenter] addObserver:_accountsController 
                                             selector:@selector(didReceiveData:) 
                                                 name:FatFreeCRMProxyDidRetrieveAccountsNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    _accountsController.listedClass = [CompanyAccount class];
    
    [[NSNotificationCenter defaultCenter] addObserver:_opportunitiesController 
                                             selector:@selector(didReceiveData:) 
                                                 name:FatFreeCRMProxyDidRetrieveOpportunitiesNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    _opportunitiesController.listedClass = [Opportunity class];
    
    [[NSNotificationCenter defaultCenter] addObserver:_contactsController 
                                             selector:@selector(didReceiveData:) 
                                                 name:FatFreeCRMProxyDidRetrieveContactsNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    _contactsController.listedClass = [Contact class];
    _contactsController.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

    [[NSNotificationCenter defaultCenter] addObserver:_campaignsController
                                             selector:@selector(didReceiveData:)
                                                 name:FatFreeCRMProxyDidRetrieveCampaignsNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    _campaignsController.listedClass = [Campaign class];

    [[NSNotificationCenter defaultCenter] addObserver:_leadsController
                                             selector:@selector(didReceiveData:)
                                                 name:FatFreeCRMProxyDidRetrieveLeadsNotification
                                               object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    _leadsController.listedClass = [Lead class];
    
    _leadsController.tabBarItem.image = [UIImage imageNamed:@"leads.png"];
    _contactsController.tabBarItem.image = [UIImage imageNamed:@"contacts.png"];
    _campaignsController.tabBarItem.image = [UIImage imageNamed:@"campaigns.png"];
    _tasksController.tabBarItem.image = [UIImage imageNamed:@"tasks.png"];
    _accountsController.tabBarItem.image = [UIImage imageNamed:@"accounts.png"];
    _opportunitiesController.tabBarItem.image = [UIImage imageNamed:@"opportunities.png"];
    
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
                case SenbeiViewControllerAccounts:
                    [controllers addObject:_accountsController.navigationController];
                    break;

                case SenbeiViewControllerCampaigns:
                    [controllers addObject:_campaignsController.navigationController];
                    break;

                case SenbeiViewControllerContacts:
                    [controllers addObject:_contactsController.navigationController];
                    break;

                case SenbeiViewControllerLeads:
                    [controllers addObject:_leadsController.navigationController];
                    break;

                case SenbeiViewControllerOpportunities:
                    [controllers addObject:_opportunitiesController.navigationController];
                    break;

                case SenbeiViewControllerSettings:
                    [controllers addObject:_settingsController.navigationController];
                    break;

                case SenbeiViewControllerTasks:
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
    SenbeiViewController controllerNumber = [[NSUserDefaults standardUserDefaults] integerForKey:CURRENT_TAB_PREFERENCE];
    switch (controllerNumber) 
    {
        case SenbeiViewControllerAccounts:
            _tabBarController.selectedViewController = _accountsController.navigationController;
            break;
            
        case SenbeiViewControllerCampaigns:
            _tabBarController.selectedViewController = _campaignsController.navigationController;
            break;
            
        case SenbeiViewControllerContacts:
            _tabBarController.selectedViewController = _contactsController.navigationController;
            break;
            
        case SenbeiViewControllerLeads:
            _tabBarController.selectedViewController = _leadsController.navigationController;
            break;
            
        case SenbeiViewControllerOpportunities:
            _tabBarController.selectedViewController = _opportunitiesController.navigationController;
            break;
            
        case SenbeiViewControllerSettings:
            _tabBarController.selectedViewController = _settingsController.navigationController;
            break;
            
        case SenbeiViewControllerTasks:
            _tabBarController.selectedViewController = _tasksController.navigationController;
            break;
            
        case SenbeiViewControllerMore:
            _tabBarController.selectedViewController = _tabBarController.moreNavigationController;
        default:
            break;
    }

    [_window addSubview:_tabBarController.view];
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController 
 didSelectViewController:(UIViewController *)viewController
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (viewController == _accountsController.navigationController)
    {
        [defaults setInteger:SenbeiViewControllerAccounts forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _contactsController.navigationController)
    {
        [defaults setInteger:SenbeiViewControllerContacts forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _opportunitiesController.navigationController)
    {
        [defaults setInteger:SenbeiViewControllerOpportunities forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _tasksController.navigationController)
    {
        [defaults setInteger:SenbeiViewControllerTasks forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _leadsController.navigationController)
    {
        [defaults setInteger:SenbeiViewControllerLeads forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _campaignsController.navigationController)
    {
        [defaults setInteger:SenbeiViewControllerCampaigns forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _settingsController.navigationController)
    {
        [defaults setInteger:SenbeiViewControllerSettings forKey:CURRENT_TAB_PREFERENCE];
    }
    else if (viewController == _tabBarController.moreNavigationController)
    {
        [defaults setInteger:SenbeiViewControllerMore forKey:CURRENT_TAB_PREFERENCE];
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
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerAccounts]];
            }
            else if (controller == _contactsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerContacts]];
            }
            else if (controller == _opportunitiesController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerOpportunities]];
            }
            else if (controller == _tasksController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerTasks]];
            }
            else if (controller == _leadsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerLeads]];
            }
            else if (controller == _campaignsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerCampaigns]];
            }
            else if (controller == _settingsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerSettings]];
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
    if (controller == _contactsController)
    {
        ABPersonViewController *personController = [[ABPersonViewController alloc] init];
        Contact *contact = (Contact *)entity;
        ABRecordRef person = contact.person;
        personController.displayedPerson = person;
        personController.displayedProperties = [Contact displayedProperties];
        personController.personViewDelegate = self;
        [controller.navigationController pushViewController:personController animated:YES];
        [personController release];
    }
    else
    {
        if (_commentsController == nil)
        {
            _commentsController = [[CommentsController alloc] init];
        }
        _commentsController.entity = entity;
        [controller.navigationController pushViewController:_commentsController animated:YES];
    }
}

- (void)listController:(ListController *)controller didTapAccessoryForEntity:(BaseEntity *)entity
{
    if (controller == _contactsController)
    {
        if (_commentsController == nil)
        {
            _commentsController = [[CommentsController alloc] init];
        }
        _commentsController.entity = entity;
        [controller.navigationController pushViewController:_commentsController animated:YES];
    }
}

#pragma mark -
#pragma mark ABPersonViewControllerDelegate methods

-        (BOOL)personViewController:(ABPersonViewController *)personViewController 
shouldPerformDefaultActionForPerson:(ABRecordRef)person 
                           property:(ABPropertyID)property 
                         identifier:(ABMultiValueIdentifier)identifierForValue
{
    if (property == kABPersonEmailProperty)
    {
        NSString* email = getValueForPropertyFromPerson(person, property, identifierForValue);
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
        [composer setToRecipients:[NSArray arrayWithObject:email]];

        NSString *body = NSLocalizedString(@"EMAIL_BODY", @"Body of the e-mail sent from the contacts view");
        [composer setMessageBody:body
                          isHTML:YES];                    
        
        [personViewController presentModalViewController:composer animated:YES];
        [composer release];
        return NO;
    }
    else if (property == kABPersonURLProperty)
    {
        NSString* urlString = getValueForPropertyFromPerson(person, property, identifierForValue);
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        WebBrowserController *webController = [[WebBrowserController alloc] init];
        webController.url = url;
        webController.title = urlString;
        webController.hidesBottomBarWhenPushed = YES;
        [personViewController presentModalViewController:webController animated:YES];
        [webController release];
        [url release];
        return NO;
    }

    return YES;
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)err
{
    [controller dismissModalViewControllerAnimated:YES];
}

@end
