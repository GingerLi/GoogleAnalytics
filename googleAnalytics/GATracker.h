//
//  GATracker.h
//  GoogleAnalyticsSDK
//
//  Created by Kfir Schindelhaim on 12/5/13.
//  Copyright (c) 2013 Kfir Schindelhaim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAHit.h"

@interface GATracker : NSObject

@property (strong) NSString *trackingID;
@property (strong) NSString *appName;

@property (assign) BOOL debug;
@property (assign) BOOL useSSL;
@property (assign) BOOL optOut;
@property (strong) NSMutableArray *hits;
@property (strong) NSTimer *timer;

/*!
 If this value is negative, tracking information must be sent manually by
 calling dispatch. If this value is zero, tracking information will
 automatically be sent as soon as possible (usually immediately if the device
 has Internet connectivity). If this value is positive, tracking information
 will be automatically dispatched every dispatchInterval seconds.
 
 When the dispatchInterval is non-zero, setting it to zero will cause any queued
 tracking information to be sent immediately.
 
 By default, this is set to `120`, which indicates tracking information should
 be dispatched automatically every 120 seconds.
 */
@property (assign) NSTimeInterval dispatchInterval;

+ (GATracker *)trackerWithID:(NSString *)trackingID;


- (void)dispatch;

- (void) sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString*)label value:(NSNumber*)value;

@end
