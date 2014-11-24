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
#import "AFNetworkReachabilityManager.h"

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
        NSString * key = [NSString stringWithFormat:@"%@.%@", kGASavedHitsKey, trackingID];
        NSArray *prevHits = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
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
        const char * label = [[NSString stringWithFormat:@"com.trendmicro.google-analytics.%@",trackingID] cStringUsingEncoding:NSUTF8StringEncoding];
        _queue  = dispatch_queue_create(label, NULL);
        _useSSL = YES;
    }
#ifdef DEBUG
    self.debug = YES;
    self.dispatchInterval = INFINITY;
#endif
    
    __weak __typeof(self) weakSelf = self;

    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[NSNotificationCenter defaultCenter] addObserverForName:AFNetworkingReachabilityDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if ([[note.userInfo valueForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue] > AFNetworkReachabilityStatusNotReachable)
        {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            NSLog(@"Reachability: %@", note);
            [strongSelf dispatch];
        }
        
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationWillTerminateNotification object:NSApp queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
      
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSMutableArray *saveHits = [NSMutableArray arrayWithCapacity:strongSelf.hits.count];
        [strongSelf.hits enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [saveHits addObject:[obj dictionaryRepresentation]];
        }];
        
        
        [NSApp replyToApplicationShouldTerminate:NO];
        
        NSString * key = [NSString stringWithFormat:@"%@.%@", kGASavedHitsKey, strongSelf.trackingID];
        [[NSUserDefaults standardUserDefaults] setObject:saveHits forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
    return self;
}

- (void)setDispatchInterval:(NSTimeInterval)dispatchInterval;
{
    _dispatchInterval = dispatchInterval;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (dispatchInterval > 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:dispatchInterval target:self selector:@selector(dispatch:) userInfo:NULL repeats:YES];
    }
}

- (void)dispatch:(NSTimer *)timer;
{
    NSLog(@"[%@] Fire events (size: %@)", [timer fireDate], @(self.hits.count));
    [self dispatch];
}

- (void)dealloc
{
//    [self dispatch];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSApplicationWillTerminateNotification object:NSApp];
    
    
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
