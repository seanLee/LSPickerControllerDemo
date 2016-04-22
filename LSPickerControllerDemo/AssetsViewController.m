//
//  AssetsViewController.m
//  magician
//
//  Created by sean on 15/2/7.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "AssetsViewController.h"
#import "PreviewViewController.h"

@interface AssetsViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *assetsArray;
@property (strong, nonatomic)   NSMutableArray *selectedAssetsArray;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UIView *bottomToolBar;

@end

static NSString * const reuseIdentifier = @"AssetCell";
static NSString * const footerIdentifier = @"Footer";
static NSInteger const maxSelectedCount = 7;

@implementation AssetsViewController {

    NSMutableIndexSet *_selectedIndex;
    NSMutableArray *_assetsURLs;
    NSInteger _remainCount;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    //返回按钮
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] init];
    [backBarButton setTitle:@"返回"];
    self.navigationItem.backBarButtonItem = backBarButton;
    
    _bottomToolBar.backgroundColor = [UIColor redColor];
    
    //取消
    UIBarButtonItem *pickButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(backClick:)];
    self.navigationItem.rightBarButtonItem = pickButton;
    
    //collectionView
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(6.0f, 0, 50.0f, 0);
    [self.collectionView registerClass:[AssetCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerIdentifier];
    
    [self.previewButton addTarget:self action:@selector(previewClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.submitButton addTarget:self action:@selector(submitClick:) forControlEvents:UIControlEventTouchUpInside];
    //默认按钮
    [self.previewButton setEnabled:NO];
    [self.submitButton setEnabled:NO];
    
    //保存多选对象
    _selectedIndex = [[NSMutableIndexSet alloc] init];
    [self setupAssets];
    
    if (self.isAvatarChosen) {
        
        self.bottomToolBar.hidden = YES;
    }
    
    _remainCount = maxSelectedCount - self.selectedCount;
}

- (void)setSelectedAssetsArray {
    
    [self.selectedAssetsArray removeAllObjects];
    
    [_selectedIndex enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {

        ALAsset *asset = [self.assetsArray objectAtIndex:idx];
        
        UIImage *image = [UIImage imageWithCGImage:[asset defaultRepresentation].fullResolutionImage];
        [self.selectedAssetsArray addObject:image];
    }];
}

#pragma mark - Action

- (IBAction)submitClick:(UIButton *)sender {
    
    [self setSelectedAssetsArray];
    
    if ([self.delegate respondsToSelector:@selector(assetsViewController:didSelectedImages:)]) {
        
        [self.delegate assetsViewController:self didSelectedImages:self.selectedAssetsArray];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)previewClick:(UIButton *)sender {
    
    [self setSelectedAssetsArray];
    
    PreviewViewController *previewVC = [[PreviewViewController alloc] initWithNibName:@"PreviewViewController" bundle:nil];
    previewVC.assetsViewDelegate = self.delegate;
    previewVC.assetsArray = self.selectedAssetsArray;
    
    [self.navigationController pushViewController:previewVC animated:YES];
}

- (IBAction)backClick:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private method

- (void)setupSelectedImage {
    
    _assetsURLs = [NSMutableArray array];
    
    [self.selectedAssetsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *info = (NSDictionary *)obj;
        NSString *url = [info valueForKey:@"path"];
        [_assetsURLs addObject:url];
    }];
    
    [self.previewButton setEnabled:YES];
    [self.submitButton setEnabled:YES];
    [self.submitButton setTitle:[NSString stringWithFormat:@"确定(%@)",[NSNumber numberWithInteger:_assetsURLs.count]] forState:UIControlStateNormal];
}

- (void)setupAssets {
    
    if (!self.assetsArray) {
        
        _assetsArray = [[NSMutableArray alloc] init];
        
    } else {
        
        [self.assetsArray removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            
            [self.assetsArray addObject:result];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [self.assetsGroup setAssetsFilter:onlyPhotosFilter];
    [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.assetsGroup.numberOfAssets;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    ALAsset *asset = [self.assetsArray objectAtIndex:indexPath.row];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    cell.imageView.image = thumbnail;
    
    BOOL previouslyContainsIndex = [_selectedIndex containsIndex:indexPath.row];
    cell.checkmartImageView.hidden = previouslyContainsIndex?NO:YES;
    
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    UICollectionReusableView  *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, reusableview.frame.size.width, reusableview.frame.size.height)];
    
    //提醒
    NSString *footerString;
    if (self.assetsGroup.numberOfAssets > 0) {
        
        footerString = [NSString stringWithFormat:@"共%@张照片",[NSNumber numberWithInteger:self.assetsGroup.numberOfAssets]];
    
    } else {
    
        footerString = @"请为该相册添加照片";
    }

    [textLabel setText:footerString];
    [textLabel setTextColor:[UIColor blackColor]];
    [textLabel setTextAlignment:NSTextAlignmentCenter];
    [textLabel setFont:[UIFont systemFontOfSize:14.5f]];
    [reusableview addSubview:textLabel];
    
    return reusableview;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 4.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {

    return 4.f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 3 * 4.f) / 4;

    return CGSizeMake(width, width);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isAvatarChosen) {
        
        ALAsset *asset = [self.assetsArray objectAtIndex:indexPath.row];
        CGImageRef imageRef = [[asset defaultRepresentation] fullResolutionImage];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        
        if ([self.delegate respondsToSelector:@selector(assetsViewController:didSelectedAvatar:)]) {
            
            [self.delegate assetsViewController:self didSelectedAvatar:image];
        }
        
    } else {
    
        AssetCell *cell = (AssetCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        BOOL previouslyContainsIndex = [_selectedIndex containsIndex:indexPath.row];
        if (previouslyContainsIndex) {
            
            [_selectedIndex removeIndex:indexPath.row];
            
        } else {

            if (_selectedIndex.count < _remainCount) {
                
                [_selectedIndex addIndex:indexPath.row];
                
            } else {
            
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您最多能选7张图片,请认真选择" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        
        BOOL latelyContainsIndex = [_selectedIndex containsIndex:indexPath.row];
        cell.checkmartImageView.hidden = latelyContainsIndex?NO:YES;
        
        if (_selectedIndex.count > 0) {
            
            [self.previewButton setEnabled:YES];
            [self.submitButton setEnabled:YES];
            [self.submitButton setTitle:[NSString stringWithFormat:@"确定(%@)",[NSNumber numberWithInteger:_selectedIndex.count]] forState:UIControlStateNormal];
            
        } else {
            
            [self.previewButton setEnabled:NO];
            [self.submitButton setEnabled:NO];
        }
    }
}

#pragma mark - Setter

- (NSMutableArray *)selectedAssetsArray {

    if (!_selectedAssetsArray) {
        
        _selectedAssetsArray = [NSMutableArray array];
    }
    
    return _selectedAssetsArray;
}

@end

@implementation AssetCell

- (UIImageView *)imageView {

    if (!_imageView) {
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
    }
    
    return _imageView;
}

- (UIImageView *)checkmartImageView {

    if (!_checkmartImageView) {
        
        UIImage *image = [UIImage imageNamed:@"checkmark"];
        _checkmartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - image.size.width, self.frame.size.height - image.size.height, image.size.width, image.size.height)];
        _checkmartImageView.image = image;
        [self addSubview:_checkmartImageView];
    }
    
    return _checkmartImageView;
}

@end
