//
//  MGImageGenerator.h
//  VIdeoCaptureExample
//
//  Created by Mehtab on 22/02/2017.
//  Copyright © 2017 Mehtab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^MGImageGeneratorCompletionHandler)(NSArray* , NSError* );

@interface MGImageGenerator : NSObject

+ (UIImage*) getImageFromVideo:(NSURL*) videoPath;
+ (void) getImagesFromVideos:(NSURL*) videoPath videoDurationSeconds:(int) duration numberOfImages:(int) imageCount completionHandler:(MGImageGeneratorCompletionHandler) handler;



@end
