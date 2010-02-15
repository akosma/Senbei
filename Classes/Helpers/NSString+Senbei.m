//
//  NSString+Senbei.m
//  Senbei
//
//  Created by Adrian on 2/15/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "NSString+Senbei.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Senbei)

- (NSString *)md5
{
    // Code adapted from
    // http://amcmillan.livejournal.com/155200.html
    const char *cStr = [self UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, strlen(cStr), result);
	return [[NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ] lowercaseString];
}

@end
