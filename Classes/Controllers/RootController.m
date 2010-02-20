//
//  RootController.m
//  Senbei
//
//  Created by Adrian on 2/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "RootController.h"
#import "FatFreeCRMProxy.h"
#import "ListController.h"
#import "SettingsController.h"
#import "TasksController.h"
#import "CompanyAccount.h"
#import "Opportunity.h"
#import "Contact.h"
#import "User.h"
#import "Campaign.h"
#import "Lead.h"
#import "Definitions.h"
#import "CommentsController.h"
#import "WebBrowserController.h"

#define TAB_ORDER_PREFERENCE @"TAB_ORDER_PREFERENCE"
#define CURRENT_TAB_PREFERENCE @"CURRENT_TAB_PREFERENCE"

NSString *getValueForPropertyFromPerson(ABRecordRef person, ABPropertyID property, ABMultiValueIdentifier identifierForValue)
{
    ABMultiValueRef items = ABRecordCopyValue(person, property);
    NSString *value = (NSString *)ABMultiValueCopyValueAtIndex(items, identifierForValue);
    CFRelease(items);
    return [value autorelease];
}

@implementation RootController

- (void)dealloc 
{
    [_commentsController release];
    [super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.delegate = self;

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
        [controllers addObject:_tasksController.navigationController];
        [controllers addObject:_accountsController.navigationController];
        [controllers addObject:_contactsController.navigationController];
        [controllers addObject:_settingsController.navigationController];
        [controllers addObject:_opportunitiesController.navigationController];
        [controllers addObject:_leadsController.navigationController];
        [controllers addObject:_campaignsController.navigationController];
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
    
    self.viewControllers = controllers;
    [controllers release];
    
    // Jump to the last selected view controller in the tab bar
    SenbeiViewController controllerNumber = [[NSUserDefaults standardUserDefaults] integerForKey:CURRENT_TAB_PREFERENCE];
    switch (controllerNumber) 
    {
        case SenbeiViewControllerAccounts:
            self.selectedViewController = _accountsController.navigationController;
            break;
            
        case SenbeiViewControllerCampaigns:
            self.selectedViewController = _campaignsController.navigationController;
            break;
            
        case SenbeiViewControllerContacts:
            self.selectedViewController = _contactsController.navigationController;
            break;
            
        case SenbeiViewControllerLeads:
            self.selectedViewController = _leadsController.navigationController;
            break;
            
        case SenbeiViewControllerOpportunities:
            self.selectedViewController = _opportunitiesController.navigationController;
            break;
            
        case SenbeiViewControllerSettings:
            self.selectedViewController = _settingsController.navigationController;
            break;
            
        case SenbeiViewControllerTasks:
            self.selectedViewController = _tasksController.navigationController;
            break;
            
        case SenbeiViewControllerMore:
            self.selectedViewController = self.moreNavigationController;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    else if (viewController == self.moreNavigationController)
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
