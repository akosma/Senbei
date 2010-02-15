//
//  ListTableViewCell.m
//  Senbei
//
//  Created by Adrian on 2/15/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "ListTableViewCell.h"
#import "AKOImageView.h"

@implementation ListTableViewCell

@dynamic photoView;

#pragma mark -
#pragma mark Static methods

+ (ListTableViewCell *)cellWithReuseIdentifier:(NSString *)reuseIdentifier
{
    ListTableViewCell *cell = [[ListTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
    return [cell autorelease];
}

#pragma mark -
#pragma mark Init and dealloc

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle
                    reuseIdentifier:reuseIdentifier]) 
    {
    }
    return self;
}

- (void)dealloc 
{
    [_photoView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Overridden methods

- (void)layoutSubviews 
{
    // This trick is borrowed from
    // http://stackoverflow.com/questions/1132029/labels-aligning-in-uitableviewcell
    [super layoutSubviews];
    if (!_photoView.hidden)
    {
        CGRect rect = self.textLabel.frame;
        self.textLabel.frame = CGRectMake(rect.origin.x + 60.0, 
                                          rect.origin.y,
                                          210.0, 
                                          rect.size.height);
        rect = self.detailTextLabel.frame;
        self.detailTextLabel.frame = CGRectMake(rect.origin.x + 60.0, 
                                          rect.origin.y,
                                          210.0, 
                                          rect.size.height);
    }
}

#pragma mark -
#pragma mark Overridden properties

- (AKOImageView *)photoView
{
    if (_photoView == nil)
    {
        _photoView = [[AKOImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 50.0, 50.0)];
        [self.contentView addSubview:_photoView];
    }
    return _photoView;
}

@end
