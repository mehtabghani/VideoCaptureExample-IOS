//
//  PreviewImageViewController.m
//  VIdeoCaptureExample
//
//  Created by Mehtab on 22/02/2017.
//  Copyright © 2017 Mehtab. All rights reserved.
//

#import "PreviewImageViewController.h"

@interface PreviewImageViewController () {

    UIImage* _image;
    NSArray* _images;
}

@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;

@end



@implementation PreviewImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Configure layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.imageCollectionView setCollectionViewLayout:flowLayout];
    
    _imageCollectionView.delegate = self;
    _imageCollectionView.dataSource = self;
}

- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    if (_images && _images.count > 0) {
        [_imageCollectionView reloadData];
    }
}


- (void) setImageArray:(NSArray*) images {
    _images = images;

}

#pragma mark - Collection View Delegates

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _images.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    imageView.image = [_images objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 100);
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
