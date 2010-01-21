//
//  AKOImageView.m
//  AKOLibrary
//
//  Created by Adrian on 11/9/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "AKOImageView.h"
#import "ASIHTTPRequest.h"
#import "AKOImageCache.h"
#import "NSURL+AKOCacheKey.h"

@implementation AKOImageView

@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Dealloc

- (id)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        _spinningWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinningWheel.center = self.center;
        _spinningWheel.hidesWhenStopped = YES;
        [self addSubview:_spinningWheel];
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    [_url release];
    [_spinningWheel release];
    [super dealloc];
}

#pragma mark -  
#pragma mark Public methods

- (void)loadImageFromURL:(NSURL *)url
{
    [_url release];
    _url = [url retain];
    
    AKOImageCache *cache = [AKOImageCache sharedAKOImageCache];
    
    if (self.image == nil)
    {
        NSString *cacheKey = [_url cacheKey];
        if ([cache hasImageWithKey:cacheKey])
        {
            UIImage *cachedImage = [cache imageForKey:cacheKey];
            self.image = cachedImage;
            [_spinningWheel stopAnimating];
        }
        else 
        {
            [_spinningWheel startAnimating];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:_url];
            [request setDelegate:self];
            [request startAsynchronous];
        }
    }
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [_spinningWheel stopAnimating];
    NSData *data = [request responseData];
    UIImage *remoteImage = [[UIImage alloc] initWithData:data];
    [[AKOImageCache sharedAKOImageCache] storeImage:remoteImage 
                                            withKey:[_url cacheKey]];
    self.image = remoteImage;
    [remoteImage release];
    
    if ([_delegate respondsToSelector:@selector(imageViewDidLoadImage:)])
    {
        [_delegate imageViewDidLoadImage:self];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [_spinningWheel stopAnimating];
    NSInteger status = [request responseStatusCode];
    if (status == 404)
    {
        if ([_delegate respondsToSelector:@selector(imageViewDidNotFindImage:)])
        {
            [_delegate imageViewDidNotFindImage:self];
        }
    }
    else 
    {
        if ([_delegate respondsToSelector:@selector(imageView:didFailLoadingWithError:)])
        {
            [_delegate imageView:self didFailLoadingWithError:[request error]];
        }
    }
}

@end
