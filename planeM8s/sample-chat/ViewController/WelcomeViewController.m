//
//  WelcomeViewController.m
//  planeM8s
//
//  Created by Erik on 11/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "WelcomeViewController.h"
#import "GeoDataManager.h"
#import "ServicesManager.h"
#import "DataManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface WelcomeViewController ()
@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    QBUUser *user = [ServicesManager instance].currentUser;
    self.usernameLabel.text = user.fullName ? user.fullName : user.login;
    [self updateMessage];
    [GeoDataManager instance];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [SVProgressHUD show];
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[NSNumber numberWithInteger:[ServicesManager instance].currentUser.ID] forKey:FF_USERID];
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest objectsWithClassName:FLIGHT_CLASS extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSMutableArray *delIDs = [[NSMutableArray alloc] init];
        NSDate *today = [NSDate date];
        NSMutableArray *newObjects = [[NSMutableArray alloc] init];
        for (QBCOCustomObject *obj in objects) {
            if (obj.userID == [ServicesManager instance].currentUser.ID) {
                NSDate *date = [NSDate dateWithTimeIntervalSinceNow:[((NSNumber*)obj.fields[FF_DATE]) doubleValue]];
                if ([date compare:today] == NSOrderedAscending) {
                    [delIDs addObject:obj.ID];
                } else {
                    [newObjects addObject:obj];
                }
            }
        }
        
        [QBRequest deleteObjectsWithIDs:delIDs className:FLIGHT_CLASS
                           successBlock:^(QBResponse *response, NSArray *deletedObjectsIDs, NSArray *notFoundObjectsIDs, NSArray *wrongPermissionsObjectsIDs) {
                               // response processing
                           } errorBlock:^(QBResponse *error) {
                               // error handling
                           }];
        
        [DataManager instance].flights = newObjects;
 //       [[DataManager instance] receiveMails:^{
            [weakSelf updateMessage];
            [SVProgressHUD dismiss];
 //       } error:^(NSError *error) {
 //           [SVProgressHUD dismiss];
 //       }];
    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD showErrorWithStatus:@"connection error"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateMessage {
    self.messageLabel.text = [NSString stringWithFormat:@"You have new %d messages\n\nThere are %d- planeM8s on your\nupcoming flights waiting to\nconnect with you", (int)[DataManager instance].messages.count, (int)[DataManager instance].flights.count];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITabBarController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:kMainControllerIdentifier];
    for (UITabBarItem *item in tabBarController.tabBar.items) {
        item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    self.view.window.rootViewController = tabBarController;
}
@end
