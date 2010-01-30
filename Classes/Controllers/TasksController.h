//
//  TasksController.h
//  Saccharin
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewTaskController;

@interface TasksController : UITableViewController <UIAlertViewDelegate>
{
@private
    UINavigationController *_navigationController;
    NSMutableArray *_tasksOverdue;
    NSMutableArray *_tasksDueASAP;
    NSMutableArray *_tasksDueToday;
    NSMutableArray *_tasksDueTomorrow;
    NSMutableArray *_tasksDueThisWeek;
    NSMutableArray *_tasksDueNextWeek;
    NSMutableArray *_tasksDueLater;
    
    NSMutableArray *_sections;
    NSMutableDictionary *_categories;
    
    NSIndexPath *_indexPathToDelete;
    
    NewTaskController *_newTaskController;
}

@property (nonatomic, readonly) UINavigationController *navigationController;

@end
