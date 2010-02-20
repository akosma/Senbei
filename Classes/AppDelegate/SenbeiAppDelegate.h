//
//  SenbeiAppDelegate.h
//  Senbei
//
//  Created by Adrian on 1/19/10.
//  Copyright akosma software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootController;
@class User;

@interface SenbeiAppDelegate : NSObject <UIApplicationDelegate>
{
@private
    IBOutlet UIWindow *_window;
    IBOutlet RootController *_tabBarController;
    IBOutlet UIActivityIndicatorView *_spinningWheel;
    IBOutlet UILabel *_statusLabel;
    IBOutlet UIView *_applicationCredits;
    User *_currentUser;
}

@property (nonatomic, readonly) User *currentUser;

+ (SenbeiAppDelegate *)sharedAppDelegate;

@end

