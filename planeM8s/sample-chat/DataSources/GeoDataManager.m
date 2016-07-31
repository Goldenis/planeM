//
//  SSLGeoDataManager.m
//  planeM8s
//
//  Created by Quickblox Team on 8/27/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "GeoDataManager.h"

@interface GeoDataManager() <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager* locationManager;
@end

@implementation GeoDataManager

+ (instancetype)instance
{
    static GeoDataManager *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (instancetype) init {
    
    self = [super init];
    if (self) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    
    return self;
}

- (float) metersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to  {
    
    CLLocation *userloc = [[CLLocation alloc]initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *dest = [[CLLocation alloc]initWithLatitude:to.latitude longitude:to.longitude];
    CLLocationDistance dist = [userloc distanceFromLocation:dest];
    
    NSString *distance = [NSString stringWithFormat:@"%f",dist];
    return [distance floatValue];
}

- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    
    _coordinate = newCoordinate;
    
    QBLGeoData *geoData = [QBLGeoData geoData];
    geoData.latitude = _coordinate.latitude;
    geoData.longitude = _coordinate.longitude;
    
    [QBRequest createGeoData:geoData successBlock:^(QBResponse *response, QBLGeoData *geoData) {
        
    } errorBlock:^(QBResponse *response) {
        
    }];

}

#pragma mark - Location

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocationCoordinate2D newCoordinate = self.locationManager.location.coordinate;
    NSLog(@"-----------------%f, %f-------", newCoordinate.latitude, newCoordinate.longitude);
    if ([self metersfromPlace:self.coordinate andToPlace:newCoordinate] > 5) {
        self.coordinate = newCoordinate;
    }
}

@end
