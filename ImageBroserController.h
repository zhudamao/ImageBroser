//
//  ImageBroserController.h
//  RACDemo
//
//  Created by 朱大茂 on 16/7/14.
//  Copyright © 2016年 zhudm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageBroserController;
@protocol ImageBroserDataSource <NSObject>

- (NSInteger)numImagesForBroser:(ImageBroserController *)broser;
- (NSURL *)imageUrlAtIndex:(NSInteger)index broser:(ImageBroserController *)broser;
- (CGRect) theImageViewFrameBaseOnWindowAtIndex:(NSInteger)index broser:(ImageBroserController *)broser;
@optional
- (NSInteger)initImageIndexForShow:(ImageBroserController *)broser;
- (NSString *)titleForIndexForShow:(ImageBroserController *)broser;
@end

@interface ImageBroserController : UIViewController

@property (nonatomic,weak) id<ImageBroserDataSource> dataSource;

@end
