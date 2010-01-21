//
//  CommentsController.m
//  Saccharin
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "CommentsController.h"
#import "FatFreeCRMProxy.h"
#import "Comment.h"
#import "NSDate+Saccharin.h"
#import "AKOEditorrific.h"

@implementation CommentsController

@synthesize entity = _entity;

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) 
    {
        _comments = [[NSMutableArray alloc] initWithCapacity:10];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(didReceiveComments:) 
                                                     name:FatFreeCRMProxyDidRetrieveCommentsNotification
                                                   object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didPostComment:) 
                                                     name:FatFreeCRMProxyDidPostCommentNotification 
                                                   object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
        
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                target:self 
                                                                                action:@selector(addComment:)];
        self.navigationItem.rightBarButtonItem = button;
        [button release];
    }
    return self;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_comments release];
    [_backgroundButton release];
    _editor.delegate = nil;
    [_editor release];
    [_entity release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = _entity.name;
    [_comments removeAllObjects];
    [self.tableView reloadData];
    [[FatFreeCRMProxy sharedFatFreeCRMProxy] loadCommentsForEntity:_entity];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Button handler

- (void)addComment:(id)sender
{
    if (_editor == nil)
    {
        _backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backgroundButton.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
        [_backgroundButton addTarget:self 
                              action:@selector(backgroundButtonTouched:)
                    forControlEvents:UIControlEventTouchUpInside];
        _backgroundButton.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.200];
        [self.tabBarController.view addSubview:_backgroundButton];

        _editor = [[AKOEditorrific alloc] init];
        _editor.delegate = self;
        [self.tabBarController.view addSubview:_editor];
    }
    _backgroundButton.hidden = NO;
    [_editor show];
}

- (void)backgroundButtonTouched:(id)sender
{
    _backgroundButton.hidden = YES;
    [_editor dismissEditor];
}

#pragma mark -
#pragma mark AKOEditorrificDelegate methods

- (void)editorrific:(AKOEditorrific *)editorrific didEnterText:(NSString *)text
{
    _backgroundButton.hidden = YES;
    [[FatFreeCRMProxy sharedFatFreeCRMProxy] sendComment:text forEntity:_entity];
}

- (void)editorrificDidCancel:(AKOEditorrific *)editorrific
{
    _backgroundButton.hidden = YES;
}

#pragma mark -
#pragma mark NSNotification handler methods

- (void)didReceiveComments:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    BaseEntity *entity = [dict objectForKey:@"entity"];
    if (entity == _entity)
    {
        NSArray *newData = [dict objectForKey:@"data"];
        [_comments removeAllObjects];
        [_comments addObjectsFromArray:newData];
        [self.tableView reloadData];
    }
}

- (void)didPostComment:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    BaseEntity *entity = [dict objectForKey:@"entity"];
    if (entity == _entity)
    {
        [[FatFreeCRMProxy sharedFatFreeCRMProxy] loadCommentsForEntity:_entity];
    }
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [_comments objectAtIndex:indexPath.row];
    return [comment.comment sizeWithFont:[UIFont systemFontOfSize:17.0] 
                       constrainedToSize:CGSizeMake(300.0, 4000.0)].height + 30.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [_comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        cell.textLabel.numberOfLines = 0;
    }

    Comment *comment = [_comments objectAtIndex:indexPath.row];
    cell.textLabel.text = comment.comment;
    cell.detailTextLabel.text = [comment.createdAt stringFormattedWithCurrentLocale];
    return cell;
}

@end
