//
//  MGImageGenerator.m
//  VIdeoCaptureExample
//
//  Created by Mehtab on 22/02/2017.
//  Copyright © 2017 Mehtab. All rights reserved.
//

#import "MGImageGenerator.h"
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVFoundation.h>



@interface MGImageGenerator() {
    
}

@end

@implementation MGImageGenerator

-(UIImage*) getImageFromVideo:(NSURL*) videoPath {
    
    
   // NSString* documentsPath = [videoPath absoluteString];
    //NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
   // NSString* foofile = [documentsPath stringByAppendingPathComponent:@"foo.html"];
//    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:documentsPath];
//    
//    if(!fileExists) {
//        
//        NSLog(@"File does not exist");
//        return nil;
//    }

    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMake(0, 1);//CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    

    
    if(error)
        NSLog(@"%@", error);
    
    
    return image;

}


- (void) getImagesFromVideos:(NSURL*) videoPath completionHandler:(MGImageGeneratorCompletionHandler) handler {

    NSMutableArray* imagesArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    CMTime actualTime;
    
    for (Float64 i = 0; i < 5; i += 0.1) // generate 5/50 frames
    {
        CGImageRef imageRef = [imageGenerator  copyCGImageAtTime:CMTimeMakeWithSeconds(i, 60) actualTime:&actualTime error:&error];
        UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
        [imagesArray addObject:image];

        CGImageRelease(imageRef);
    }
    

    if(handler)
        handler(imagesArray, error);

}


@end
