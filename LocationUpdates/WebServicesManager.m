//
//  WebServices.m
//  LocationUpdates
//
//  Created by Suhit on 24/12/14.
//  Copyright (c) 2014 com.suhit. All rights reserved.
//

#import "WebServicesManager.h"

@interface WebServicesManager ()

@property (nonatomic, strong) NSURLSessionConfiguration *configuration;
@property (nonatomic, strong) NSURLSession *session;

@end

static NSString* const kServerURLString = @"http://gentle-tor-1851.herokuapp.com/events";
static NSString* const kUser = @"suhit";
static NSString* const kPassword = @"phil53";

@implementation WebServicesManager

- (instancetype)init {
    return [self initWithBaseURL:[NSURL URLWithString:kServerURLString]];
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    return [self initWithBaseURL:url sessionConfiguration:nil];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    return [self initWithBaseURL:nil sessionConfiguration:configuration];
}

- (instancetype)initWithBaseURL:(NSURL *)url
           sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (!configuration) {
        _configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    else {
        _configuration = configuration;
    }
    return self;
}

- (void)submitUserLocationData:(NSString *)locationData success:(void (^)(id))successBlock failure:(void(^)(NSError *))failureBlock {
    
    NSDictionary *parameters = @{
                                 @"data":locationData
                                 };
    
    NSMutableString *parameterString = [NSMutableString string];
    for (NSString *key in [parameters allKeys]) {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@", key, parameters[key]];
    }
    
   
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kServerURLString]];
    [request setHTTPMethod:@"POST"];

    NSString *userPasswordString = [NSString stringWithFormat:@"%@:%@", kUser, kPassword];
    NSData * userPasswordData = [userPasswordString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedCredential = [userPasswordData base64EncodedStringWithOptions:0];
    NSString *authString = [NSString stringWithFormat:@"Basic %@", base64EncodedCredential];
   
    self.configuration.HTTPAdditionalHeaders = @{
                                                 @"Authorization": authString,
                                               };
     _session = [NSURLSession sessionWithConfiguration:self.configuration];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
            NSLog(@"%ld", (long)httpResp.statusCode);
            if (httpResp.statusCode == 201 && [data length]) {
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                successBlock(jsonResponse);
            }
        } else {
            NSLog(@"%@", error.description);
            failureBlock(error);
        }
    }];
    [task resume];
    
}


@end
