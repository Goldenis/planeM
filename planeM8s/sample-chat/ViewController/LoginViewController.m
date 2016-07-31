//
//  LoginViewController.m
//
//  Created by Erik on 11/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "LoginViewController.h"
#import "ServicesManager.h"
#import "ProfileViewController.h"
#import "IQKeyboardManager.h"
#import "WelcomeViewController.h"
#import "ChatViewController.h"

@interface LoginViewController ()<NotificationServiceDelegate>
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([ServicesManager instance].currentUser) {        
        ServicesManager.instance.currentUser.password = [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
        [self login:ServicesManager.instance.currentUser];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) login:(QBUUser*)user {
    [SVProgressHUD showWithStatus:@"Logging in..."];
    
    __weak __typeof(self)weakSelf = self;
    [ServicesManager.instance logInWithUser:user completion:^(BOOL success, NSString *errorMessage) {
        if (success) {
            __typeof(self) strongSelf = weakSelf;
            if (ServicesManager.instance.notificationService.pushDialogID != nil) {
                [ServicesManager.instance.notificationService handlePushNotificationWithDelegate:self];
            } else {
                WelcomeViewController *welcomeController = [self.storyboard instantiateViewControllerWithIdentifier:kWelcomeControllerIdentifier];
                weakSelf.view.window.rootViewController = welcomeController;
            }
        } else {
            [SVProgressHUD showErrorWithStatus:@"Can not login"];
        }
    }];
}

- (IBAction)clickLogin:(id)sender {
    
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([username isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"Please enter username"];
        return;
    }
    
    QBUUser *user = [QBUUser user];
    user.login = username;
    user.password = self.passwordTextField.text;
    [[NSUserDefaults standardUserDefaults] setValue:user.password forKey:@"password"];
    [self login:user];
}

- (IBAction)clickSignup:(id)sender {
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:cProfileViewController];
    [self presentViewController:profileViewController animated:YES completion:nil];
}

- (void)notificationServiceDidStartLoadingDialogFromServer {
    [SVProgressHUD showWithStatus:@"Loading dialog..."];
}

- (void)notificationServiceDidFinishLoadingDialogFromServer {
    [SVProgressHUD dismiss];
}

- (void)notificationServiceDidSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    
    UIViewController *viewController = (UIViewController *)self.view.window.rootViewController;
    
    ChatViewController *chatController = (ChatViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:cChatViewController];
    chatController.dialog = chatDialog;
    
    NSMutableArray* mutableOccupants = [chatDialog.occupantIDs mutableCopy];
    [mutableOccupants removeObject:@([ServicesManager instance].currentUser.ID)];
    NSNumber* opponentID = [mutableOccupants firstObject];
    QBUUser* opponentUser = [[ServicesManager instance].usersService.usersMemoryStorage userWithID:[opponentID unsignedIntegerValue]];
    if (opponentUser == nil) {
        [SVProgressHUD show];
        [QBRequest userWithID:opponentID.integerValue successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
            [SVProgressHUD dismiss];
            [[ServicesManager instance].usersService.usersMemoryStorage addUser:user];
            [viewController presentViewController:chatController animated:YES completion:nil];
        } errorBlock:^(QBResponse * _Nonnull response) {
            [SVProgressHUD dismiss];
        }];
    } else {
        [viewController presentViewController:chatController animated:YES completion:nil];
    }
}

@end
