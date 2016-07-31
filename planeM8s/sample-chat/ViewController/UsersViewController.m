//
//  TestUsersTableViewController.m
//  planeM8s
//
//  Created by Erik on 11/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "UsersViewController.h"
#import "ServicesManager.h"
#import "UsersDataSource.h"
#import "UserPhotoViewController.h"
#import "GeoDataManager.h"
#import "DataManager.h"

@interface UsersViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UsersDataSource *dataSource;

@end

@implementation UsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    [self setUsers:[[NSArray alloc] init]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.userIDs) {
        [SVProgressHUD show];
        [QBRequest usersWithIDs:self.userIDs page:nil successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nullable page, NSArray<QBUUser *> * _Nullable users) {
            [self setUsers:users];
            [SVProgressHUD dismiss];
        } errorBlock:^(QBResponse * _Nonnull response) {
            [SVProgressHUD showErrorWithStatus:@"Can not download users"];
        }];
    } else {
        QBLGeoDataFilter* filter = [QBLGeoDataFilter new];
        filter.lastOnly = YES;
        filter.currentPosition = [GeoDataManager instance].coordinate;
        filter.radius = 1;
        [SVProgressHUD show];
        [QBRequest geoDataWithFilter:filter
                                page:nil
                        successBlock:^(QBResponse *response, NSArray *objects, QBGeneralResponsePage *page) {
                            [DataManager instance].geoUsers = objects;
                            NSMutableArray *users = [[NSMutableArray alloc] init];
                            for (QBLGeoData *geoData in objects) {
                                [users addObject:geoData.user];
                            }
                            [self setUsers:users];
                            [SVProgressHUD dismiss];
                        } errorBlock:^(QBResponse *response) {
                            
                            [SVProgressHUD showErrorWithStatus:@"Can not download users"];
                        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUsers:(NSArray*)users {
    [[ServicesManager instance].usersService.usersMemoryStorage addUsers:users];

    self.dataSource = [[UsersDataSource alloc] initWithUsers:users];
    
    [self.dataSource setExcludeUsersIDs:@[@([QBSession currentSession].currentUser.ID)]];
    self.usersCollectionView.dataSource = self.dataSource;
    [self.usersCollectionView reloadData];
}

#pragma mark <UICollectionViewDelegate>

 - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
     QBUUser *selectedUser = [self.dataSource.users objectAtIndex:indexPath.row];
     UserPhotoViewController *userPhotoViewController = [self.storyboard instantiateViewControllerWithIdentifier:cUserPhotoViewController];
     userPhotoViewController.selectedUser = selectedUser;
     [self.navigationController pushViewController:userPhotoViewController animated:YES];
 }

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat screenWidth = collectionView.frame.size.width / 3;
    //CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width / 3;
    return CGSizeMake(screenWidth, screenWidth);
}

@end
