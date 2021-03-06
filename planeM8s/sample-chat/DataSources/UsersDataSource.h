//
//  UsersDataSource.h
//  planeM8s
//
//  Created by Anton Sokolchenko on 5/28/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Users datasource for table view.
 */
@interface UsersDataSource : NSObject<UICollectionViewDataSource>

- (instancetype)initWithUsers:(NSArray *)users;

/**
 *  Adds users to datasource.
 *
 *  @param users NSArray of users to add.
 */
- (void)addUsers:(NSArray *)users;

/**
 *  Default: empty []
 *  Excludes users with given ids from data source
 */

/**
 *  @return Array of QBUUser instances
 */
@property (nonatomic, strong, readonly) NSArray *users;
@property (nonatomic, strong) NSArray *excludeUsersIDs;

@end
