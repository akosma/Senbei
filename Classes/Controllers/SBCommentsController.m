//
//  SBCommentsController.m
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

#import "SBCommentsController.h"
#import "SBModels.h"
#import "SBHelpers.h"
#import "SBExternals.h"

@interface SBCommentsController ()

@property (nonatomic, retain) UIButton *backgroundButton;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, retain) AKOEditorrific *editor;

@end


@implementation SBCommentsController

@synthesize entity = _entity;
@synthesize backgroundButton = _backgroundButton;
@synthesize comments = _comments;
@synthesize editor = _editor;

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) 
    {
        self.comments = [NSMutableArray arrayWithCapacity:10];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(didReceiveComments:) 
                                                     name:SBNetworkManagerDidRetrieveCommentsNotification
                                                   object:[SBNetworkManager sharedSBNetworkManager]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didPostComment:) 
                                                     name:SBNetworkManagerDidPostCommentNotification 
                                                   object:[SBNetworkManager sharedSBNetworkManager]];
        
        UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                 target:self 
                                                                                 action:@selector(addComment:)] autorelease];
        self.navigationItem.rightBarButtonItem = button;
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

#pragma mark - UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = self.entity.name;
    [self.comments removeAllObjects];
    [self.tableView reloadData];
    [[SBNetworkManager sharedSBNetworkManager] loadCommentsForEntity:self.entity];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button handler

- (void)addComment:(id)sender
{
    if (self.editor == nil)
    {
        self.backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backgroundButton.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
        [self.backgroundButton addTarget:self 
                              action:@selector(backgroundButtonTouched:)
                    forControlEvents:UIControlEventTouchUpInside];
        self.backgroundButton.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.200];
        [self.tabBarController.view addSubview:self.backgroundButton];

        self.editor = [[[AKOEditorrific alloc] init] autorelease];
        self.editor.delegate = self;
        [self.tabBarController.view addSubview:self.editor];
    }
    self.backgroundButton.hidden = NO;
    [self.editor show];
}

- (void)backgroundButtonTouched:(id)sender
{
    self.backgroundButton.hidden = YES;
    [self.editor dismissEditor];
}

#pragma mark - AKOEditorrificDelegate methods

- (void)editorrific:(AKOEditorrific *)editorrific didEnterText:(NSString *)text
{
    self.backgroundButton.hidden = YES;
    [[SBNetworkManager sharedSBNetworkManager] sendComment:text forEntity:self.entity];
}

- (void)editorrificDidCancel:(AKOEditorrific *)editorrific
{
    self.backgroundButton.hidden = YES;
}

#pragma mark - NSNotification handler methods

- (void)didReceiveComments:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    SBBaseEntity *entity = [dict objectForKey:@"entity"];
    if (entity == self.entity)
    {
        NSArray *newData = [dict objectForKey:@"data"];
        [self.comments removeAllObjects];
        [self.comments addObjectsFromArray:newData];
        [self.tableView reloadData];
    }
}

- (void)didPostComment:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    SBBaseEntity *entity = [dict objectForKey:@"entity"];
    if (entity == self.entity)
    {
        [[SBNetworkManager sharedSBNetworkManager] loadCommentsForEntity:self.entity];
    }
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBComment *comment = [self.comments objectAtIndex:indexPath.row];
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
    return [self.comments count];
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

    SBComment *comment = [self.comments objectAtIndex:indexPath.row];
    cell.textLabel.text = comment.comment;
    cell.detailTextLabel.text = [comment.createdAt stringFormattedWithCurrentLocale];
    return cell;
}

@end
