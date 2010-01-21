//
//  SaccharinAppDelegate.h
//  Saccharin
//
//  Created by Adrian on 1/19/10.
//  Copyright akosma software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListControllerDelegate.h"

@class SettingsController;
@class TasksController;
@class ListController;
@class CommentsController;
@class User;

@interface SaccharinAppDelegate : NSObject <UIApplicationDelegate,
                                            UITabBarControllerDelegate,
                                            ListControllerDelegate> 
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

    CommentsController *_commentsController;
    User *_currentUser;
}

@property (nonatomic, readonly) User *currentUser;

+ (SaccharinAppDelegate *)sharedAppDelegate;

@end

