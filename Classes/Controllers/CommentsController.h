//
//  CommentsController.h
//  Senbei
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKOEditorrificDelegate.h"

@class BaseEntity;

@interface CommentsController : UITableViewController <AKOEditorrificDelegate>
{
@private
    UIButton *_backgroundButton;
    BaseEntity *_entity;
    NSMutableArray *_comments;
    AKOEditorrific *_editor;
}

@property (nonatomic, retain) BaseEntity *entity;

@end
