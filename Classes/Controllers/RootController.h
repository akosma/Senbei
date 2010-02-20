//
//  RootController.h
//  Senbei
//
//  Created by Adrian on 2/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ListControllerDelegate.h"

@class SettingsController;
@class TasksController;
@class ListController;
@class CommentsController;

typedef enum {
    SenbeiViewControllerAccounts = 0,
    SenbeiViewControllerContacts = 1,
    SenbeiViewControllerOpportunities = 2,
    SenbeiViewControllerTasks = 3,
    SenbeiViewControllerLeads = 4,
    SenbeiViewControllerCampaigns = 5,
    SenbeiViewControllerSettings = 6,
    SenbeiViewControllerMore = 7
} SenbeiViewController;

@interface RootController : UITabBarController <UITabBarControllerDelegate,
                                                ListControllerDelegate,
                                                ABPersonViewControllerDelegate,
                                                MFMailComposeViewControllerDelegate> 
{
@private
    IBOutlet ListController *_accountsController;
    IBOutlet ListController *_contactsController;
    IBOutlet ListController *_opportunitiesController;
    IBOutlet ListController *_leadsController;
    IBOutlet ListController *_campaignsController;
    IBOutlet SettingsController *_settingsController;
    IBOutlet TasksController *_tasksController;
    CommentsController *_commentsController;
}

@end
