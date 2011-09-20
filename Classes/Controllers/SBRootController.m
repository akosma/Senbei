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
#import "FatFreeCRMProxy.h"
#import "SBListController.h"
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
#import "SettingsManager.h"

NSString *getValueForPropertyFromPerson(ABRecordRef person, ABPropertyID property, ABMultiValueIdentifier identifierForValue)
{
    ABMultiValueRef items = ABRecordCopyValue(person, property);
    NSString *value = (NSString *)ABMultiValueCopyValueAtIndex(items, identifierForValue);
    CFRelease(items);
    return [value autorelease];
}

@interface SBRootController ()

@property (nonatomic, retain) CommentsController *commentsController;

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
    self.accountsController.listedClass = [CompanyAccount class];
    
    [center addObserver:self.opportunitiesController 
               selector:@selector(didReceiveData:) 
                   name:FatFreeCRMProxyDidRetrieveOpportunitiesNotification
                 object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    self.opportunitiesController.listedClass = [Opportunity class];
    
    [center addObserver:self.contactsController 
               selector:@selector(didReceiveData:) 
                   name:FatFreeCRMProxyDidRetrieveContactsNotification
                 object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    self.contactsController.listedClass = [Contact class];
    self.contactsController.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    [center addObserver:self.campaignsController
               selector:@selector(didReceiveData:)
                   name:FatFreeCRMProxyDidRetrieveCampaignsNotification
                 object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    self.campaignsController.listedClass = [Campaign class];
    
    [center addObserver:self.leadsController
               selector:@selector(didReceiveData:)
                   name:FatFreeCRMProxyDidRetrieveLeadsNotification
                 object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
    self.leadsController.listedClass = [Lead class];
    
    self.leadsController.tabBarItem.image = [UIImage imageNamed:@"leads.png"];
    self.contactsController.tabBarItem.image = [UIImage imageNamed:@"contacts.png"];
    self.campaignsController.tabBarItem.image = [UIImage imageNamed:@"campaigns.png"];
    self.tasksController.tabBarItem.image = [UIImage imageNamed:@"tasks.png"];
    self.accountsController.tabBarItem.image = [UIImage imageNamed:@"accounts.png"];
    self.opportunitiesController.tabBarItem.image = [UIImage imageNamed:@"opportunities.png"];

    // Restore the order of the tab bars following the preferences of the user
    NSArray *order = [SettingsManager sharedSettingsManager].tabOrder;
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
                case SenbeiViewControllerAccounts:
                    [controllers addObject:self.accountsController.navigationController];
                    break;
                    
                case SenbeiViewControllerCampaigns:
                    [controllers addObject:self.campaignsController.navigationController];
                    break;
                    
                case SenbeiViewControllerContacts:
                    [controllers addObject:self.contactsController.navigationController];
                    break;
                    
                case SenbeiViewControllerLeads:
                    [controllers addObject:self.leadsController.navigationController];
                    break;
                    
                case SenbeiViewControllerOpportunities:
                    [controllers addObject:self.opportunitiesController.navigationController];
                    break;
                    
                case SenbeiViewControllerSettings:
                    [controllers addObject:self.settingsController.navigationController];
                    break;
                    
                case SenbeiViewControllerTasks:
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
    SenbeiViewController controllerNumber = [SettingsManager sharedSettingsManager].currentTab;
    switch (controllerNumber) 
    {
        case SenbeiViewControllerAccounts:
            self.selectedViewController = self.accountsController.navigationController;
            break;
            
        case SenbeiViewControllerCampaigns:
            self.selectedViewController = self.campaignsController.navigationController;
            break;
            
        case SenbeiViewControllerContacts:
            self.selectedViewController = self.contactsController.navigationController;
            break;
            
        case SenbeiViewControllerLeads:
            self.selectedViewController = self.leadsController.navigationController;
            break;
            
        case SenbeiViewControllerOpportunities:
            self.selectedViewController = self.opportunitiesController.navigationController;
            break;
            
        case SenbeiViewControllerSettings:
            self.selectedViewController = self.settingsController.navigationController;
            break;
            
        case SenbeiViewControllerTasks:
            self.selectedViewController = self.tasksController.navigationController;
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
    SettingsManager *settings = [SettingsManager sharedSettingsManager];
    if (viewController == self.accountsController.navigationController)
    {
        settings.currentTab = SenbeiViewControllerAccounts;
    }
    else if (viewController == self.contactsController.navigationController)
    {
        settings.currentTab = SenbeiViewControllerContacts;
    }
    else if (viewController == self.opportunitiesController.navigationController)
    {
        settings.currentTab = SenbeiViewControllerOpportunities;
    }
    else if (viewController == self.tasksController.navigationController)
    {
        settings.currentTab = SenbeiViewControllerTasks;
    }
    else if (viewController == self.leadsController.navigationController)
    {
        settings.currentTab = SenbeiViewControllerLeads;
    }
    else if (viewController == self.campaignsController.navigationController)
    {
        settings.currentTab = SenbeiViewControllerCampaigns;
    }
    else if (viewController == self.settingsController.navigationController)
    {
        settings.currentTab = SenbeiViewControllerSettings;
    }
    else if (viewController == self.moreNavigationController)
    {
        settings.currentTab = SenbeiViewControllerMore;
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
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerAccounts]];
            }
            else if (controller == self.contactsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerContacts]];
            }
            else if (controller == self.opportunitiesController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerOpportunities]];
            }
            else if (controller == self.tasksController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerTasks]];
            }
            else if (controller == self.leadsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerLeads]];
            }
            else if (controller == self.campaignsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerCampaigns]];
            }
            else if (controller == self.settingsController.navigationController)
            {
                [order addObject:[NSNumber numberWithInt:SenbeiViewControllerSettings]];
            }
        }
        [SettingsManager sharedSettingsManager].tabOrder = order;
    }
}

#pragma mark -
#pragma mark BaseListControllerDelegate methods

- (void)listController:(SBListController *)controller didSelectEntity:(BaseEntity *)entity
{
    if (controller == self.contactsController)
    {
        ABPersonViewController *personController = [[ABPersonViewController alloc] init];
        Contact *contact = (Contact *)entity;
        ABRecordRef person = [contact getPerson];
        personController.displayedPerson = person;
        personController.displayedProperties = [Contact displayedProperties];
        personController.personViewDelegate = self;
        [controller.navigationController pushViewController:personController animated:YES];
        [personController release];
    }
    else
    {
        if (self.commentsController == nil)
        {
            self.commentsController = [[[CommentsController alloc] init] autorelease];
        }
        self.commentsController.entity = entity;
        [controller.navigationController pushViewController:self.commentsController
                                                   animated:YES];
    }
}

- (void)listController:(SBListController *)controller didTapAccessoryForEntity:(BaseEntity *)entity
{
    if (controller == self.contactsController)
    {
        if (self.commentsController == nil)
        {
            self.commentsController = [[[CommentsController alloc] init] autorelease];
        }
        self.commentsController.entity = entity;
        [controller.navigationController pushViewController:self.commentsController animated:YES];
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
