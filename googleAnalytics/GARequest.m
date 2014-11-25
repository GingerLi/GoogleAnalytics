//
//  GARequest.m
//  GoogleAnalyticsSDK
//
//  Created by Kfir Schindelhaim on 12/12/13.
//  Copyright (c) 2013 Kfir Schindelhaim. All rights reserved.
//

#import "GARequest.h"
#import "GAUtils.h"
#import "GATracker.h"

#define GOOGLE_ANALITYCS_URL     @"http://www.google-analytics.com/collect"  //Not Secured
#define GOOGLE_ANALITYCS_URL_SSL @"https://ssl.google-analytics.com/collect" //Secured

@interface GARequest ()

@property (strong) NSString *cid;
@property (strong) NSString *language;
@property (strong) NSString *appVersion;
@property (strong) NSString *appName;
@property (strong) NSString *customDimension1; // uuid
@property (strong) NSString *customDimension2; // hardware model
@property (strong) NSString *customDimension3; // os
@property (strong) NSDictionary *param;



@end

@implementation GARequest

- (void)commonInit
{
    _cid = [GAUtils userUUID];
    _language = [GAUtils userLanguage];
    _appName = [GAUtils appName];
    _appVersion = [GAUtils appVersion];
    _customDimension1 = [GAUtils userUUID];
    _customDimension2 = [GAUtils hardwareModel];
    _customDimension3 = [GAUtils operatingSystem];
    
}

- (id) initWithHitParam:(NSDictionary *)param
{
    self = [super init];
    if (self) {
        [self commonInit];
        _param = param;
        
    }
    return self;
}



// -------------------------------------------------------------------------------
#pragma mark - Post Strings
// -------------------------------------------------------------------------------
- (NSString*)postUrl
{
    if (self.tracker.useSSL)
    {
        return [GOOGLE_ANALITYCS_URL_SSL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        return [GOOGLE_ANALITYCS_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
}

- (NSString*)postBody
{
     __block NSString * postBody = [NSString stringWithFormat:@"v=1&t=%@&cid=%@&an=%@&av=%@&cd1=%@&cd2=%@&cd3=%@", self.tracker.trackingID, self.cid, self.appName, self.appVersion, self.customDimension1, self.customDimension2, self.customDimension3];
    [self.param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        postBody=[postBody stringByAppendingFormat:@"&%@=%@",key,obj];
    }];
    return postBody;
}



// -------------------------------------------------------------------------------
#pragma mark - Send Request
// -------------------------------------------------------------------------------
- (NSURLRequest*)postRequest
{
    NSURL *url = [NSURL URLWithString:self.postUrl];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"POST"];
    
    NSString *postString = [[self postBody] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [theRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setHTTPShouldUsePipelining:YES];
    
    return theRequest;
}

- (BOOL)sendRequest
{
    NSError *error = nil;
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:self.postRequest returningResponse:&response error:&error];
    if (error)
    {
        if (self.tracker.debug)
        {
            NSLog(@"Did fail with error %@" , [error localizedDescription]);
        }
        return NO;
    }
    else
    {
        if (self.tracker.debug)
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            long statusCode = [httpResponse statusCode];
            NSLog(@"Status code was %lu, response: %@", statusCode, httpResponse);
        }
        return YES;
    }
}

@end
