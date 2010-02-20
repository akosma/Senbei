//
//  Campaign.h
//  Senbei
//
//  Created by Adrian on 1/21/10.
//  Copyright (c) 2010, akosma software / Adrian Kosmaczewski
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. All advertising materials mentioning features or use of this software
//  must display the following acknowledgement:
//  This product includes software developed by akosma software.
//  4. Neither the name of the akosma software nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ADRIAN KOSMACZEWSKI ''AS IS'' AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL ADRIAN KOSMACZEWSKI BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>
#import "BaseEntity.h"

@interface Campaign : BaseEntity 
{
@private
    double _budget;
    NSDate *_endsOn;
    NSInteger _leadsCount;
    NSString *_objectives;
    NSInteger _opportunitiesCount;
    double _revenue;
    NSDate *_startsOn;
    NSString *_status;
    float _conversionTarget;
    NSInteger _leadsTarget;
    double _revenueTarget;
}

@property (nonatomic) double budget;
@property (nonatomic, retain) NSDate *endsOn;
@property (nonatomic) NSInteger leadsCount;
@property (nonatomic, copy) NSString *objectives;
@property (nonatomic) NSInteger opportunitiesCount;
@property (nonatomic) double revenue;
@property (nonatomic, retain) NSDate *startsOn;
@property (nonatomic, copy) NSString *status;
@property (nonatomic) float conversionTarget;
@property (nonatomic) NSInteger leadsTarget;
@property (nonatomic) double revenueTarget;

+ (NSString *)serverPath;
- (id)initWithCXMLElement:(CXMLElement *)element;

@end
