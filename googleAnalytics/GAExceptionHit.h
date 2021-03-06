//
//  GAExceptionHit.h
//
//  Created by Ivan Ablamskyi on 16.01.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAHit.h"

@interface GAExceptionHit : NSObject <GAHit>

@property (nonatomic, strong) NSString *exceptionDescription;
@property (nonatomic, assign) BOOL fatal;

+ (GAExceptionHit *)exceptionHitWithDescription:(NSString *)description isFatal:(BOOL)isFatal;

@end
