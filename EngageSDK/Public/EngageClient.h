//
//  EngageClient.h
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "AFOAuth2Manager.h"
#import "EngageLocalEventStore.h"

typedef enum {
    EngagePilot,
    EngagePilotSecure,
    EngageLiveSecure,
} EngageHostConfig;

@interface EngageClient : NSObject

- (id)initWithHost:(NSString *)host
          clientId:(NSString *)clientId
            secret:(NSString *)secret
             token:(NSString *)refreshToken;

- (BOOL)isAuthenticated;

- (void)authenticate:(void (^)(AFOAuthCredential *credential))success
               failure:(void (^)(NSError *error))failure;

@end
