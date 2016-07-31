//
//  MailInboxViewController.h
//  iOS UI Test
//
//  Created by Jonathan Willing on 4/8/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface MailInboxViewController : UITableViewController <MFMailComposeViewControllerDelegate>

- (IBAction)showSettingsViewController:(id)sender;
@property (nonatomic, strong) NSMutableArray* filterAddresses;

@end
