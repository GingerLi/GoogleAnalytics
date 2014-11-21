//
//  GARequest.h
//  GoogleAnalyticsSDK
//
//  Created by Kfir Schindelhaim on 12/12/13.
//  Copyright (c) 2013 Kfir Schindelhaim. All rights reserved.
//

#import <Foundation/Foundation.h>



@class GATracker;

@interface GARequest : NSObject

@property (weak) GATracker *tracker;


- (id) initWithHitParam:(NSDictionary *)param;

- (BOOL)sendRequest;

@end
