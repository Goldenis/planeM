//
//  FlightsViewController.m
//  planeM8s
//
//  Created by Erik on 11/30/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "FlightsViewController.h"
#import "FlightInfoViewController.h"
#import "DataManager.h"

@interface FlightsViewController ()
@end

@implementation FlightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSMutableArray *flights = [DataManager instance].flights;
    self.flightTextField1.text = flights.count > 0 ? ((QBCOCustomObject*)flights[0]).fields[FF_FLIGHT] : @"";
    self.flightTextField2.text = flights.count > 1 ? ((QBCOCustomObject*)flights[1]).fields[FF_FLIGHT] : @"";
    self.flightTextField3.text = flights.count > 2 ? ((QBCOCustomObject*)flights[2]).fields[FF_FLIGHT] : @"";
    self.flightTextField4.text = flights.count > 3 ? ((QBCOCustomObject*)flights[3]).fields[FF_FLIGHT] : @"";
    self.flightTextField5.text = flights.count > 4 ? ((QBCOCustomObject*)flights[4]).fields[FF_FLIGHT] : @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)clickFlight1:(id)sender {
    [self showFlightInfo:0];
}

- (IBAction)clickFlight2:(id)sender {
    [self showFlightInfo:1];
}

- (IBAction)clickFlight3:(id)sender {
    [self showFlightInfo:2];
}

- (IBAction)clickFlight4:(id)sender {
    [self showFlightInfo:3];
}

- (IBAction)clickFlight5:(id)sender {
    [self showFlightInfo:4];
}

- (void)showFlightInfo:(int)flightIndex {
    
    FlightInfoViewController *flightInfoViewController = [self.storyboard instantiateViewControllerWithIdentifier:cFlightInfoViewController];
    if ([DataManager instance].flights.count > flightIndex) {
        flightInfoViewController.flightObject = [DataManager instance].flights[flightIndex];
    }
    [self.navigationController pushViewController:flightInfoViewController animated:YES];
}

@end
