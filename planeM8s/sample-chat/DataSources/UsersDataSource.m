//
//  UsersDataSource.m
//  planeM8s
//
//  Created by Anton Sokolchenko on 5/28/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "UsersDataSource.h"
#import "ServicesManager.h"
#import "UserCollectionViewCell.h"
#import "DataManager.h"
#import "GeoDataManager.h"

@interface UsersDataSource()
@property (nonatomic, copy) NSArray *customUsers;
@end

@implementation UsersDataSource

- (instancetype)initWithUsers:(NSArray *)users {
	self = [super init];
	if( self) {
		_excludeUsersIDs = @[];
		_customUsers =  [[users copy] sortedArrayUsingComparator:^NSComparisonResult(QBUUser *obj1, QBUUser *obj2) {
			return [obj1.login compare:obj2.login options:NSNumericSearch];
		}];
		_users = _customUsers == nil ? [[ServicesManager instance].usersService.usersMemoryStorage unsortedUsers] : _customUsers;
	}
	return self;
	
}
- (void)addUsers:(NSArray *)users {
	NSMutableArray *mUsers;
	if( _users != nil ){
		mUsers = [_users mutableCopy];
	}
	else {
		mUsers = [NSMutableArray array];
	}
	[mUsers addObjectsFromArray:users];
	_users = [mUsers copy];
}

- (instancetype)init {
	return [self initWithUsers:[[ServicesManager instance].usersService.usersMemoryStorage unsortedUsers]];
}

- (void)setExcludeUsersIDs:(NSArray *)excludeUsersIDs {
	if  (excludeUsersIDs == nil) {
		_users = self.customUsers == nil ? self.customUsers : [[ServicesManager instance].usersService.usersMemoryStorage unsortedUsers];
		return;
	}
	if ([excludeUsersIDs isEqualToArray:self.users]) {
		return;
	}
	if (self.customUsers == nil) {
		_users = [[[ServicesManager instance].usersService.usersMemoryStorage unsortedUsers] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (ID IN %@)", self.excludeUsersIDs]];
	} else {
		_users = self.customUsers;
	}
	// add excluded users to future remove
	NSMutableArray *excludedUsers = [NSMutableArray array];
	[_users enumerateObjectsUsingBlock:^(QBUUser *obj, NSUInteger idx, BOOL *stop) {
		for (NSNumber *excID in excludeUsersIDs) {
			if (obj.ID == excID.integerValue) {
				[excludedUsers addObject:obj];
			}
		}
	}];
	
	//remove excluded users
	NSMutableArray *mUsers = [_users mutableCopy];
	[mUsers removeObjectsInArray:excludedUsers];
	_users = [mUsers copy];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.users count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserCollectionCell forIndexPath:indexPath];
    
    QBUUser *user = (QBUUser *)self.users[indexPath.row];
    cell.user = user;
    cell.usernameLabel.text = user.fullName != nil ? user.fullName : user.login;
    
    int distance = 1000;
    NSArray *geoUsers = [DataManager instance].geoUsers;
    for (QBLGeoData *geoData in geoUsers) {
        if (geoData.userID == user.ID) {
            CLLocation *userloc = [[CLLocation alloc]initWithLatitude:[GeoDataManager instance].coordinate.latitude longitude:[GeoDataManager instance].coordinate.longitude];
            CLLocation *dest = [[CLLocation alloc]initWithLatitude:geoData.latitude longitude:geoData.longitude];
            distance = [userloc distanceFromLocation:dest];
            break;
        }
    }
    
    if (distance >= 1000) {
        cell.distanceLabel.text = @"1+ Km";
    } else {
        cell.distanceLabel.text = [NSString stringWithFormat:@"%dm", distance];
    }
    
    NSString *bid = [NSString stringWithFormat:@"%d", (int)user.blobID];
    if ([DataManager instance].avatars[bid]) {
        cell.avatarImageView.image = [DataManager instance].avatars[bid];
    } else {
        [cell.loadingIcon startAnimating];
        [QBRequest downloadFileWithID:user.blobID successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {
            [cell.loadingIcon stopAnimating];
            [DataManager instance].avatars[bid] = [UIImage imageWithData:fileData];
            cell.avatarImageView.image = [DataManager instance].avatars[bid];
        } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
        } errorBlock:^(QBResponse * _Nonnull response) {
            [cell.loadingIcon stopAnimating];
        }];
    }
    
    return cell;
}

@end
