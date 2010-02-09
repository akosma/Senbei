//
//  BaseEntity.h
//  Senbei
//
//  Created by Adrian on 1/20/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchXML.h"

@interface BaseEntity : NSObject 
{
@private
    NSInteger _objectId;
    NSDate *_createdAt;
    NSDate *_updatedAt;
    NSString *_name;
}

@property (nonatomic) NSInteger objectId;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, copy) NSString *name;

- (id)initWithCXMLElement:(CXMLElement *)element;

@end
