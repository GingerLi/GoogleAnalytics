//
//  GAEventHit.m
//  CPGATracking
//
//  Created by Ivan Ablamskyi on 19.12.12.
//  Copyright (c) 2012 Coppertino Inc. All rights reserved.
//

#import "GAEventHit.h"

@implementation GAEventHit

- (GAHitType)hitType { return GAEvent; }



- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [@{@"t" : @"event"} mutableCopy];
    
    if (self.category)
        [dict setValue:self.category forKey:@"ec"];
    
    if (self.action)
        [dict setValue:self.action forKey:@"ea"];
    
    if (self.label)
        [dict setValue:self.label forKey:@"el"];
    
    if (self.value)
        [dict setValue:self.value forKey:@"ev"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}


+ (id)eventCategory:(NSString *)ec action:(NSString *)ea label:(NSString *)el value:(NSNumber *)ev
{
    GAEventHit * event = [GAEventHit new];
    event.category = ec;
    event.action = ea;
    event.label = el;
    event.value = ev;
    return event;
}
@end
