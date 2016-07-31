//
//  TestUsersTableViewController.h
//  planeM8s
//
//  Created by Erik on 11/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsersViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *usersCollectionView;
@property (strong, nonatomic) NSArray *userIDs;

@end
