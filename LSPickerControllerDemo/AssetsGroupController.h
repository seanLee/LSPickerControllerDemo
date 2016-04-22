//
//  AssetsPickerController.h
//  PhotoLibraryDemo
//
//  Created by sean on 15/1/10.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsViewController.h"

@interface AssetsGroupController : UITableViewController

+ (AssetsGroupController *)shareInstance;
- (void)setupAssetsLibraryAuthorizationStatus;

@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic) BOOL isAvatarChosen;
@property (weak,nonatomic) id<AssetsViewControllerDelegate> assetsViewDelegate;
@property (nonatomic) NSInteger selectedCount;

@end
