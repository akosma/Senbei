//
//  AccountsController.h
//  Senbei
//
//  Created by Adrian on 1/19/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListControllerDelegate.h"

@interface ListController : UITableViewController <UISearchDisplayDelegate, 
                                                       UISearchBarDelegate>
{
@private
    UINavigationController *_navigationController;
    UISearchDisplayController *_searchController;
    UISearchBar *_searchBar;
    NSMutableArray *_data;
	NSMutableArray	*_searchData;
    NSInteger _pageCounter;
    BOOL _moreToLoad;
    BOOL _firstLoad;
    Class _listedClass;
    UITableViewCellAccessoryType _accessoryType;
    
    IBOutlet id<ListControllerDelegate> _delegate;
}

@property (nonatomic) UITableViewCellAccessoryType accessoryType;
@property (nonatomic) Class listedClass;
@property (nonatomic, assign) id<ListControllerDelegate> delegate;

- (void)refresh;

@end
