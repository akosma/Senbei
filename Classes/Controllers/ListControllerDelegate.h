//
//  BaseListControllerDelegate.h
//  Saccharin
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ListController;
@class BaseEntity;

@protocol ListControllerDelegate <NSObject>

@optional
- (void)listController:(ListController *)controller didSelectEntity:(BaseEntity *)entity;
- (void)listController:(ListController *)controller didTapAccessoryForEntity:(BaseEntity *)entity;

@end
