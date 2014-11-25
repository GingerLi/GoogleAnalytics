//
//  GAManager.h
//  googleAnalytics
//
//  Created by itisdev on 11/25/14.
//  Copyright (c) 2014 trendmicro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAManager : NSObject

+ (GAManager *)sharedInstance;

+ (void)addTrackersWithIDs:(NSArray *)IDs;

+ (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString*)label value:(NSNumber*)value;
@end
