//
//  AKOImageViewDelegate.h
//  AKOLibrary
//
//  Created by Adrian on 11/9/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKOImageView;

@protocol AKOImageViewDelegate <NSObject>

- (void)imageViewDidLoadImage:(AKOImageView *)imageView;
- (void)imageView:(AKOImageView *)imageView didFailLoadingWithError:(NSError *)error;
- (void)imageViewDidNotFindImage:(AKOImageView *)imageView;

@end
