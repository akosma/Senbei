//
//  SenbeiAppDelegate.h
//  Senbei
//
//  Created by Adrian on 1/19/10.
//  Copyright akosma software 2010. All rights reserved.
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
@class User;

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

@interface SenbeiAppDelegate : NSObject <UIApplicationDelegate,
                                            UITabBarControllerDelegate,
                                            ListControllerDelegate,
                                            ABPersonViewControllerDelegate,
                                            MFMailComposeViewControllerDelegate> 
{
@private
    IBOutlet UIWindow *_window;
    IBOutlet UITabBarController *_tabBarController;
    IBOutlet ListController *_accountsController;
    IBOutlet ListController *_contactsController;
    IBOutlet ListController *_opportunitiesController;
    IBOutlet ListController *_leadsController;
    IBOutlet ListController *_campaignsController;
    IBOutlet SettingsController *_settingsController;
    IBOutlet TasksController *_tasksController;
    IBOutlet UIActivityIndicatorView *_spinningWheel;
    IBOutlet UILabel *_statusLabel;

    CommentsController *_commentsController;
    User *_currentUser;
}

@property (nonatomic, readonly) User *currentUser;

+ (SenbeiAppDelegate *)sharedAppDelegate;

@end

