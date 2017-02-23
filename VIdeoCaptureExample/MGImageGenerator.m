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

+ (UIImage*) getImageFromVideo:(NSURL*) videoPath {
    
    
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


+ (void) getImagesFromVideos:(NSURL*) videoPath videoDurationSeconds:(int) duration numberOfImages:(int) imageCount completionHandler:(MGImageGeneratorCompletionHandler) handler {

    NSMutableArray* imagesArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    CMTime actualTime;
    
    float increament =  (float)duration / (float)imageCount;
    int loopCount = 0;
    
    for (Float64 i = 0; i < duration; i += increament) // e.g generate 5(duration in seconds)/50(frames)
    {
        loopCount++;
        
        //reference for timescale calculation http://stackoverflow.com/questions/4001755/trying-to-understand-cmtime-and-cmtimemake
        
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(i, 600) actualTime:&actualTime error:&error];
        UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
        [imagesArray addObject:image];
        [MGImageGenerator saveImageToDocumentDirectory:image withName:[NSString stringWithFormat:@"MG_image_%d", loopCount]];
        CGImageRelease(imageRef);
    }
    

    if(handler)
        handler(imagesArray, error);

}

+ (void) saveImageToDocumentDirectory:(UIImage*) image withName:(NSString*) imageName {
    
    __block NSString* _imageName = imageName;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *jpegData = UIImageJPEGRepresentation(image, 1) ;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        _imageName = [NSString stringWithFormat:@"/%@.jpeg", _imageName];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:imageName]; //Add the file name
        [jpegData writeToFile:filePath atomically:YES]; //Write the file
    });
  
}


@end
