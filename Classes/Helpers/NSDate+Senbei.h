//
//  NSDate+Senbei.h
//  Senbei
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Senbei)

- (NSString *)stringFormattedWithCurrentLocale;
- (NSString *)stringWithDateFormattedWithCurrentLocale;
- (NSString *)stringForNewTaskCreation;

@end
