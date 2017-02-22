//
//  PreviewImageViewController.h
//  VIdeoCaptureExample
//
//  Created by Mehtab on 22/02/2017.
//  Copyright © 2017 Mehtab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviewImageViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

- (void) setImageArray:(NSArray*) images;
//- (void) setImage:(UIImage*) img;

@end
