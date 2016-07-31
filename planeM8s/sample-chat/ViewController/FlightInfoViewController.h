//
//  FlightInfoViewController.h
//  planeM8s
//
//  Created by Erik on 12/1/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlightInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *flightTextField;
@property (weak, nonatomic) IBOutlet UITextField *departTextField;
@property (weak, nonatomic) IBOutlet UITextField *arriveTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UITextField *seatNumberTextField;

@property (strong, nonatomic) QBCOCustomObject* flightObject;

@end
