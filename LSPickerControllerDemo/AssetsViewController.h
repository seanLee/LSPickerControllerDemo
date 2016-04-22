//
//  AssetsViewController.h
//  magician
//
//  Created by sean on 15/2/7.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class AssetsViewController;

@protocol  AssetsViewControllerDelegate<NSObject>

@optional
- (void)assetsViewController:(AssetsViewController *)control didSelectedAvatar:(UIImage *)avatar;
- (void)assetsViewController:(AssetsViewController *)control didSelectedImages:(NSArray *)selectedImages;
- (void)assetsViewController:(AssetsViewController *)control didDeletedImages:(NSArray *)deletedImages;

@end

@interface AssetsViewController : UIViewController

@property (strong, nonatomic) ALAssetsGroup *assetsGroup;
@property (nonatomic) BOOL isAvatarChosen;
@property (nonatomic) NSInteger selectedCount;

@property (weak,nonatomic) id<AssetsViewControllerDelegate> delegate;

@end

@interface AssetCell : UICollectionViewCell

@property (strong,nonatomic) UIImageView *imageView;
@property (strong,nonatomic) UIImageView *checkmartImageView;

@end
