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
@dynamic url;

#pragma mark -
#pragma mark Dealloc

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
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

- (NSURL *)url
{
    return _url;
}

- (void)setUrl:(NSURL *)url
{
    if (url != _url)
    {
        [_url release];
        _url = [url retain];
        
        if (_url != nil)
        {
            AKOImageCache *cache = [AKOImageCache sharedAKOImageCache];
            
            NSString *cacheKey = [_url cacheKey];
            if ([cache hasImageWithKey:cacheKey])
            {
                UIImage *cachedImage = [cache imageForKey:cacheKey];
                self.image = cachedImage;
                [_spinningWheel stopAnimating];
            }
            else 
            {
                self.image = nil;
                [_spinningWheel startAnimating];
                _request.delegate = nil;
                _request = [ASIHTTPRequest requestWithURL:_url];
                _request.delegate = self;
                _request.shouldRedirect = YES;
                [_request startAsynchronous];
            }
        }
    }
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{
    _request = nil;
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
    _request = nil;
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
