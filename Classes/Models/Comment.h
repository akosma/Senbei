//
//  Comment.h
//  Saccharin
//
//  Created by Adrian on 1/21/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEntity.h"

@interface Comment : BaseEntity
{
@private
    NSString *_comment;
}

@property (nonatomic, copy) NSString *comment;

- (id)initWithCXMLElement:(CXMLElement *)element;

@end
