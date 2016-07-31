//
//  Constants.h
//  planeM8s
//
//  Created by Anton Sokolchenko on 5/29/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#ifndef planeM8s_Constants_h
#define planeM8s_Constants_h


/**
 *  UsersService
 */
static NSString *const kTestUsersTableKey = @"test_users";
static NSString *const kUserFullNameKey = @"fullname";
static NSString *const kUserLoginKey = @"login";
static NSString *const kUserPasswordKey = @"password";

/**
 *  UsersDataSource
 */
static NSString *const kUserTableViewCellIdentifier = @"TestUsersCell";

/**
 *  ServicesManager
 */
static NSString *const kChatCacheNameKey = @"planeM8s";
static NSString *const kContactListCacheNameKey = @"splaneM8s-contacts";
static NSString *const kLastActivityDateKey = @"last_activity_date";

/**
 *  LoginTableViewController
 */
static NSString *const kGoToDialogsSegueIdentifier = @"goToDialogs";

/**
 *  DialogsViewController
 */
static const NSUInteger kDialogsPageLimit = 10;

static NSString *const kGoToEditDialogSegueIdentifier = @"goToEditDialog";

/**
 *  DialogInfoTableViewController
 */
static NSString *const kGoToAddOccupantsSegueIdentifier = @"goToAddOccupants";

/**
 *  EditDialogTableViewController
 */
static NSString *const kGoToChatSegueIdentifier = @"goToChat";

/**
 * Dialog keys
 */
static NSString *const kPushNotificationDialogIdentifierKey = @"dialog_id";
static NSString *const kPushNotificationDialogMessageKey = @"message";

static NSString *const kWelcomeControllerIdentifier = @"WelcomeController";
static NSString *const kMainControllerIdentifier = @"MainController";

static NSString *const kProfileEditTableController = @"ProfileEditTableController";
static NSString *const kProfileViewTableController = @"ProfileViewTableController";

static NSString *const cUserPhotoViewController = @"UserPhotoViewController";
static NSString *const cProfileViewController = @"ProfileViewController";
static NSString *const cChatViewController = @"ChatViewController";
static NSString *const cFlightInfoViewController = @"FlightInfoViewController";
static NSString *const cUsersViewController = @"UsersViewController";

static NSString *const kGeoDataManagerDidUpdateData = @"GeoDataManagerDidUpdateData";
static NSString *const kUserCollectionCell = @"UserCollectionCell";

#define     USERID              @"id"
#define     PHOTO               @"photo"
#define     USERNAME            @"username"
#define     PASSWORD            @"password"
#define     REPASSWORD          @"repassword"
#define     EMAIL               @"email"
#define     GENDER              @"gender"
#define     SEXUALITY           @"sexuality"
#define     BIRTHDAY            @"birthday"
#define     NATIONALITY         @"nationality"
#define     AGERANGE            @"agerange"
#define     ILIKE               @"ilike"
#define     SPORTING            @"sporting"
#define     TRAVEL              @"travel"
#define     EATING              @"eating"
#define     MOVIE               @"movie"

#define     FLIGHT_CLASS        @"Flight"
#define     FF_USERID           @"userID"
#define     FF_DATE             @"Date"
#define     FF_FLIGHT           @"Flight"
#define     FF_DEPART           @"Depart"
#define     FF_ARRIVE           @"Arrive"
#define     FF_SEAT             @"SeatNumber"

#endif
