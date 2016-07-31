//
//  UserTableViewCell.h
//  planeM8s
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIcon;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (nonatomic, strong) QBUUser *user;

@end
