//
//  ViewController.m
//  LSPickerControllerDemo
//
//  Created by sean on 15/9/2.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "ViewController.h"
#import "AssetsGroupController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48.f, 24.f)];
    [button setTitle:@"相册 " forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.center = self.view.center;
    [button addTarget:self action:@selector(photoClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark - Action
- (void)photoClicked:(id)sender {
    AssetsGroupController *groupController = [[AssetsGroupController alloc] init];
    [self.navigationController pushViewController:groupController animated:YES];
}

@end
