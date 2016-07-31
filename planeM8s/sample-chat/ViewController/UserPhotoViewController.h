//
//  UserPhotoViewController.h
//  planeM8s
//
//  Created by Erik on 11/30/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserPhotoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) QBUUser *selectedUser;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIcon;

@end
