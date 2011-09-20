//
//  SBListController.m
//  Senbei
//
//  Created by Adrian on 1/19/10.
//  Copyright (c) 2010, akosma software / Adrian Kosmaczewski
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. All advertising materials mentioning features or use of this software
//  must display the following acknowledgement:
//  This product includes software developed by akosma software.
//  4. Neither the name of the akosma software nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ADRIAN KOSMACZEWSKI ''AS IS'' AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL ADRIAN KOSMACZEWSKI BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SBListController.h"
#import "SBModels.h"
#import "SBHelpers.h"
#import "SBListTableViewCell.h"
#import "AKOImageView.h"

@interface SBListController ()

@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) UISearchDisplayController *searchController;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) NSMutableArray *searchData;
@property (nonatomic) NSInteger pageCounter;
@property (nonatomic) NSInteger pageSize;
@property (nonatomic) BOOL moreToLoad;
@property (nonatomic) BOOL firstLoad;

- (void)loadData;
- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope;

@end


@implementation SBListController

@synthesize listedClass = _listedClass;
@synthesize delegate = _delegate;
@synthesize accessoryType = _accessoryType;

@synthesize navigationController = _navigationController;
@synthesize searchController = _searchController;
@synthesize searchBar = _searchBar;
@synthesize data = _data;
@synthesize searchData = _searchData;
@synthesize pageCounter = _pageCounter;
@synthesize pageSize = _pageSize;
@synthesize moreToLoad = _moreToLoad;
@synthesize firstLoad = _firstLoad;

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) 
    {
        self.navigationController = [[[UINavigationController alloc] initWithRootViewController:self] autorelease];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        UIBarButtonItem *reloadItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                     target:self
                                                                                     action:@selector(refresh:)] autorelease];
        self.navigationItem.leftBarButtonItem = reloadItem;
        
        self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
        NSString *search = NSLocalizedString(@"SEARCH", @"Word used in the 'Search' controller");
        self.searchBar.placeholder = search;
        self.searchController = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar 
                                                                   contentsController:self] autorelease];
        self.searchController.delegate = self;
        self.searchController.searchResultsDataSource = self;
        self.searchController.searchResultsDelegate = self;
        
        self.data = [NSMutableArray arrayWithCapacity:20];
        self.searchData = [NSMutableArray arrayWithCapacity:20];
        
        self.pageSize = 0;
        self.pageCounter = 1;
        self.moreToLoad = YES;
        self.firstLoad = YES;
    }
    return self;
}

- (void)dealloc 
{
    [_navigationController release];
    [_searchBar release];
    [_searchController release];
    [_data release];
    [_searchData release];
    [super dealloc];
}

#pragma mark - Button handler methods

- (void)refresh:(id)sender
{
    self.pageCounter = 1;
    self.pageSize = 0;
    self.moreToLoad = YES;
    self.firstLoad = YES;
    [self.data removeAllObjects];
    [self loadData];
}

#pragma mark - UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.rowHeight = 60.0;
    self.searchDisplayController.searchResultsTableView.rowHeight = 60.0;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    if (self.firstLoad)
    {
        [self loadData];
    }
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark - NSNotification methods

- (void)didReceiveData:(NSNotification *)notification
{
    NSArray *newData = [[notification userInfo] objectForKey:@"data"];
    self.moreToLoad = [newData count] >= self.pageSize;
    if (self.searchDisplayController.active)
    {
        [self.searchData addObjectsFromArray:newData];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else 
    {
        [self.data addObjectsFromArray:newData];
        [self.tableView reloadData];
    }
    
    if (self.firstLoad)
    {
        self.firstLoad = NO;
        self.pageSize = [newData count];
        [self performSelector:@selector(scroll) 
                   withObject:nil
                   afterDelay:0.5];
    }
}

- (void)scroll
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if ([self.data count] > 0)
    {
        [self.tableView scrollToRowAtIndexPath:indexPath 
                              atScrollPosition:UITableViewScrollPositionTop 
                                      animated:YES];
        self.moreToLoad = self.moreToLoad && ([self.data count] > [[self.tableView indexPathsForVisibleRows] count]);
    }
    else
    {
        self.moreToLoad = NO;
    }
    [self.tableView reloadData];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // When the user scrolls to the bottom, we load a new page of information automatically.
    if (!self.searchDisplayController.active && self.moreToLoad && 
        scrollView.contentOffset.y + 372.0 >= scrollView.contentSize.height)
    {
        self.pageCounter += 1;
        [self loadData];
    }
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (self.searchDisplayController.active)
	{
        return [self.searchData count];
    }
    if (self.moreToLoad)
    {
        return [self.data count] + 1;
    }
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *cellIdentifier = @"ListControllerCell";
    
    SBListTableViewCell *cell = (SBListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) 
    {
        cell = [SBListTableViewCell cellWithReuseIdentifier:cellIdentifier];
    }

    NSArray *array = (self.searchDisplayController.active) ? self.searchData : self.data;
    
    if (indexPath.row < [array count])
    {
        SBBaseEntity *item = [array objectAtIndex:indexPath.row];
        cell.accessoryType = self.accessoryType;
        cell.textLabel.text = item.name;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = [item description];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;

        NSURL *photoURL = item.photoURL;
        cell.photoView.hidden = (photoURL == nil);
        cell.photoView.url = photoURL;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSString *loading = NSLocalizedString(@"LOADING", @"Text shown in cells when more content is loading");
        cell.textLabel.text = loading;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.text = @"";

        cell.photoView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(listController:didTapAccessoryForEntity:)])
    {
        NSArray *array = (self.searchDisplayController.active) ? self.searchData : self.data;
        if (indexPath.row < [array count])
        {
            SBBaseEntity *entity = [array objectAtIndex:indexPath.row];
            [self.delegate listController:self didTapAccessoryForEntity:entity];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([self.delegate respondsToSelector:@selector(listController:didSelectEntity:)])
    {
        NSArray *array = (self.searchDisplayController.active) ? self.searchData : self.data;
        if (indexPath.row < [array count])
        {
            SBBaseEntity *entity = [array objectAtIndex:indexPath.row];
            [self.delegate listController:self didSelectEntity:entity];
        }
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSInteger index = [self.searchController.searchBar selectedScopeButtonIndex];
    NSArray *buttons = [self.searchController.searchBar scopeButtonTitles];
    NSString *scope = [buttons objectAtIndex:index];
    [self filterContentForSearchText:searchString scope:scope];
    
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSArray *buttons = [self.searchController.searchBar scopeButtonTitles];
    NSString *scope = [buttons objectAtIndex:searchOption];
    [self filterContentForSearchText:self.searchController.searchBar.text scope:scope];
    
    return NO;
}

#pragma mark - Private methods

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
	[self.searchData removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
	
    if (searchText != nil && [searchText length] > 0)
    {
        [[FatFreeCRMProxy sharedFatFreeCRMProxy] searchList:self.listedClass query:searchText];
    }
}

- (void)loadData
{
    [[FatFreeCRMProxy sharedFatFreeCRMProxy] loadList:self.listedClass page:self.pageCounter];
}

@end
