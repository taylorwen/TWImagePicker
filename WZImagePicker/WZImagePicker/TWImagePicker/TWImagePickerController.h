//
//  TWImagePickerController.h
//  WZImagePicker
//
//  Created by wenzhan on 2018/12/17.
//  Copyright © 2018年 wenzhan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TWImagePickerControllerDelegate <NSObject>

- (void)tw_imagePickerControllerDidSelect:(UIImage *)image;

@end

@interface TWImagePickerController : UIViewController

@property (nonatomic, copy) void (^selectPhoto)(UIImage *);
@property (nonatomic, assign) BOOL needPreviewAndEdit;
@property (nonatomic, weak) id<TWImagePickerControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
