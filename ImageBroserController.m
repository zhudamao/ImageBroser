//
//  ImageBroserController.m
//  RACDemo
//
//  Created by 朱大茂 on 16/7/14.
//  Copyright © 2016年 zhudm. All rights reserved.
//

#import "ImageBroserController.h"
#import <UIImageView+WebCache.h>

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface ImageBroserViewCell : UICollectionViewCell<UIScrollViewDelegate>
{
    UIScrollView * _scrollView;
    UIImageView * _imageView;
}

@property (nonatomic, assign) CGRect frameToWindow;
@property (nonatomic, assign) BOOL inital;// 是否是开始的图片

@property (nonatomic, weak) UIViewController * owner;

@end

static const CGFloat kMaxImageScale = 2.0f;
static const CGFloat kMinImageScale = 1.0f;

@implementation ImageBroserViewCell
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        CGRect frame = [UIScreen mainScreen].bounds;
        _scrollView = [[UIScrollView alloc]initWithFrame:frame];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:_scrollView];
        
        _imageView = [[UIImageView alloc]init];
        [_scrollView addSubview:_imageView];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return self;
}

- (void)setImageURL:(NSURL *)imageURL defaultImage:(UIImage*)defaultImage imageIndex:(NSInteger)imageIndex{
    [_scrollView setZoomScale:1.0f animated:NO];
    [_imageView setImage:defaultImage];
    [_imageView setShowActivityIndicatorView:YES];
    
    [_imageView sd_setImageWithURL:imageURL placeholderImage:defaultImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        _imageView.frame = [self centerFrameFromImage:image];
        if(self.inital){
            _imageView.frame = self.frameToWindow;
            [UIView animateWithDuration:0.4f delay:0.0f options:0 animations:^{
                _imageView.frame = [self centerFrameFromImage:_imageView.image];
            }   completion:^(BOOL finished) {
                if (finished) {
                    
                }
            }];
            
        }
        _imageView.userInteractionEnabled = NO;
        
        [self addMultipleGesture];
    }];
    
}

- (CGRect) centerFrameFromImage:(UIImage*) image {
    if(!image) return CGRectZero;
    
    CGRect windowBounds = [UIScreen mainScreen].bounds;
    CGSize newImageSize = [self imageResizeBaseOnWidth:windowBounds
                           .size.width oldWidth:image
                           .size.width oldHeight:image.size.height];
    // Just fit it on the size of the screen
    newImageSize.height = MIN(windowBounds.size.height,newImageSize.height);
    return CGRectMake(0.0f, windowBounds.size.height/2 - newImageSize.height/2, newImageSize.width, newImageSize.height);
}

- (CGSize)imageResizeBaseOnWidth:(CGFloat) newWidth oldWidth:(CGFloat) oldWidth oldHeight:(CGFloat)oldHeight {
    CGFloat scaleFactor = newWidth / oldWidth;
    CGFloat newHeight = oldHeight * scaleFactor;
    return CGSizeMake(newWidth, newHeight);
}

- (void)addMultipleGesture {
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [_scrollView addGestureRecognizer:singleTapRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDobleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [_scrollView addGestureRecognizer:doubleTapRecognizer];
    
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    
    _scrollView.minimumZoomScale = kMinImageScale;
    _scrollView.maximumZoomScale = kMaxImageScale;
    _scrollView.zoomScale = 1;
   
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = [UIScreen mainScreen].bounds.size;
    CGRect contentsFrame = _imageView.frame;
    //NSLog(@"%@",NSStringFromCGRect(contentsFrame));
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    _imageView.frame = contentsFrame;
}

#pragma mark - UIScrollView Delegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}


#pragma mark - Showing of Done Button if ever Zoom Scale is equal to 1
- (void)didSingleTap:(UITapGestureRecognizer*)recognizer {
    //self.userInteractionEnabled = NO;
    if (_scrollView.zoomScale > 1) {
        [_scrollView setZoomScale:1.0 animated:YES];
    }else
        [self dismissViewController];
}

- (void)didDobleTap:(UITapGestureRecognizer*)recognizer {
    CGPoint pointInView = [recognizer locationInView:_imageView];
    [self zoomInZoomOut:pointInView];
}

- (void)zoomInZoomOut:(CGPoint)point {
    // Check if current Zoom Scale is greater than half of max scale then reduce zoom and vice versa
    CGFloat newZoomScale = _scrollView.zoomScale > (_scrollView.maximumZoomScale/2)?_scrollView.minimumZoomScale:_scrollView.maximumZoomScale;
    
    CGSize scrollViewSize = _scrollView.bounds.size;
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = point.x - (w / 2.0f);
    CGFloat y = point.y - (h / 2.0f);
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    [_scrollView zoomToRect:rectToZoomTo animated:YES];
}

#pragma mark - Dismiss
- (void)dismissViewController
{
    _imageView.clipsToBounds = YES;
    [UIView animateWithDuration:0.4f delay:0.0f options:0 animations:^{
        _imageView.frame = _frameToWindow;
    } completion:^(BOOL finished) {
        if (finished) {
            //                if(_closingBlock)
            //                    _closingBlock();
            [self.owner dismissViewControllerAnimated:NO completion:^{
                
            } ];
        }
    }];
}

@end


#pragma mark - ImageBroserController 图片浏览器

@interface ImageBroserController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    BOOL hasAnimation;
}

@property (nonatomic,retain) UICollectionView * collectView;
@property (nonatomic,retain) UILabel * titleLable;
@property (nonatomic,assign) NSInteger initIndex;
@end


@implementation ImageBroserController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initIndex = 0;
    if ([_dataSource respondsToSelector:@selector(initImageIndexForShow:)]) {
        [_dataSource initImageIndexForShow:self];
    }
    
    [self p_initSubViews];
    // Do any additional setup after loading the view.
}

- (void)p_initSubViews{
    [self.view addSubview:self.collectView];

    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 40.0, SCREEN_WIDTH, 40.0f)];
    backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self.view addSubview:backView];

    [backView addSubview:self.titleLable];
}

#pragma mark -overrWrite Method
- (UICollectionView *)collectView{
    if (!_collectView) {
        CGRect widowFrame = [UIScreen mainScreen].bounds;
        
        UICollectionViewFlowLayout * layOut = [[UICollectionViewFlowLayout alloc]init];
        
        layOut.minimumLineSpacing = 0;
        layOut.itemSize = widowFrame.size;
        layOut.sectionInset = UIEdgeInsetsZero;
        layOut.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectView = [[UICollectionView alloc]initWithFrame:widowFrame collectionViewLayout:layOut];
        _collectView.dataSource = self;
        _collectView.delegate = self;
        _collectView.pagingEnabled = YES;
        _collectView.showsVerticalScrollIndicator = NO;
        _collectView.showsHorizontalScrollIndicator = NO;
        
        [_collectView registerClass:[ImageBroserViewCell class] forCellWithReuseIdentifier:@"ImageBroserViewCell"];
    }
    
    return _collectView;
}

- (UILabel *)titleLable{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] init];
        _titleLable.font = [UIFont systemFontOfSize:14.0f];
        _titleLable.textColor = [UIColor whiteColor];
        [self scrollViewDidEndDecelerating:self.collectView];
    }
    
    return _titleLable;
}

#pragma mark -UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return [_dataSource numImagesForBroser:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageBroserViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageBroserViewCell" forIndexPath:indexPath];
    
    if (!hasAnimation && _initIndex == indexPath.row) {
        cell.inital = YES;
        hasAnimation = YES;
    }else{
        cell.inital = NO;
    }
    
    if (self.dataSource) {
        if ([self.dataSource respondsToSelector:@selector(theImageViewFrameBaseOnWindowAtIndex:broser:)]) {
            cell.frameToWindow = [self.dataSource theImageViewFrameBaseOnWindowAtIndex:indexPath.row broser:self];
        }
        [cell setImageURL:[self.dataSource imageUrlAtIndex:indexPath.row broser:self] defaultImage:nil imageIndex:indexPath.row];
    }
    
    //cell.backgroundColor = [UIColor whiteColor];
    cell.owner = self;
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger totalPage = [_dataSource numImagesForBroser:self];
    
    if (totalPage < 2) {
        self.titleLable.text = nil;
    }else{
        NSInteger currentPage = scrollView.contentOffset.x/SCREEN_WIDTH;
        self.titleLable.text = [NSString stringWithFormat:@"%@/%@",@(currentPage + 1),@(totalPage)];
        [self.titleLable sizeToFit];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
