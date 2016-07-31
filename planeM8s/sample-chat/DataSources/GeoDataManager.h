//
//  SSLGeoDataManager.h
//  planeM8s
//
//  Created by Quickblox Team on 8/27/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoDataManager : NSObject

@property CLLocationCoordinate2D coordinate;

- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate;

+ (instancetype)instance;

@end