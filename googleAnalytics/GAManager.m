//
//  GAManager.m
//  googleAnalytics
//
//  Created by itisdev on 11/25/14.
//  Copyright (c) 2014 trendmicro. All rights reserved.
//

#import "GAManager.h"
#import "GATracker.h"
#import "NetworkReachabilityManager.h"

@interface GAManager ()
@property (nonatomic, strong) NSMutableDictionary * trackers;

@end

@implementation GAManager

+ (GAManager *)sharedInstance
{
    static GAManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GAManager alloc] init];
        
    });

    return manager;
}
+ (void)addTrackersWithIDs:(NSArray *)IDs
{
    [[GAManager sharedInstance] addTrackersWithIDs:IDs];
}

+ (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString*)label value:(NSNumber*)value
{
    [[GAManager sharedInstance] sendEventWithCategory:category action:action label:label value:value];
}


- (id)init
{
    self = [super init];
    if (self) {
        _trackers = [NSMutableDictionary new];
        
    }
    return self;
}

- (void)addTrackersWithIDs:(NSArray *)IDs
{
    for (NSString *trackingID in IDs) {
        
        if (![[self.trackers allKeys] containsObject:trackingID]) {
            [self.trackers addEntriesFromDictionary:@{trackingID: [GATracker trackerWithID:trackingID]}];
        }
    }
    [[NetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString*)label value:(NSNumber*)value
{
    [self.trackers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        GATracker * tracker = obj;
        [tracker sendEventWithCategory:category action:action label:label value:value];
    }];
}
@end
