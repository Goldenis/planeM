//
//  AppDelegate.m
//  planeM8s
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "AppDelegate.h"
#import "ServicesManager.h"
#import "DataManager.h"
#import "ChatViewController.h"

const NSUInteger kApplicationID = 29566;
NSString *const kAuthKey        = @"aRqm7cHOTsrURXL";
NSString *const kAuthSecret     = @"u7zRap5ded5R7hX";
NSString *const kAcconuntKey    = @"iYaYyznBqjuXjSvA5hex";

@interface AppDelegate ()

@end

@implementation AppDelegate 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    [QBSettings setApplicationID:kApplicationID];
    [QBSettings setAuthKey:kAuthKey];
    [QBSettings setAuthSecret:kAuthSecret];
    [QBSettings setAccountKey:kAcconuntKey];
    
    // Enables Quickblox REST API calls debug console output
    [QBSettings setLogLevel:QBLogLevelDebug];
    
    // Enables detailed XMPP logging in console output
    [QBSettings enableXMPPLogging];
    
    // app was launched from push notification, handling it
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        ServicesManager.instance.notificationService.pushDialogID = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey][kPushNotificationDialogIdentifierKey];
    }

//    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
//    UIUserNotificationSettings *setttings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
//    [application registerUserNotificationSettings:setttings];
//    [application registerForRemoteNotifications];
//    
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1]];
    
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:236/255.0f green:78/255.0f blue:27/255.0f alpha:1]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // subscribing for push notifications
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        //
    } errorBlock:^(QBResponse *response) {
        //
    }];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // failed to register push
    NSLog(@"Push failed to register with error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification userInfo=%@", userInfo);
    
    if ([application applicationState] == UIApplicationStateInactive)
    {
        NSString *dialogID = userInfo[kPushNotificationDialogIdentifierKey];
        if (dialogID != nil) {
            NSString *dialogWithIDWasEntered = [ServicesManager instance].currentDialogID;
            if ([dialogWithIDWasEntered isEqualToString:dialogID]) return;
            
            ServicesManager.instance.notificationService.pushDialogID = dialogID;
            [ServicesManager.instance.notificationService handlePushNotificationWithDelegate:self];
        }
    }
//    else {
//        NSString *dialogID = userInfo[kPushNotificationDialogIdentifierKey];
//        if (dialogID != nil) {
//            NSString *dialogWithIDWasEntered = [ServicesManager instance].currentDialogID;
//            if ([dialogWithIDWasEntered isEqualToString:dialogID]) return;
//            
//            [DataManager instance].messageCount++;
//            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[DataManager instance].messageCount];
//        }
//    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Logout from chat
    //
    if ([ServicesManager instance].currentUser)
        [ServicesManager.instance.chatService disconnectWithCompletionBlock:nil];
//    [DataManager instance].messageCount = 0;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	
    // Login to QuickBlox Chat
    //
    
    if ([ServicesManager instance].currentUser)
        [ServicesManager.instance.chatService connectWithCompletionBlock:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - NotificationServiceDelegate protocol

- (void)notificationServiceDidSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    
    UIViewController *viewController = (UIViewController *)self.window.rootViewController;
    
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
