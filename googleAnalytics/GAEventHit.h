//
//  GAEventHit.h
//  CPGATracking
//
//  Created by Ivan Ablamskyi on 19.12.12.
//  Copyright (c) 2012 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAHit.h"

@interface GAEventHit : NSObject <GAHit>

@property(nonatomic, strong) NSString *category;
@property(nonatomic, strong) NSString *action;
@property(nonatomic, strong) NSString *label;
@property(nonatomic, strong) NSValue *value;

+ (id)eventCategory:(NSString *)ec action:(NSString *)ea label:(NSString *)el value:(NSNumber *)ev;

@end
