//
//  MobileIdentityManager.m
//  EngageSDK
//
//  Created by andrew zuercher on 1/19/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "EngageConnectionManager.h"

@interface EngageConnectionManager()

@property NSString *clientId, *secret, *refreshToken, *host;

@end


@implementation EngageConnectionManager
__strong static EngageConnectionManager *_sharedInstance = nil;

+ (EngageConnectionManager*)sharedInstance
{
    if (_sharedInstance == nil) {
        [NSException raise:@"MobileIdentityManager sharedInstance is null" format:@"MobileIdentityManager sharedInstance is null. You must first create an MobileIdentityManager instance"];
    }
    return _sharedInstance;
}

- (void) dealloc {
}

+ (EngageConnectionManager*)createInstanceWithHost:(NSString *)host
                                        clientId:(NSString *)clientId
                                          secret:(NSString *)secret
                                           token:(NSString *)refreshToken {
    if (_sharedInstance != nil) {
        return _sharedInstance;
    }
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedInstance = [[EngageConnectionManager alloc] initWithHost:host clientId:clientId secret:secret token:refreshToken];
    });
    
    return _sharedInstance;
}
- (id)initWithHost:(NSString *)host
          clientId:(NSString *)clientId
            secret:(NSString *)secret
             token:(NSString *)refreshToken
{
    
    NSURL *baseUrl = [NSURL URLWithString:host];
    
    if (self = [super initWithBaseURL:baseUrl clientID:clientId secret:secret]) {
        _clientId = clientId;
        _secret = secret;
        _refreshToken = refreshToken;
        _host = host;
        
//        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//            if (status == AFNetworkReachabilityStatusNotReachable) {
//                [[self operationQueue] setSuspended:YES];
//            } else {
//                [[self operationQueue] setSuspended:NO];
//            }
//        }];
        [[self operationQueue] setSuspended:NO];
//        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    
    return self;
}

- (BOOL)isAuthenticated {
    if (self.credential != nil && ![self.credential isExpired]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)authenticate:(void (^)(AFOAuthCredential *credential))success
             failure:(void (^)(NSError *error))failure {
//    [[self operationQueue] setSuspended:NO];
    [self authenticateUsingOAuthWithURLString:[self.host stringByAppendingString:@"oauth/token"]
                                 refreshToken:_refreshToken
                                      success:^(AFOAuthCredential *credential) {
                                          
                                          self.credential = credential;
                                          
                                          if (success) {
                                              success(credential);
                                          }
                                          
                                          //Checks the network status and if its active open up the queue.
                                          if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
                                              [[self operationQueue] setSuspended:YES];
                                          } else {
                                              [[self operationQueue] setSuspended:NO];
                                          }
                                      }
                                      failure:^(NSError *error) {
                                          [[self operationQueue] setSuspended:YES];
                                          
                                          if (failure) {
                                              failure(error);
                                          }
                                      }];
    
    //Suspend the operation queue until the login is successful
//    [[self operationQueue] setSuspended:YES];
}

- (void)postJsonRequest:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    AFOAuthCredential *credential = [self credential];
    
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [credential accessToken]] forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];

    
//    [self POST:URLString parameters:parameters success:success failure:failure];
}


- (void)postXmlRequest:(NSString *)URLString
         parameters:(id)parameters
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    
    AFOAuthCredential *credential = [self credential];
    [requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [credential accessToken]] forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [operation setResponseSerializer:[AFXMLParserResponseSerializer serializer]];
    
    [self.operationQueue addOperation:operation];
    
    // original
    
//    AFOAuthCredential *credential = [self credential];
//    [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [credential accessToken]] forHTTPHeaderField:@"Authorization"];
    
//    self.responseSerializer = [AFXMLParserResponseSerializer serializer];
//    [self POST:URLString parameters:parameters success:success failure:failure];
    
}

@end
