//
//  AssetsPickerController.m
//  PhotoLibraryDemo
//
//  Created by sean on 15/1/10.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "AssetsGroupController.h"

@interface AssetsGroupController ()

@property (nonatomic, strong) NSMutableArray *groups;

@end

static NSString *reuseCellIdentifier = @"cell";

@implementation AssetsGroupController

+ (AssetsGroupController *)shareInstance
{
    static AssetsGroupController * share = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        share = [[self alloc] init];
    });
    return share;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //tableView
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseCellIdentifier];
    [self.tableView setContentInset:UIEdgeInsetsMake(10.f, 0, 0, 0)];
    
    UIBarButtonItem *pickButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(backClick:)];
    self.navigationItem.rightBarButtonItem = pickButton;
    
    [self.navigationItem setTitle:@"照片"];
    
    [self setupGroups];
    if (self.isAvatarChosen) {
        
        //TODO:
    }
}

- (void)setupGroups {
    
    if (self.groups == nil) {
        
        _groups = [[NSMutableArray alloc] init];
        
    } else {
        
        [self.groups removeAllObjects];
    }
    
    // Group enumerator Block
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group == nil)
        {
            [self.tableView reloadData];
            AssetsViewController *controller = [[AssetsViewController alloc] init];
            controller.delegate = self.assetsViewDelegate;
            controller.isAvatarChosen = self.isAvatarChosen;
            controller.assetsGroup = [self.groups objectAtIndex:0];
            controller.selectedCount = self.selectedCount;
            [self.navigationController pushViewController:controller animated:NO];
            return;
        }
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];

        if ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos) {
         
            [self.groups insertObject:group atIndex:0];
        
        } else if ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupPhotoStream) {
        
            [self.groups insertObject:group atIndex:1];
        
        } else {
        
            [self.groups addObject:group];
        }
        
        [self.tableView reloadData];
    };
    
    // Group Enumerator Failure Block
    void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate: nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
        [alert show];
    };
    
    //enumerate only photos
    [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:assetGroupEnumberatorFailure];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    
    ALAssetsGroup *groupForCell = self.groups[indexPath.row];
    CGImageRef posterImageRef = [groupForCell posterImage];
    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
    
    cell.imageView.image = posterImage;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",[groupForCell valueForProperty:ALAssetsGroupPropertyName],[NSNumber numberWithInteger:[groupForCell numberOfAssets]]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 80.f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    AssetsViewController *controller = [[AssetsViewController alloc] init];
    controller.delegate = self.assetsViewDelegate;
    controller.isAvatarChosen = self.isAvatarChosen;
    controller.selectedCount = self.selectedCount;
    controller.assetsGroup = [self.groups objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - BarButton Click

- (IBAction)backClick:(UIBarButtonItem *)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getter and Setter

- (ALAssetsLibrary *)assetLibrary {

    if (!_assetLibrary) {
        
        _assetLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    return _assetLibrary;
}

#pragma mark - Private Method

- (void)setupAssetsLibraryAuthorizationStatus {
    
    [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

@end
