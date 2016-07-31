//
//  DataManager.h
//  planeM8s
//
//  Created by Quickblox Team on 9/19/12.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//
//
// This class presents storage for user's checkins
//

#import <MailCore/MailCore.h>

extern NSString * const GeoDataManagerDidUpdateData;

@interface DataManager : NSObject

@property (nonatomic, strong) NSMutableArray *flights;
@property (nonatomic, strong) NSMutableDictionary *avatars;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSArray *geoUsers;

@property (nonatomic, strong) MCOIMAPSession *imapSession;

@property int messageCount;

-(void)receiveMails:(NSString*)email password:(NSString*)password completed:(void (^)())completionBlock error:(void (^)(NSError * error))errorBlock;

+ (instancetype)instance;

@end