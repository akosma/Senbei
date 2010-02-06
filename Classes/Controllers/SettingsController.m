//
//  SettingsController.m
//  Saccharin
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "SettingsController.h"
#import "Definitions.h"
#import "FatFreeCRMProxy.h"

@implementation SettingsController

@synthesize navigationController = _navigationController;

#pragma mark -
#pragma mark Init and dealloc

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithNibName:@"IASKAppSettingsView" bundle:nil]) 
    {
        self.showDoneButton = NO;
        self.showCreditsFooter = NO;
        _navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        self.title = @"Settings";
        self.tabBarItem.image = [UIImage imageNamed:@"settings.png"];
    }
    return self;
}

- (void)dealloc 
{
    [_navigationController release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

@end
