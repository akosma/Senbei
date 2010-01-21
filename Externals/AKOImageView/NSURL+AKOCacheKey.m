//
//  NSURL+AKOCacheKey.m
//  AKOLibrary
//
//  Created by Adrian on 11/9/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "NSURL+AKOCacheKey.h"

@implementation NSURL (AKOCacheKey)

- (NSString *)cacheKey
{
    NSString *cacheKey = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                    (CFStringRef)[self absoluteString],
                                                                    NULL, 
                                                                    (CFStringRef)@";/?:@&=+$,", 
                                                                    kCFStringEncodingUTF8);
    return [cacheKey autorelease];
}

@end
