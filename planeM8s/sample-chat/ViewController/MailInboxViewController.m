//
//  MailInboxViewController.m
//  iOS UI Test
//
//  Created by Jonathan Willing on 4/8/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "MailInboxViewController.h"
#import <MailCore/MailCore.h>
#import "FXKeychain.h"
#import "MCTMsgViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "MCTTableViewCell.h"

#import "ServicesManager.h"
#import "DataManager.h"

#define CLIENT_ID @"the-client-id"
#define CLIENT_SECRET @"the-client-secret"
#define KEYCHAIN_ITEM_NAME @"MailCore OAuth 2.0 Token"

#define NUMBER_OF_MESSAGES_TO_LOAD		10

static NSString *mailCellIdentifier = @"MailCell";
static NSString *inboxInfoIdentifier = @"InboxStatusCell";

@interface MailInboxViewController ()
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) NSMutableDictionary *messagePreviews;
@end

@implementation MailInboxViewController {
    MFMailComposeViewController *mailComposer;
}

- (void)viewDidLoad {
	[super viewDidLoad];

    UIBarButtonItem* btnSend = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStyleDone target:self action:@selector(sendMail:)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:btnSend, nil];
    mailComposer.mailComposeDelegate = self;
    
    self.messages = [DataManager instance].messages;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([DataManager instance].imapSession == nil) {
    
        NSString *email = [ServicesManager instance].currentUser.email;
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Email Password"
                                              message:email
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = NSLocalizedString(@"PasswordPlaceholder", @"Password");
             textField.secureTextEntry = YES;
         }];
        
        UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [SVProgressHUD show];
                                           __weak __typeof(self)weakSelf = self;
                                           NSString *password = alertController.textFields.lastObject.text;
                                           [[DataManager instance] receiveMails:email password:password completed:^{
                                               weakSelf.messages = [DataManager instance].messages;
                                               [weakSelf.tableView reloadData];
                                               [SVProgressHUD dismiss];
                                           } error:^(NSError *error) {
                                               [SVProgressHUD dismiss];
                                           }];
                                       }];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                       }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 1)
	{
		if ((int)self.messages.count >= 0)
			return 1;
		
		return 0;
	}
	
	return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section)
	{
		case 0:
		{
			MCTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mailCellIdentifier forIndexPath:indexPath];
			MCOIMAPMessage *message = self.messages[indexPath.row];
            cell.lblSenderName.text = message.header.from.displayName;
			cell.lblSubject.text = message.header.subject;
            NSDateFormatter* dateFormatter;
            dateFormatter.dateStyle = NSDateIntervalFormatterMediumStyle;
            NSString* strTime = [dateFormatter stringFromDate:message.header.receivedDate];
            cell.lblTime.text = strTime;
            if (message.flags == MCOMessageFlagSeen) {
                cell.flagImageView.hidden = true;
            }
            
			NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
			NSString *cachedPreview = self.messagePreviews[uidKey];
			
			if (cachedPreview)
			{
				cell.lblContent.text = cachedPreview;
			}
			else
			{
				cell.messageRenderingOperation = [[DataManager instance].imapSession plainTextBodyRenderingOperationWithMessage:message
																									   folder:@"INBOX"];
				
				[cell.messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
					cell.lblContent.text = plainTextBodyString;
					cell.messageRenderingOperation = nil;
					self.messagePreviews[uidKey] = plainTextBodyString;
				}];
			}
			
			return cell;
			break;
		}
			
		case 1:
		{
			UITableViewCell *cell =
			[tableView dequeueReusableCellWithIdentifier:inboxInfoIdentifier];
			
			if (!cell)
			{
				cell =
				[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:inboxInfoIdentifier];
				
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				cell.textLabel.textAlignment = NSTextAlignmentCenter;
				cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
			}

            return cell;
			break;
		}
			
		default:
			return nil;
			break;
	}
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.section)
	{
		case 0:
		{
			MCOIMAPMessage *msg = self.messages[indexPath.row];
            ((MCTTableViewCell*)[tableView cellForRowAtIndexPath:indexPath]).flagImageView.hidden = true;
            MCTMsgViewController *vc = [[MCTMsgViewController alloc] init];
			vc.folder = @"INBOX";
			vc.message = msg;
			vc.session = [DataManager instance].imapSession;
			[self.navigationController pushViewController:vc animated:YES];

            MCOIMAPOperation *msgOperation=[[DataManager instance].imapSession storeFlagsOperationWithFolder:@"INBOX"
                                                                                      uids:[MCOIndexSet indexSetWithIndex:msg.uid]
                                                                                      kind:MCOIMAPStoreFlagsRequestKindAdd flags:MCOMessageFlagSeen];
            
            [msgOperation start:^(NSError * error)
            {
                //here I get 2 or 3 , no Idea whats going here.
                
                NSLog(@"selected message flags %u UID is %u",msg.flags | MCOMessageFlagSeen,msg.uid );
            }];
			break;
		}
			
		case 1:
		{
		}
			
		default:
			break;
	}

}


-(void)sendMail:(id)sender{
    
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
