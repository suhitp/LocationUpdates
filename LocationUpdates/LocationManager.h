//
//  LocationManager.h
//  LocationUpdates
//
//  Created by Suhit on 23/12/14.
//  Copyright (c) 2014 com.suhit. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LocationManagerUpdatesDelagte <NSObject>

- (void)updateCoordinatesWithLattitudeAndLongitude:(NSString *)coordinates;

@end

@interface LocationManager : NSObject

@property (nonatomic, weak) id <LocationManagerUpdatesDelagte> delegate;

@end
