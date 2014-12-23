//
//  WebServices.h
//  LocationUpdates
//
//  Created by Suhit on 24/12/14.
//  Copyright (c) 2014 com.suhit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServicesManager : NSObject

/**
 Initializes an `WebServicesManager` object with the specified configuration.
 
 @param configuration for the HTTP client.
 
 @return The newly-initialized HTTP client
 */

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 Initializes an `WebServicesManager` object with the specified base URL.
 
 This is the designated initializer.
 
 @param url The base URL for the HTTP client.
 @param configuration The configuration used to create the managed session.
 
 @return The newly-initialized HTTP client
 */
- (instancetype)initWithBaseURL:(NSURL *)url
           sessionConfiguration:(NSURLSessionConfiguration *)configuration;

- (void)submitUserLocationData:(NSString *)locationData success:(void (^)(id))successBlock failure:(void(^)(NSError *))failureBlock;


@end
