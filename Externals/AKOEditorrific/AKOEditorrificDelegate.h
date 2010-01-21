//
//  AKOEditorrificDelegate.h
//  AKOLibrary
//
//  Created by Adrian on 11/7/09.
//  Copyright 2009 akosma software. All rights reserved.
//

@class AKOEditorrific;

@protocol AKOEditorrificDelegate <NSObject>

@required
- (void)editorrific:(AKOEditorrific *)editorrific didEnterText:(NSString *)text;

@optional
- (void)editorrificDidCancel:(AKOEditorrific *)editorrific;

@end
