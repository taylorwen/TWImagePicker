//
//  TWPhotoCell.m
//  WZImagePicker
//
//  Created by wenzhan on 2018/12/17.
//  Copyright © 2018年 wenzhan. All rights reserved.
//

#import "TWPhotoCell.h"

@implementation TWPhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.image = self.image;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}


- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    }
    return _imageView;
}
@end
