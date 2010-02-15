//
//  ListTableViewCell.h
//  Senbei
//
//  Created by Adrian on 2/15/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKOImageView;

@interface ListTableViewCell : UITableViewCell 
{
@private
    AKOImageView *_photoView;
}

@property (nonatomic, readonly) AKOImageView *photoView;

+ (ListTableViewCell *)cellWithReuseIdentifier:(NSString *)reuseIdentifier;
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
