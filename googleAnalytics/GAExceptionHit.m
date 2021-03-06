//
//  GAExceptionHit.m
//
//  Created by Ivan Ablamskyi on 16.01.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "GAExceptionHit.h"

@implementation GAExceptionHit

- (GAHitType)hitType { return GAException; }


- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [@{@"t" : @"exception"} mutableCopy];
    
    if (self.description)
        [dict setValue:self.exceptionDescription forKey:@"exd"];
    
    [dict setValue:@(self.fatal) forKey:@"exf"];
    
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (GAExceptionHit *)exceptionHitWithDescription:(NSString *)description isFatal:(BOOL)isFatal;
{
    GAExceptionHit *hit = [GAExceptionHit new];
    hit.exceptionDescription = description;
    hit.fatal = isFatal;
    return hit;
}

@end
