//
//  NSDate+Senbei.m
//  Senbei
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "NSDate+Senbei.h"

@implementation NSDate (Senbei)

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

- (NSString *)stringWithDateFormattedWithCurrentLocale
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *result = [formatter stringFromDate:self];
    [formatter release];
    
    return result;
}

- (NSString *)stringForNewTaskCreation
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *result = [formatter stringFromDate:self];
    [formatter release];
    return result;
}

@end
