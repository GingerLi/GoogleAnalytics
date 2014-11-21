//
//  GATracker.m
//  GoogleAnalyticsSDK
//
//  Created by Kfir Schindelhaim on 12/5/13.
//  Copyright (c) 2013 Kfir Schindelhaim. All rights reserved.
//

#import "GATracker.h"
#import "GARequest.h"
#import "GAHit.h"
#import "GAEventHit.h"
#import "GAExceptionHit.h"

#include <sys/sysctl.h>


NSString *const kGASavedHitsKey = @"googleAnalyticsOldHits";

@interface GATracker()

@property (strong) dispatch_queue_t queue;

@end

@implementation GATracker

+ (GATracker *)trackerWithID:(NSString *)trackingID
{
    GATracker *tracker = [[self alloc] initWithTrackingID:trackingID];
    if (trackingID) {
        
        // Restore prev hits
        NSArray *prevHits = [[NSUserDefaults standardUserDefaults] objectForKey:kGASavedHitsKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGASavedHitsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (prevHits && prevHits.count > 0) {
            [tracker.hits addObjectsFromArray:prevHits];
            [tracker dispatch];
        }
    }
    
    return tracker;
}

- (id)initWithTrackingID:(NSString*)trackingID
{
    self = [super init];
    if (self)
    {
        _trackingID = trackingID;
        _hits = [NSMutableArray array];
        _queue  = dispatch_queue_create("com.trendmicro.google-analytics", NULL);
        _useSSL = YES;
    }
#ifdef DEBUG
    self.debug = YES;
    self.dispatchInterval = 0;
#endif
    [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationWillTerminateNotification object:NSApp queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
//        @strongify(self);
    
        NSMutableArray *saveHits = [NSMutableArray arrayWithCapacity:self.hits.count];
        [self.hits enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [saveHits addObject:[obj dictionaryRepresentation]];
        }];
        
        
        [NSApp replyToApplicationShouldTerminate:NO];
        
        [[NSUserDefaults standardUserDefaults] setObject:saveHits forKey:kGASavedHitsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    return self;
}

- (void)dealloc
{
    [self dispatch];
}

// -------------------------------------------------------------------------------
#pragma mark - Reports
// -------------------------------------------------------------------------------

- (BOOL)trackHit:(id<GAHit>)hitObject;
{
    // User do not like tracking
    if (self.optOut)
        return NO;
    
    [self.hits addObject:hitObject];
    
    if (0 == self.dispatchInterval) {
        [self dispatch];
    }
    
    return YES;
}


- (void)sendException:(NSString *)description fatal:(BOOL)isFatal
{
    [self trackHit:[GAExceptionHit exceptionHitWithDescription:description isFatal:isFatal]];
}

- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString*)label value:(NSNumber*)value
{

    [self trackHit:[GAEventHit eventCategory:category action:action label:label value:value ]];
}

// -------------------------------------------------------------------------------
#pragma mark - Send Request
// -------------------------------------------------------------------------------

- (void)dispatch
{
    NSOrderedSet *copyHits = [self.hits copy];
    [copyHits enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        GARequest * request;
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            /* get dictionary from user defaults
             */
            request = [[GARequest alloc] initWithHitParam:obj];
            
        } else {
            /* get normal hit
             */
            id<GAHit>hit = obj;
            request = [[GARequest alloc] initWithHitParam:[hit dictionaryRepresentation]];
        }
        
        request.tracker = self;
        
        dispatch_async(self.queue, ^{
            [request sendRequest];
            [self.hits removeObject:obj];
        });
    }];
}


@end
