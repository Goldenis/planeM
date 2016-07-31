//
//  SignupTableViewController.h
//  planeM8s
//
//  Created by Erik on 11/28/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSeg;
@property (weak, nonatomic) IBOutlet UITextField *sexualityTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UITextField *nationalityTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *likeTextField;
@property (weak, nonatomic) IBOutlet UITextField *sportTextField;
@property (weak, nonatomic) IBOutlet UITextField *travelTextField;
@property (weak, nonatomic) IBOutlet UITextField *eatingTextField;
@property (weak, nonatomic) IBOutlet UITextField *movieTextField;

@property (weak, nonatomic) QBUUser *user;
@property BOOL readOnly;

-(NSString*) getUserData;

@end
