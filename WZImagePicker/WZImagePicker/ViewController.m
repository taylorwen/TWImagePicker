//
//  ViewController.m
//  WZImagePicker
//
//  Created by wenzhan on 2018/12/17.
//  Copyright © 2018年 wenzhan. All rights reserved.
//

#import "ViewController.h"
#import "TWImagePicker/TWImagePickerController.h"

#define kScreenWidth                           [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight                          [[UIScreen mainScreen] bounds].size.height
#define IS_iPhoneX ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)
#define kStatusBarAndNavigationBarHeight       (IS_iPhoneX ? 88.f : 64.f)

@interface ViewController ()<TWImagePickerControllerDelegate>
@property (nonatomic, strong) UIImageView *tw_imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *pick = [UIButton buttonWithType:UIButtonTypeCustom];
    [pick setFrame:CGRectMake(10, kScreenHeight-100, kScreenWidth-20, 60)];
    [pick setTitle:@"选取" forState:UIControlStateNormal];
    [pick setBackgroundColor:[UIColor colorWithRed:39/255 green:145/255 blue:73/255 alpha:1.0]];
    [pick setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pick.layer.masksToBounds = YES;
    pick.layer.cornerRadius = 5;
    [pick addTarget:self action:@selector(pickImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pick];
    
    _tw_imageView = [[UIImageView alloc] init];
    _tw_imageView.frame = CGRectMake(5, kStatusBarAndNavigationBarHeight, kScreenWidth-10, (kScreenWidth-10)/10*16);
    _tw_imageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_tw_imageView];
}

- (void)pickImage:(UIButton *)sender
{
    TWImagePickerController *picker = [[TWImagePickerController alloc] init];
    picker.needPreviewAndEdit = NO;
    picker.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)tw_imagePickerControllerDidSelect:(nonnull UIImage *)image {
    _tw_imageView.image = image;
}

@end
