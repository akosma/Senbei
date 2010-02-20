//
//  AccountsController.m
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

#import "ListController.h"
#import "FatFreeCRMProxy.h"
#import "CompanyAccount.h"
#import "NSDate+Senbei.h"
#import "ListTableViewCell.h"
#import "AKOImageView.h"

@implementation ListController

@synthesize listedClass = _listedClass;
@synthesize delegate = _delegate;
@synthesize accessoryType = _accessoryType;

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) 
    {
        _navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        _accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        UIBarButtonItem *reloadItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                    target:self
                                                                                    action:@selector(refresh)];
        self.navigationItem.leftBarButtonItem = reloadItem;
        [reloadItem release];
        
        
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
        NSString *search = NSLocalizedString(@"SEARCH", @"Word used in the 'Search' controller");
        _searchBar.placeholder = search;
        _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar 
                                                              contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsDataSource = self;
        _searchController.searchResultsDelegate = self;
        
        _data = [[NSMutableArray alloc] initWithCapacity:20];
        _searchData = [[NSMutableArray alloc] initWithCapacity:20];
        
        _pageCounter = 1;
        _moreToLoad = YES;
        _firstLoad = YES;
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

#pragma mark -
#pragma mark Public methods

- (void)refresh
{
    [[FatFreeCRMProxy sharedFatFreeCRMProxy] loadList:_listedClass page:_pageCounter];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.tableView.tableHeaderView = _searchBar;
    self.tableView.rowHeight = 60.0;
    self.searchDisplayController.searchResultsTableView.rowHeight = 60.0;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    if (_firstLoad)
    {
        [self refresh];
    }
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark NSNotification methods

- (void)didReceiveData:(NSNotification *)notification
{
    NSArray *newData = [[notification userInfo] objectForKey:@"data"];
    _moreToLoad = [newData count] > 0;
    if (self.searchDisplayController.active)
    {
        [_searchData addObjectsFromArray:newData];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else 
    {
        [_data addObjectsFromArray:newData];
        [self.tableView reloadData];
    }
    
    if (_firstLoad)
    {
        _firstLoad = NO;
        [self performSelector:@selector(scroll) 
                   withObject:nil
                   afterDelay:0.5];
    }
}

- (void)scroll
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath 
                          atScrollPosition:UITableViewScrollPositionTop 
                                  animated:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // When the user scrolls to the bottom, we load a new page of information automatically.
    if (!self.searchDisplayController.active && _moreToLoad && 
        scrollView.contentOffset.y + 372.0 >= scrollView.contentSize.height)
    {
        ++_pageCounter;
        [self refresh];
    }
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (self.searchDisplayController.active)
	{
        return [_searchData count];
    }
    if (_moreToLoad)
    {
        return [_data count] + 1;
    }
    return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *cellIdentifier = @"ListControllerCell";
    
    ListTableViewCell *cell = (ListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) 
    {
        cell = [ListTableViewCell cellWithReuseIdentifier:cellIdentifier];
    }

    NSArray *array = (self.searchDisplayController.active) ? _searchData : _data;
    
    if (indexPath.row < [array count])
    {
        BaseEntity *item = [array objectAtIndex:indexPath.row];
        cell.accessoryType = _accessoryType;
        cell.textLabel.text = item.name;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = [item description];

        NSURL *photoURL = item.photoURL;
        cell.photoView.hidden = (photoURL == nil);
        cell.photoView.url = photoURL;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSString *loading = NSLocalizedString(@"LOADING", @"Text shown in cells when more content is loading");
        cell.textLabel.text = loading;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.text = @"";

        cell.photoView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(listController:didTapAccessoryForEntity:)])
    {
        NSArray *array = (self.searchDisplayController.active) ? _searchData : _data;
        BaseEntity *entity = [array objectAtIndex:indexPath.row];
        [_delegate listController:self didTapAccessoryForEntity:entity];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([_delegate respondsToSelector:@selector(listController:didSelectEntity:)])
    {
        NSArray *array = (self.searchDisplayController.active) ? _searchData : _data;
        BaseEntity *entity = [array objectAtIndex:indexPath.row];
        [_delegate listController:self didSelectEntity:entity];
    }
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
	[_searchData removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
	
    if (searchText != nil && [searchText length] > 0)
    {
        [[FatFreeCRMProxy sharedFatFreeCRMProxy] searchList:_listedClass query:searchText];
    }
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSInteger index = [_searchController.searchBar selectedScopeButtonIndex];
    NSArray *buttons = [_searchController.searchBar scopeButtonTitles];
    NSString *scope = [buttons objectAtIndex:index];
    [self filterContentForSearchText:searchString scope:scope];
    
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSArray *buttons = [_searchController.searchBar scopeButtonTitles];
    NSString *scope = [buttons objectAtIndex:searchOption];
    [self filterContentForSearchText:_searchController.searchBar.text scope:scope];
    
    return NO;
}

@end
