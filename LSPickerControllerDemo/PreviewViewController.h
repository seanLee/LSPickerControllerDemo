//
//  PreviewViewController.h
//  magician
//
//  Created by sean on 15/2/11.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetsViewController.h"

@interface PreviewViewController : UIViewController

@property (strong,nonatomic) NSArray *assetsArray;
@property (nonatomic) NSInteger curIndex;
@property (nonatomic) BOOL deletingResource;

@property (weak,nonatomic) id<AssetsViewControllerDelegate> assetsViewDelegate;

@end
