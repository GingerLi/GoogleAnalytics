//
//  GAHit.h
//  CPGATracking
//
//  Created by Ivan Ablamskyi on 19.12.12.
//  Copyright (c) 2012 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "GATracking-Prefix.pch"

typedef NS_ENUM(NSInteger, GAHitType) {
    GAEvent,

    GAException,
    
};

@protocol GAHit <NSObject>

- (GAHitType)hitType;


- (NSDictionary *)dictionaryRepresentation;

@end
