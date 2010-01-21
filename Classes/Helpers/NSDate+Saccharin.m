//
//  NSDate+Saccharin.m
//  Saccharin
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "NSDate+Saccharin.h"

@implementation NSDate (Saccharin)

- (NSString *)stringFormattedWithCurrentLocale
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *result = [formatter stringFromDate:self];
    [formatter release];
    
    return result;    
}

@end
