//
//  CommentsController.m
//  Senbei
//
//  Created by Adrian on 1/20/10.
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

#import "CommentsController.h"
#import "FatFreeCRMProxy.h"
#import "Comment.h"
#import "NSDate+Senbei.h"
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
        
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
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
    CGFloat height = [comment.comment sizeWithFont:[UIFont systemFontOfSize:17.0] 
                                 constrainedToSize:CGSizeMake(300.0, 4000.0)].height + 30.0;
    if (height < 44.0)
    {
        height = 44.0;
    }
    return height;
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    Comment *comment = [_comments objectAtIndex:indexPath.row];
    cell.textLabel.text = comment.comment;
    cell.detailTextLabel.text = [comment.createdAt stringFormattedWithCurrentLocale];
    return cell;
}

@end
