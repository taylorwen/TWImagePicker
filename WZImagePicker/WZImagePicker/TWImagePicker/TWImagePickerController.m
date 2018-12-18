//
//  TWImagePickerController.m
//  WZImagePicker
//
//  Created by wenzhan on 2018/12/17.
//  Copyright © 2018年 wenzhan. All rights reserved.
//

#import "TWImagePickerController.h"
#import <Photos/Photos.h>
#import "TWPhotoCell.h"

#define kScreenWidth                           [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight                          [[UIScreen mainScreen] bounds].size.height
#define IS_iPhoneX ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)
#define kStatusBarAndNavigationBarHeight       (IS_iPhoneX ? 88.f : 64.f)

@interface TWImagePickerController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray *photoList;
@property (nonatomic, strong) NSMutableArray *thumbList;
@property (nonatomic, strong) PHFetchOptions *options;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation TWImagePickerController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.needPreviewAndEdit = NO;//默认不支持预览和编辑
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNav];
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self getOriginalImages];
}

-(void)initNav
{
    // 在主线程异步加载，使下面的方法最后执行，防止其他的控件挡住了导航栏
    dispatch_async(dispatch_get_main_queue(), ^{
        // 隐藏系统导航栏
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        // 创建假的导航栏
        UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kStatusBarAndNavigationBarHeight)];
        navView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0f];
        [self.view addSubview:navView];
        // 创建导航栏左按钮
        UIButton *left= [UIButton buttonWithType:UIButtonTypeSystem];
        left.frame = CGRectMake(kScreenWidth-50, kStatusBarAndNavigationBarHeight-37, 40, 30);
        [left setTitle:@"取消" forState:UIControlStateNormal];
        left.titleLabel.font = [UIFont systemFontOfSize:16];
        [left addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:left];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.text = @"选取图片";
        titleLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0f];
        titleLabel.frame = CGRectMake(left.frame.origin.x + left.frame.size.width + 20, 20, 150, 44);
        [navView addSubview:titleLabel];
    });
}

- (void)getOriginalImages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 获得所有的自定义相簿
        PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        // 遍历所有的自定义相簿
        for (PHAssetCollection *assetCollection in assetCollections) {
            [self enumerateAssetsInAssetCollection:assetCollection original:YES];
        }
        
        // 获得相机胶卷
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        // 遍历相机胶卷,获取大图
        [self enumerateAssetsInAssetCollection:cameraRoll original:YES];
    });
}

- (void)getThumbnailImages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 获得所有的自定义相簿
        PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        // 遍历所有的自定义相簿
        for (PHAssetCollection *assetCollection in assetCollections) {
            [self enumerateAssetsInAssetCollection:assetCollection original:NO];
        }
        // 获得相机胶卷
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        [self enumerateAssetsInAssetCollection:cameraRoll original:NO];
    });
}

/*
*  遍历相簿中的全部图片
*  @param assetCollection 相簿
*  @param original        是否要原图
*/
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    NSLog(@"相簿名:%@", assetCollection.localizedTitle);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    for (PHAsset *asset in assets) {
        // 是否要原图
        CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
        // 从asset中获得图片
        __weak typeof(self) weakSelf = self;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            NSLog(@"%@", result);
            original ? [weakSelf.photoList addObject:result] : [weakSelf.thumbList addObject:result];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
        });
    }
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TWPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TWPhotoCellID" forIndexPath:indexPath];
    cell.imageView.image = _photoList[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (_photoList[indexPath.item]) {
        if (self.needPreviewAndEdit) {
            
        }else{
            //直接返回
            if (self.delegate && [self.delegate respondsToSelector:@selector(tw_imagePickerControllerDidSelect:)]) {
                [self.delegate tw_imagePickerControllerDidSelect:self.photoList[indexPath.item]];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photoList.count;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth/3-1, kScreenWidth/3-1);
}

#pragma mark - action
- (void)cancel:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Lazy Load

- (NSMutableArray *)photoList
{
    if (!_photoList) {
        _photoList = [NSMutableArray array];
    }
    return _photoList;
}

- (NSMutableArray *)thumbList
{
    if (!_thumbList) {
        _thumbList = [NSMutableArray array];
    }
    return _thumbList;
}

- (PHFetchOptions *)options {
    if (!_options) {
        _options = [[PHFetchOptions alloc] init];
        _options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    }
    return _options;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kStatusBarAndNavigationBarHeight, kScreenWidth, kScreenHeight-kStatusBarAndNavigationBarHeight) collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[TWPhotoCell class] forCellWithReuseIdentifier:@"TWPhotoCellID"];
        
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 1;
        _flowLayout.minimumInteritemSpacing = 1;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0.5, 0, 0.5, 0);
    }
    return _flowLayout;
}

@end