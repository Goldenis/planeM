//
//  UserPhotoViewController.m
//  planeM8s
//
//  Created by Erik on 11/30/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "UserPhotoViewController.h"
#import "ProfileViewController.h"
#import "ChatViewController.h"
#import "ServicesManager.h"
#import "DataManager.h"

#import <MessageUI/MessageUI.h>

@interface UserPhotoViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation UserPhotoViewController {
    MFMailComposeViewController *mailComposer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *bid = [NSString stringWithFormat:@"%d", (int)self.selectedUser.blobID];
    if ([DataManager instance].avatars[bid]) {
        self.photoImageView.image = [DataManager instance].avatars[bid];
    } else {
        [self.loadingIcon startAnimating];
        [QBRequest downloadFileWithID:self.selectedUser.blobID successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {
            [self.loadingIcon stopAnimating];
            [DataManager instance].avatars[bid] = [UIImage imageWithData:fileData];
            self.photoImageView.image = [DataManager instance].avatars[bid];
        } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
        } errorBlock:^(QBResponse * _Nonnull response) {
            [self.loadingIcon stopAnimating];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)clickProfileView:(id)sender {
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:cProfileViewController];
    profileViewController.readOnly = YES;
    profileViewController.user = self.selectedUser;
    
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (IBAction)clickMail:(id)sender {
    mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:@"Hello from California!"];
    // Set up the recipients.
    NSArray *toRecipients = [NSArray arrayWithObjects:@"first@example.com", nil];
    
    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
    
    NSArray *bccRecipients = [NSArray arrayWithObjects:@"four@example.com", nil];
    
    [mailComposer setToRecipients:toRecipients];
    
    [mailComposer setCcRecipients:ccRecipients];
    
    [mailComposer setBccRecipients:bccRecipients];
    
    // Attach an image to the email.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ipodnano" ofType:@"png"];
    
    NSData *myData = [NSData dataWithContentsOfFile:path];
    
    [mailComposer addAttachmentData:myData mimeType:@"image/png" fileName:@"ipodnano"];
    
    // Fill out the email body text.
    
    NSString *emailBody = @"It is raining in sunny California!";
    
    [mailComposer setMessageBody:emailBody isHTML:NO];
    
    // Present the mail composition interface.
    [self presentViewController:mailComposer animated:YES completion:nil];
}

- (IBAction)clickChat:(id)sender {
    __weak __typeof(self) weakSelf = self;
    [[ServicesManager instance].chatService createPrivateChatDialogWithOpponent:self.selectedUser completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        if( !response.success && createdDialog == nil ) {
            [SVProgressHUD showErrorWithStatus:@"Can not create dialog"];
        } else {
            ChatViewController *chatController = [self.storyboard instantiateViewControllerWithIdentifier:cChatViewController];
            chatController.dialog = createdDialog;
            [[weakSelf navigationController] pushViewController:chatController animated:YES];
        }
    }];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result) {
        NSLog(@"Result : %d",result);
    }
    if (error) {
        NSLog(@"Error : %@",error);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
