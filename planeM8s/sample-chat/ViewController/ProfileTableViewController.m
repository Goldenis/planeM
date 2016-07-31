//
//  SignupTableViewController.m
//  planeM8s
//
//  Created by Erik on 11/28/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "PopupPickView.h"
#import "SBJsonParser.h"
#import "IQKeyboardManager.h"

@interface ProfileTableViewController () <PopupPickViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *profileData;
@property (nonatomic, strong) PopupPickView *pickview;
@property (nonatomic, strong) NSDictionary *dicTextField;

@end

@implementation ProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.profileData = [[NSMutableDictionary alloc] init];
    
    self.dicTextField = @{ SEXUALITY: self.sexualityTextField,
                       AGERANGE: self.ageTextField,
                       ILIKE: self.likeTextField,
                       SPORTING: self.sportTextField,
                       TRAVEL: self.travelTextField,
                       EATING: self.eatingTextField,
                       MOVIE: self.movieTextField,
                       BIRTHDAY: self.birthdayTextField };
    
    if (self.user) {
        self.usernameTextField.text = self.user.login;
        self.passwordTextField.text = self.user.password;
        self.repasswordTextField.text = self.user.password;
        self.emailTextField.text = self.user.email;
        
        self.profileData = [[[SBJsonParser alloc] init] objectWithString:self.user.customData];
        self.profileData[BIRTHDAY] = [NSDate dateWithTimeIntervalSinceNow:[self.profileData[BIRTHDAY] doubleValue]];
        
        self.genderSeg.selectedSegmentIndex = [self.profileData[GENDER] integerValue];
        self.sexualityTextField.text = [PopupPickView getValueToString:SEXUALITY value:[self.profileData[SEXUALITY] intValue]];
        self.birthdayTextField.text = [PopupPickView getDateToString:self.profileData[BIRTHDAY]];
        self.nationalityTextField.text = self.profileData[NATIONALITY];
        self.ageTextField.text = [PopupPickView getValueToString:AGERANGE value:[self.profileData[AGERANGE] intValue]];
        self.likeTextField.text = [PopupPickView getValueToString:ILIKE value:[self.profileData[ILIKE] intValue]];
        self.sportTextField.text = [PopupPickView getValueToString:SPORTING value:[self.profileData[SPORTING] intValue]];
        self.travelTextField.text = [PopupPickView getValueToString:TRAVEL value:[self.profileData[TRAVEL] intValue]];
        self.eatingTextField.text = [PopupPickView getValueToString:EATING value:[self.profileData[EATING] intValue]];
        self.movieTextField.text = [PopupPickView getValueToString:MOVIE value:[self.profileData[MOVIE] intValue]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hidePickup)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [self hidePickup];
}

-(void)hidePickup {
    [self.pickview remove];
}

-(NSString*) getUserData {
    return [NSString stringWithFormat:@"{\"%@\":%d, \"%@\":%d, \"%@\":%f, \"%@\":\"%@ \", \"%@\":%d, \"%@\":%d, \"%@\":%d, \"%@\":%d, \"%@\":%d, \"%@\":%d}",
                       GENDER, (int)self.genderSeg.selectedSegmentIndex,
                       SEXUALITY, [(NSNumber*)self.profileData[SEXUALITY] intValue],
                       BIRTHDAY, (double)((NSDate*)self.profileData[BIRTHDAY]).timeIntervalSinceNow,
                       NATIONALITY, [self.nationalityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                       AGERANGE, [(NSNumber*)self.profileData[AGERANGE] intValue],
                       ILIKE, [(NSNumber*)self.profileData[ILIKE] intValue],
                       SPORTING, [(NSNumber*)self.profileData[SPORTING] intValue],
                       TRAVEL, [(NSNumber*)self.profileData[TRAVEL] intValue],
                       EATING, [(NSNumber*)self.profileData[EATING] intValue],
                       MOVIE, [(NSNumber*)self.profileData[MOVIE] intValue] ];
}

#pragma mark PopupPickViewDelegate

-(void)doneBtnClick:(PopupPickView *)popupPickView {
    
    NSString *name = popupPickView.name;
    self.profileData[name] = [popupPickView getSelectedValue];
    ((UITextField*)self.dicTextField[name]).text = [popupPickView getSelectedString];
}

#pragma mark - Table view data source

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.readOnly) return;
    
    NSArray *keys = @[ @"", @"", @"", @"", @"", SEXUALITY, BIRTHDAY, @"", AGERANGE, ILIKE, SPORTING, TRAVEL, EATING, MOVIE ];
    NSString *key = keys[indexPath.row];
    if ([key isEqualToString:@""]) return;
    
    [self.view endEditing:YES];
    [self.pickview remove];
    
    if ([key isEqualToString:BIRTHDAY]) {
        NSDate *date = _profileData[BIRTHDAY];
        self.pickview=[[PopupPickView alloc] initDatePickWithDate:(date?date:[NSDate date]) datePickerMode:UIDatePickerModeDate];
        self.pickview.name = BIRTHDAY;
    } else {
        NSNumber *number = self.profileData[key];
        self.pickview=[[PopupPickView alloc] initPickviewWithName:key selectedRow:(number?number.intValue:0)];
    }
    self.pickview.delegate = self;
    [self.pickview show];
}

@end
