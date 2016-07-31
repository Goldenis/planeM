//
//  FlightInfoViewController.m
//  planeM8s
//
//  Created by Erik on 12/1/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "FlightInfoViewController.h"
#import "UsersViewController.h"
#import "PopupPickView.h"
#import "DataManager.h"
#import "ServicesManager.h"

@interface FlightInfoViewController ()  <PopupPickViewDelegate>
@property (nonatomic, strong) PopupPickView *pickview;
@property (strong, nonatomic) NSDate *date;
@end

@implementation FlightInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.flightObject) {
        self.date = [NSDate dateWithTimeIntervalSinceNow:[((NSNumber*)self.flightObject.fields[FF_DATE]) doubleValue]];
        self.dateTextField.text = [PopupPickView getDateToString:self.date];
        self.flightTextField.text = self.flightObject.fields[FF_FLIGHT];
        self.departTextField.text = self.flightObject.fields[FF_DEPART];
        self.arriveTextField.text = self.flightObject.fields[FF_ARRIVE];
        self.timeTextField.text = [PopupPickView getTimeToString:self.date];
        self.seatNumberTextField.text = self.flightObject.fields[FF_SEAT];
    } else {
        self.date = [NSDate date];
        self.dateTextField.text = [PopupPickView getDateToString:self.date];
        self.timeTextField.text = [PopupPickView getTimeToString:self.date];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hidePickup)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [self hidePickup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)hidePickup {
    [self.pickview remove];
}

- (BOOL) getData {
    NSString *flight = [self.flightTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([flight isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"Please enter flight"];
        return NO;
    }
    
    [self.flightObject.fields setObject:[NSNumber numberWithDouble:self.date.timeIntervalSinceNow] forKey:FF_DATE];
    [self.flightObject.fields setObject:flight forKey:FF_FLIGHT];
    [self.flightObject.fields setObject:[self.departTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:FF_DEPART];
    [self.flightObject.fields setObject:[self.arriveTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:FF_ARRIVE];
    [self.flightObject.fields setObject:self.seatNumberTextField.text forKey:FF_SEAT];
    return YES;
}

- (void) save:(void (^)())callback {
    
    if (self.flightObject) {
        if ([self getData] == NO) return;
        
        [SVProgressHUD show];
        [QBRequest updateObjects:@[self.flightObject] className:FLIGHT_CLASS successBlock:^(QBResponse *response, NSArray *objects, NSArray *notFoundObjectsIds) {
            [SVProgressHUD dismiss];
            callback();
        } errorBlock:^(QBResponse *error) {
            [SVProgressHUD showInfoWithStatus:@"Response error"];
        }];
    } else {
        self.flightObject = [QBCOCustomObject customObject];
        if ([self getData] == NO) return;
        
        [SVProgressHUD show];
        [QBRequest createObjects:@[self.flightObject] className:FLIGHT_CLASS successBlock:^(QBResponse *response, NSArray *objects) {
            [SVProgressHUD dismiss];
            self.flightObject = objects[0];
            [[DataManager instance].flights addObject:self.flightObject];
            callback();
        } errorBlock:^(QBResponse *error) {
            self.flightObject = nil;
            [SVProgressHUD showInfoWithStatus:@"Response error"];
        }];
    }
}

- (IBAction)clickMyFlight:(id)sender {
    [self save:^{
        
        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        [getRequest setObject:self.flightObject.fields[FF_FLIGHT] forKey:FF_FLIGHT];
        
        __weak __typeof(self)weakSelf = self;
        [QBRequest objectsWithClassName:FLIGHT_CLASS extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            [SVProgressHUD dismiss];
            
            NSMutableArray *ids = [[NSMutableArray alloc] init];
            for (QBCOCustomObject *object in objects) {
                [ids addObject:[NSNumber numberWithInteger:object.userID]];
            }
            
            UsersViewController *usersViewController = [self.storyboard instantiateViewControllerWithIdentifier:cUsersViewController];
            usersViewController.userIDs = ids;
            [weakSelf.navigationController pushViewController:usersViewController animated:YES];
            
        } errorBlock:^(QBResponse *response) {
            [SVProgressHUD showErrorWithStatus:@"connection error"];
        }];
    }];
}

- (IBAction)showDatePicker:(id)sender {
    [self showPicker:UIDatePickerModeDate];
}

- (IBAction)showTimePicker:(id)sender {
    [self showPicker:UIDatePickerModeTime];
}

- (void)showPicker:(UIDatePickerMode)pickerMode {
    [self.view endEditing:YES];
    [self.pickview remove];
    
    self.pickview=[[PopupPickView alloc] initDatePickWithDate:self.date datePickerMode:pickerMode];
    self.pickview.name = pickerMode==UIDatePickerModeDate ? @"date" : @"time";
    
    self.pickview.delegate = self;
    [self.pickview show];
}

#pragma mark PopupPickViewDelegate

-(void)doneBtnClick:(PopupPickView *)popupPickView {
    self.date = (NSDate*)[popupPickView getSelectedValue];
    if ([popupPickView.name isEqualToString:@"date"]) {
        self.dateTextField.text = [popupPickView getSelectedString];
    } else {
        self.timeTextField.text = [popupPickView getSelectedString];
    }
}

@end
