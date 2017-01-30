//
//  ViewController.m
//  VIdeoCaptureExample
//
//  Created by Mehtab on 09/12/2016.
//  Copyright © 2016 Mehtab. All rights reserved.
//

/*
 PBJVision: https://github.com/piemonte/PBJVision
 */

#import "ViewController.h"
#import "PBJVision.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAssetChangeRequest.h>
#import <Photos/PHAssetCollectionChangeRequest.h>
#import <Photos/PHAssetCreationRequest.h>

#import "DownPicker.h"


#define RECODRING_TIMER             1.0
#define RECODRING_TIME_LIMIT        10.0
#define kHigh           @"High (1280x720)"
#define kMedium         @"Medium (480x360)"
#define k640x480        @"640x480"


#define kFPS_30        @"30"
#define kFPS_20        @"20"
#define kFPS_10        @"10"





@interface ViewController () {

    AVCaptureVideoPreviewLayer* _previewLayer;
    NSTimer* _recordingTimer;
    int elapsedTime;
    
    NSDictionary* dictResolution;
    NSDictionary* dictFrame;
    PBJVision *vision;
    NSString* quality;
    int frameRate;

    
}

@property (strong, nonatomic) DownPicker *qulaityDownPicker;
@property (strong, nonatomic) DownPicker *fpsDownPicker;

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *lblRecordingDuration;

@property (weak, nonatomic) IBOutlet UITextField *tfResolutions;
@property (weak, nonatomic) IBOutlet UITextField *tfFPS;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    dictResolution = [NSDictionary dictionaryWithObjectsAndKeys:
                      AVCaptureSessionPresetHigh, kHigh,
                      AVCaptureSessionPresetMedium, kMedium,
                      AVCaptureSessionPreset640x480,k640x480,
                      nil];
    
    [self initView];
    [self initDropDown];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupCamera];
}


- (void) initView {
    _previewView.backgroundColor = [UIColor blackColor];
    CGRect previewFrame = CGRectMake(0, 60.0f, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame));
    _previewView.frame = previewFrame;
    _previewLayer = [[PBJVision sharedInstance] previewLayer];
    _previewLayer.frame = _previewView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewView.layer addSublayer:_previewLayer];
    
    _lblRecordingDuration.text = @"00:00";

}

- (void) initDropDown {
    // create the array of data
    NSMutableArray* qualityArray = [[NSMutableArray alloc] init];
    
    // add some sample data
    [qualityArray addObject:kHigh];
    [qualityArray addObject:kMedium];
    [qualityArray addObject:k640x480];


    // bind yourTextField to DownPicker
    self.qulaityDownPicker = [[DownPicker alloc] initWithTextField:self.tfResolutions withData:qualityArray];
    [self.qulaityDownPicker setPlaceholder:@"Slect Quality"];
    [self.qulaityDownPicker addTarget:self
                            action:@selector(onQualitySelect:)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.qulaityDownPicker setText:kHigh];
    
    
    
    // create the array of data
    NSMutableArray* fpsArray = [[NSMutableArray alloc] init];
    
    // add some sample data
    [fpsArray addObject:kFPS_30];
    [fpsArray addObject:kFPS_20];
    [fpsArray addObject:kFPS_10];

    
    // bind yourTextField to DownPicker
    self.fpsDownPicker = [[DownPicker alloc] initWithTextField:self.tfFPS withData:fpsArray];
    [self.fpsDownPicker setPlaceholder:@"Slect FPS"];
    [self.fpsDownPicker addTarget:self
                               action:@selector(onFPSSelect:)
                     forControlEvents:UIControlEventValueChanged];
    
    [self.fpsDownPicker setText:kFPS_30];
    
    
}

- (void)viewDidLayoutSubviews
{
    _previewLayer.frame = _previewView.bounds;
}

- (void) setupCamera
{
    //_longPressGestureRecognizer.enabled = YES;
    
    vision = [PBJVision sharedInstance];
    vision.delegate = self;
    vision.cameraMode = PBJCameraModeVideo;
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatSquare;
    vision.audioCaptureEnabled = NO;
    vision.cameraDevice = PBJCameraDeviceFront;
    vision.maximumCaptureDuration = CMTimeMakeWithSeconds(15, 600); // ~ 15 seconds
    //vision.videoBitRate = PBJVideoBitRate1920x1080;
    vision.captureSessionPreset = AVCaptureSessionPresetHigh;
   // [vision setVideoFrameRate:30];
    

    [vision startPreview];
    
    NSLog(@"\n\n----------\n");
    NSLog(@"Bit rate:%f", vision.videoBitRate);
    NSLog(@"FPS rate:%ld", vision.videoFrameRate);
    NSLog(@"Quality:%@", vision.captureSessionPreset);
    NSLog(@"\n----------\n\n");

    
    quality = AVCaptureSessionPresetHigh;
    //frameRate = 30;
}


- (void)vision:(PBJVision *)_vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }
    
    
    NSString *videoPath = [videoDict  objectForKey:PBJVisionVideoPathKey];
    NSLog(@"\n----------\n");
    NSLog(@"-> Video Path:%@", videoPath);
    NSLog(@"Bit rate:%f", vision.videoBitRate);
    NSLog(@"FPS rate:%ld", vision.videoFrameRate);
    NSLog(@"Quality:%@", vision.captureSessionPreset);
    NSLog(@"\n----------\n");


    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // Request creating an asset from the image.
        
        
        
        PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL URLWithString:videoPath]];
        
        
//        NSURL *url = [NSURL URLWithString:videoPath];
//        PHAssetResourceType assetType = PHAssetResourceTypeVideo;
//        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
//        PHAssetResourceCreationOptions *creationOptions = [PHAssetResourceCreationOptions new];
//        creationOptions.originalFilename = @"iphone6plus/customname.m4v";
//        [request addResourceWithType:assetType fileURL:url options:creationOptions];
        
        
        
//        // Request editing the album.
//        PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:<#(nonnull PHAssetCollection *)#>];
//        // Get a placeholder for the new asset and add it to the album editing request.
//        PHObjectPlaceholder *assetPlaceholder = [createAssetRequest placeholderForCreatedAsset];
//        [albumChangeRequest addAssets:@[ assetPlaceholder ]];
        
    } completionHandler:^(BOOL success, NSError *error) {
        
        if(error) {
            [self showAlert:@"Error" withMessage:error.description];
            return;
        }
        
        NSLog(@"Finished adding asset. %@", (success ? @"Success" : error));
        [self showAlert:@"Video Recording" withMessage:@"Video has been captured, Please check Photos app."];
        [_vision freezePreview];
    }];
}


- (void) showAlert:(NSString*) title withMessage:(NSString*) msg {

    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:msg
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];

}


#pragma mark - Timer

- (void) startRecordingTimer {

    elapsedTime = 0;
    _recordingTimer = [NSTimer scheduledTimerWithTimeInterval:RECODRING_TIMER target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
 
    [_recordingTimer fire];
}


- (void) updateTime {

    if(elapsedTime >= RECODRING_TIME_LIMIT ) {
        [self stopRecording];
        return;
    }
    
    elapsedTime += 1;
    _lblRecordingDuration.text = [NSString stringWithFormat:@"00:%02d", elapsedTime];

}

- (void) stopRecording {
    [[PBJVision sharedInstance] endVideoCapture];
    [_recordingTimer invalidate];
    _recordingTimer = nil;
}

#pragma mark - IBAction

- (IBAction)onStartRecording:(id)sender {
    
    

    [[PBJVision sharedInstance] startVideoCapture];
    _lblRecordingDuration.text = @"00:00";
    [self startRecordingTimer];
}
- (IBAction)onStopRecodring:(id)sender {
    [self stopRecording];
}
#pragma mark - Picker


-(void) onQualitySelect:(id)dp {
    NSString* selectedValue = [self.qulaityDownPicker text];
    
    if( !selectedValue || [selectedValue isEqualToString:@""])
        return;
    
    quality = [dictResolution objectForKey:selectedValue];
    vision.captureSessionPreset = quality;
    vision.videoFrameRate = frameRate;
    [vision startPreview];
    
}


-(void) onFPSSelect:(id)dp {
    NSString* selectedValue = [self.fpsDownPicker text];
    
    if( !selectedValue || [selectedValue isEqualToString:@""])
        return;
    frameRate = [selectedValue intValue];
    vision.captureSessionPreset = quality;
    //vision.videoFrameRate = frameRate;
    [vision startPreview];
    
}

@end
