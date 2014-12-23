//
//  LocationManager.m
//  LocationUpdates
//
//  Created by Suhit on 23/12/14.
//  Copyright (c) 2014 com.suhit. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationManager () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@end

@implementation LocationManager

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self startLocationServices];
    }
    return self;
}

- (void)startLocationServices {
    
    // Create the CoreLocationManager object
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    //For iOS 8 and above
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _location = [locations lastObject];
    
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[self.location.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) {
        return;
    }
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (self.location.horizontalAccuracy < 0) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(updateCoordinatesWithLattitudeAndLongitude:)]) {
        [self.delegate updateCoordinatesWithLattitudeAndLongitude:[NSString stringWithFormat:@"%+.6f, %+.6f", self.location.coordinate.latitude, self.location.coordinate.longitude]];
    }
}


- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            break;
            
        case kCLAuthorizationStatusDenied:
            NSLog(@"Permission Denied");
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [self.locationManager startUpdatingLocation]; //Will update location immediately
            break;
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a
    // timeout that will stop the location manager to save power.
    //
    if ([error code] != kCLErrorLocationUnknown) {
        [self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
    }
}

@end
