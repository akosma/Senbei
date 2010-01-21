//
//  AKOImageView.h
//  AKOLibrary
//
//  Created by Adrian on 11/9/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKOImageViewDelegate.h"

@interface AKOImageView : UIImageView 
{
@private
    NSURL *_url;
    UIActivityIndicatorView *_spinningWheel;
    IBOutlet id<AKOImageViewDelegate> _delegate;
}

@property (nonatomic, assign) id<AKOImageViewDelegate> delegate;

- (void)loadImageFromURL:(NSURL *)url;
                                               
@end
