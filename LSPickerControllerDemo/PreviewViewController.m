//
//  PreviewViewController.m
//  magician
//
//  Created by sean on 15/2/11.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "PreviewViewController.h"
#import "AssetsGroupController.h"

#define MARGIN_Y 64.0f
#define MARGIN_Left 20.f

@interface PreviewViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (nonatomic, strong) UIBarButtonItem *selectedBarButton;
@property (nonatomic, strong) NSMutableArray *imageViewArays;

@end

@implementation PreviewViewController {

    NSMutableIndexSet *_selectedAssetsArray;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //取消返回手势
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * self.assetsArray.count, [UIScreen mainScreen].bounds.size.height - MARGIN_Y);
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    //确定
    [self.submitButton addTarget:self action:@selector(didSelectedClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _selectedAssetsArray = [[NSMutableIndexSet alloc] init];
    [self.assetsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        //加载所有图片
        [self loadScrollViewWithIndex:idx];
        [_selectedAssetsArray addIndex:idx];
    }];
    
    self.selectedBarButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:self action:@selector(changeStateClick:)];
    self.navigationItem.rightBarButtonItem = self.selectedBarButton;
    //默认状态
    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame) * self.curIndex, 0) animated:YES];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)loadScrollViewWithIndex:(NSUInteger)index {
    
    if (index >= self.assetsArray.count) {
        
        return;
    }

    UIImageView *imageView = [self.imageViewArays objectAtIndex:index];
    
    if (!imageView) {
        //imageview
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * index, -1 * MARGIN_Y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        //insert in arrar
        [self.imageViewArays replaceObjectAtIndex:index withObject:imageView];
    }
    
    if (imageView.superview == nil ) {
        
        UIImage *image = [self.assetsArray objectAtIndex:index];
        [imageView didMoveToSuperview];
        [imageView setImage:image];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.scrollView addSubview:imageView];
    }
}

- (void)setCheckmart:(NSInteger)index {

    //checkmark
    BOOL previouslyContainsIndex = [_selectedAssetsArray containsIndex:index];
    [self setSelectedBarButtonState:previouslyContainsIndex];
    
    [self.submitButton setTitle:[NSString stringWithFormat:@"确定(%@)",[NSNumber numberWithInteger:_selectedAssetsArray.count]] forState:UIControlStateNormal];
}

- (void)setSelectedBarButtonState:(BOOL)selected {

    [self.selectedBarButton setTag:selected];
    
    if (selected) {
        
        [self.selectedBarButton setImage:[UIImage imageNamed:@"icon_checkmark_select"]];
    
    } else {
    
         [self.selectedBarButton setImage:[UIImage imageNamed:@"icon_checkmark_cancel"]];
    }
    
    [self.navigationItem setRightBarButtonItem:self.selectedBarButton animated:YES];
}

#pragma mark - Actions

- (void)didSelectedClick:(UIButton *)sender {

    NSMutableArray *temp = [NSMutableArray array];
    
    [_selectedAssetsArray enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        [temp addObject:[self.assetsArray objectAtIndex:idx]];
    }];
    
    if (self.deletingResource) {
        
        [self.navigationController popViewControllerAnimated:YES];
        if ([self.assetsViewDelegate respondsToSelector:@selector(assetsViewController:didDeletedImages:)]) {
            
            [self.assetsViewDelegate assetsViewController:nil didDeletedImages:temp];
        }
    
    } else {
    
        [self dismissViewControllerAnimated:YES completion:nil];
        if ([self.assetsViewDelegate respondsToSelector:@selector(assetsViewController:didSelectedImages:)]) {
            
            [self.assetsViewDelegate assetsViewController:nil didSelectedImages:temp];
        }
    }
}

- (void)changeStateClick:(UIBarButtonItem *)sender {

    sender.tag = !sender.tag;
    
    if (sender.tag) {
        
        [_selectedAssetsArray addIndex:self.curIndex];
    
    } else {
    
        [_selectedAssetsArray removeIndex:self.curIndex];
    }
    
    [self setCheckmart:self.curIndex];
}

#pragma mark - UIScrollViewDelegate     

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = [UIScreen mainScreen].bounds.size.width;
    NSUInteger index = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.curIndex = index;
    
    self.title = [NSString stringWithFormat:@"%@/%@",[NSNumber numberWithInteger:self.curIndex + 1],[NSNumber numberWithInteger:self.assetsArray.count]];
    [self setCheckmart:self.curIndex];
}

@end
