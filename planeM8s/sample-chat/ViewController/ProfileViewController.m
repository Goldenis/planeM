//
//  SignupViewController.m
//  planeM8s
//
//  Created by Erik on 11/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileTableViewController.h"
#import "ServicesManager.h"
#import "DataManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ProfileViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation ProfileViewController {
    ProfileTableViewController *_profileTableViewController;
}

- (UIImagePickerController *)imagePicker {
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.allowsEditing = NO;
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return _imagePicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.avaterImageView.layer.cornerRadius = [UIScreen mainScreen].bounds.size.width*0.27f/2;
    self.avaterImageView.clipsToBounds = YES;
    self.avaterImageView.layer.borderWidth = 2.0f;
    self.avaterImageView.layer.borderColor = [UIColor grayColor].CGColor;
    
    if (self.readOnly == false) {
        if (self.user == nil && [ServicesManager instance].currentUser) {
            self.user = [ServicesManager instance].currentUser;
        }
        if (self.user == nil) {
            self.leftButton.hidden = NO;
            self.rightButton.hidden = NO;
        } else {
            self.centerButton.hidden = NO;
        }
        _profileTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:kProfileEditTableController];
    } else {
        _profileTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:kProfileViewTableController];
    }
    
    if (self.user) {
        _profileTableViewController.user = self.user;
        
        NSString *bid = [NSString stringWithFormat:@"%d", (int)self.user.blobID];
        if ([DataManager instance].avatars[bid]) {
            self.avaterImageView.image = [DataManager instance].avatars[bid];
        } else {
            [self.loadingIcon startAnimating];
            __weak __typeof(self)weakSelf = self;
            [QBRequest downloadFileWithID:self.user.blobID successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {
                [weakSelf.loadingIcon stopAnimating];
                [DataManager instance].avatars[bid] = [UIImage imageWithData:fileData];
                weakSelf.avaterImageView.image = [DataManager instance].avatars[bid];
            } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
            } errorBlock:^(QBResponse * _Nonnull response) {
                [weakSelf.loadingIcon stopAnimating];
            }];
        }
    }
    
    _profileTableViewController.readOnly = self.readOnly;
    _profileTableViewController.view.frame = self.container.bounds;
    [self addChildViewController:_profileTableViewController];
    [self.container addSubview:_profileTableViewController.view];
    
    if (self.readOnly) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.view.backgroundColor = [UIColor clearColor];
    } else {
        self.navigationController.navigationBar.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showWelcome {
    [SVProgressHUD dismiss];
    UIViewController *welcomeController = [self.storyboard instantiateViewControllerWithIdentifier:kWelcomeControllerIdentifier];
    self.view.window.rootViewController = welcomeController;
}

- (void) uploadAvater:(QBUUser*)user {
    
    // Upload file to QuickBlox cloud
    
    CGRect bounds = CGRectMake(0, 0, 100, 100);
    UIGraphicsBeginImageContext(bounds.size);
    [self.avaterImageView.image drawInRect:bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(image);
    
    [[NSUserDefaults standardUserDefaults] setValue:user.password forKey:@"password"];

    __weak __typeof(self)weakSelf = self;
    
    [QBRequest TUploadFile:imageData fileName:@"avatar" contentType:@"image/png" isPublic:NO
              successBlock:^(QBResponse *response, QBCBlob *blob) {
                  
                  QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
                  updateParameters.blobID = blob.ID;
                  
                  [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
                      if (self.user) {
                          [SVProgressHUD showSuccessWithStatus:@"Updated"];
                      } else {
                          [weakSelf showWelcome];
                      }
                  } errorBlock:^(QBResponse * _Nonnull response) {
                      if (self.user) {
                          [SVProgressHUD showSuccessWithStatus:@"Uploading error"];
                      } else {
                          [weakSelf showWelcome];
                      }
                  }];
              } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                  [SVProgressHUD showProgress:status.percentOfCompletion status:@"Uploading image"];
              } errorBlock:^(QBResponse *response) {
                  [weakSelf showWelcome];
              }
     ];
}

- (IBAction)clickSave:(id)sender {
    NSString *username = [_profileTableViewController.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = [_profileTableViewController.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *repassword = [_profileTableViewController.repasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *email = [_profileTableViewController.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // check username
    if ([username isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"Please enter username"];
        return;
    }
    
    // check password
    if (password.length < 8) {
        [SVProgressHUD showInfoWithStatus:@"Passwords must have at least 8 characters."];
        return;
    }
    
    // check password
    if ([password isEqualToString:repassword] == false) {
        [SVProgressHUD showInfoWithStatus:@"These passwords don't match."];
        return;
    }
    
    // check email
    if ([email isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"Please enter the email address"];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    if (self.user == nil) {
        QBUUser *user = [QBUUser new];
        user.login = username;
        user.password = password;
        user.email = email;
        user.customData = [_profileTableViewController getUserData];
        
        [SVProgressHUD showWithStatus:@"Signing up"];
        
        [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
            [QBRequest logInWithUserLogin:username password:password successBlock:^(QBResponse *response, QBUUser *user) {
                [weakSelf uploadAvater:user];
            } errorBlock:^(QBResponse *response) {
                [SVProgressHUD showErrorWithStatus:@"Login error"];
            }];
            
        } errorBlock:^(QBResponse *response) {
            [SVProgressHUD showErrorWithStatus:@"Signup error"];
        }];
    } else {
        
        QBUpdateUserParameters * parameters = [QBUpdateUserParameters new];
        parameters.login = username;
        parameters.oldPassword = [ServicesManager instance].currentUser.password;
        parameters.password = password;
        parameters.email = email;
        parameters.customData = [_profileTableViewController getUserData];
        
        [SVProgressHUD showWithStatus:@"Updating..."];
        
        [QBRequest updateCurrentUser:parameters successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
            [weakSelf uploadAvater:user];
        } errorBlock:^(QBResponse * _Nonnull response) {
            [SVProgressHUD showErrorWithStatus:@"Update error"];
        }];
    }
}

- (IBAction)clickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickAvatar:(id)sender {
    if (self.readOnly == false ) {
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

#pragma mark UIImagePickerControllerDelegate

// when photo is selected from gallery - > upload it to server
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.avaterImageView.image = [info valueForKey:UIImagePickerControllerOriginalImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

@end
