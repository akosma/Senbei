//
//  SBRootController.m
//  Senbei
//
//  Created by Adrian on 2/20/10.
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

#import "SBRootController.h"
#import "Definitions.h"
#import "SBHelpers.h"
#import "SBModels.h"
#import "SBListController.h"
#import "SBSettingsController.h"
#import "SBTasksController.h"
#import "SBCommentsController.h"
#import "SBWebBrowserController.h"

typedef enum {
    SBViewControllerTasks = 0,
    SBViewControllerAccounts = 1,
    SBViewControllerContacts = 2,
    SBViewControllerSettings = 3,
    SBViewControllerOpportunities = 4,
    SBViewControllerLeads = 5,
    SBViewControllerCampaigns = 6,
    SBViewControllerMore = 7
} SBViewController;

NSString *getValueForPropertyFromPerson(ABRecordRef person, ABPropertyID property, ABMultiValueIdentifier identifierForValue)
{
    ABMultiValueRef items = ABRecordCopyValue(person, property);
    NSString *value = (NSString *)ABMultiValueCopyValueAtIndex(items, identifierForValue);
    CFRelease(items);
    return [value autorelease];
}

@interface SBRootController ()

@property (nonatomic, retain) SBCommentsController *commentsController;

@end


@implementation SBRootController

@synthesize accountsController = _accountsController;
@synthesize contactsController = _contactsController;
@synthesize opportunitiesController = _opportunitiesController;
@synthesize leadsController = _leadsController;
@synthesize campaignsController = _campaignsController;
@synthesize settingsController = _settingsController;
@synthesize tasksController = _tasksController;
@synthesize commentsController = _commentsController;

- (void)dealloc 
{
    [_accountsController release];
    [_contactsController release];
    [_opportunitiesController release];
    [_leadsController release];
    [_campaignsController release];
    [_settingsController release];
    [_tasksController release];
    [_commentsController release];
    [super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.delegate = self;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self.accountsController 
               selector:@selector(didReceiveData:) 
                   name:FatFreeCRMProxyDidRetrieveAccountsNotification
                 object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    self.accountsController.listedClass = [SBCompanyAccount class];
    
    [center addObserver:self.opportunitiesController 
               selector:@selector(didReceiveData:) 
                   name:FatFreeCRMProxyDidRetrieveOpportunitiesNotification
                 object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    self.opportunitiesController.listedClass = [SBOpportunity class];
    
    [center addObserver:self.contactsController 
               selector:@selector(didReceiveData:) 
                   name:FatFreeCRMProxyDidRetrieveContactsNotification
                 object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    self.contactsController.listedClass = [SBContact class];
    self.contactsController.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    [center addObserver:self.campaignsController
               selector:@selector(didReceiveData:)
                   name:FatFreeCRMProxyDidRetrieveCampaignsNotification
                 object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    self.campaignsController.listedClass = [SBCampaign class];
    
    [center addObserver:self.leadsController
               selector:@selector(didReceiveData:)
                   name:FatFreeCRMProxyDidRetrieveLeadsNotification
                 object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    self.leadsController.listedClass = [SBLead class];
    
    self.leadsController.tabBarItem.image = [UIImage imageNamed:@"leads.png"];
    self.contactsController.tabBarItem.image = [UIImage imageNamed:@"contacts.png"];
    self.campaignsController.tabBarItem.image = [UIImage imageNamed:@"campaigns.png"];
    self.tasksController.tabBarItem.image = [UIImage imageNamed:@"tasks.png"];
    self.accountsController.tabBarItem.image = [UIImage imageNamed:@"accounts.png"];
    self.opportunitiesController.tabBarItem.image = [UIImage imageNamed:@"opportunities.png"];

    // Restore the order of the tab bars following the preferences of the user
    NSArray *order = [SBSettingsManager sharedSBSettingsManager].tabOrder;
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:7];
    if (order == nil)
    {
        // Probably first run, or never reordered controllers
        [controllers addObject:self.tasksController.navigationController];
        [controllers addObject:self.accountsController.navigationController];
        [controllers addObject:self.contactsController.navigationController];
        [controllers addObject:self.settingsController.navigationController];
        [controllers addObject:self.opportunitiesController.navigationController];
        [controllers addObject:self.leadsController.navigationController];
        [controllers addObject:self.campaignsController.navigationController];
    }
    else 
    {
        for (id number in order)
        {
            switch ([number intValue]) 
            {
                case SBViewControllerAccounts:
                    [controllers addObject:self.accountsController.navigationController];
                    break;
                    
                case SBViewControllerCampaigns:
                    [controllers addObject:self.campaignsController.navigationController];
                    break;
                    
                case SBViewControllerContacts:
                    [controllers addObject:self.contactsController.navigationController];
                    break;
                    
                case SBViewControllerLeads:
                    [controllers addObject:self.leadsController.navigationController];
                    break;
                    
                case SBViewControllerOpportunities:
                    [controllers addObject:self.opportunitiesController.navigationController];
                    break;
                    
                case SBViewControllerSettings:
                    [controllers addObject:self.settingsController.navigationController];
                    break;
                    
                case SBViewControllerTasks:
                    [controllers addObject:self.tasksController.navigationController];
                    break;

                default:
                    break;
            }
        }
    }
    
    self.viewControllers = controllers;
    [controllers release];
    
    // Jump to the last selected view controller in the tab bar
    SBViewController controllerNumber = [SBSettingsManager sharedSBSettingsManager].currentTab;
    switch (controllerNumber) 
    {
        case SBViewControllerAccounts:
            self.selectedViewController = self.accountsController.navigationController;
            break;
            
        case SBViewControllerCampaigns:
            self.selectedViewController = self.campaignsController.navigationController;
            break;
            
        case SBViewControllerContacts:
            self.selectedViewController = self.contactsController.navigationController;
            break;
            
        case SBViewControllerLeads:
            self.selectedViewController = self.leadsController.navigationController;
            break;
            
        case SBViewControllerOpportunities:
            self.selectedViewController = self.opportunitiesController.navigationController;
            break;
            
        case SBViewControllerSettings:
            self.selectedViewController = self.settingsController.navigationController;
            break;
            
        case SBViewControllerTasks:
            self.selectedViewController = self.tasksController.navigationController;
            break;
            
        case SBViewControllerMore:
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

#pragma mark - UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController 
 didSelectViewController:(UIViewController *)viewController
{
    SBSettingsManager *settings = [SBSettingsManager sharedSBSettingsManager];
    if (viewController == self.accountsController.navigationController)
    {
        settings.currentTab = SBViewControllerAccounts;
    }
    else if (viewController == self.contactsController.navigationController)
    {
        settings.currentTab = SBViewControllerContacts;
    }
    else if (viewController == self.opportunitiesController.navigationController)
    {
        settings.currentTab = SBViewControllerOpportunities;
    }
    else if (viewController == self.tasksController.navigationController)
    {
        settings.currentTab = SBViewControllerTasks;
    }
    else if (viewController == self.leadsController.navigationController)
    {
        settings.currentTab = SBViewControllerLeads;
    }
    else if (viewController == self.campaignsController.navigationController)
    {
        settings.currentTab = SBViewControllerCampaigns;
    }
    else if (viewController == self.settingsController.navigationController)
    {
        settings.currentTab = SBViewControllerSettings;
    }
    else if (viewController == self.moreNavigationController)
    {
        settings.currentTab = SBViewControllerMore;
    }
}

-         (void)tabBarController:(UITabBarController *)tabBarController 
didEndCustomizingViewControllers:(NSArray *)viewControllers 
                         changed:(BOOL)changed
{
    if (changed)
    {
        NSMutableArray *order = [NSMutableArray arrayWithCapacity:7];
        for (id controller in viewControllers)
        {
            if (controller == self.accountsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SBViewControllerAccounts]];
            }
            else if (controller == self.contactsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SBViewControllerContacts]];
            }
            else if (controller == self.opportunitiesController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SBViewControllerOpportunities]];
            }
            else if (controller == self.tasksController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SBViewControllerTasks]];
            }
            else if (controller == self.leadsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SBViewControllerLeads]];
            }
            else if (controller == self.campaignsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SBViewControllerCampaigns]];
            }
            else if (controller == self.settingsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SBViewControllerSettings]];
            }
        }
        [SBSettingsManager sharedSBSettingsManager].tabOrder = order;
    }
}

#pragma mark - BaseListControllerDelegate methods

- (void)listController:(SBListController *)controller didSelectEntity:(SBBaseEntity *)entity
{
    if (controller == self.contactsController)
    {
        ABPersonViewController *personController = [[ABPersonViewController alloc] init];
        SBContact *contact = (SBContact *)entity;
        ABRecordRef person = [contact getPerson];
        personController.displayedPerson = person;
        personController.displayedProperties = [SBContact displayedProperties];
        personController.personViewDelegate = self;
        [controller.navigationController pushViewController:personController animated:YES];
        [personController release];
    }
    else
    {
        if (self.commentsController == nil)
        {
            self.commentsController = [[[SBCommentsController alloc] init] autorelease];
        }
        self.commentsController.entity = entity;
        [controller.navigationController pushViewController:self.commentsController
                                                   animated:YES];
    }
}

- (void)listController:(SBListController *)controller didTapAccessoryForEntity:(SBBaseEntity *)entity
{
    if (controller == self.contactsController)
    {
        if (self.commentsController == nil)
        {
            self.commentsController = [[[SBCommentsController alloc] init] autorelease];
        }
        self.commentsController.entity = entity;
        [controller.navigationController pushViewController:self.commentsController animated:YES];
    }
}

#pragma mark - ABPersonViewControllerDelegate methods

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
        SBWebBrowserController *webController = [[SBWebBrowserController alloc] init];
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

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)err
{
    [controller dismissModalViewControllerAnimated:YES];
}

@end
