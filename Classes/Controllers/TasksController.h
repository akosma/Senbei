//
//  TasksController.h
//  Saccharin
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TasksController : UITableViewController 
{
@private
    UINavigationController *_navigationController;
}

@property (nonatomic, readonly) UINavigationController *navigationController;

@end
