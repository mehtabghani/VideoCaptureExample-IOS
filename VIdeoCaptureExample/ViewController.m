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
#import "SDVersion.h"
#import "DownPicker.h"
#import "PreviewImageViewController.h"
#import "MGImageGenerator.h"


#define RECODRING_TIMER             1.0
#define RECODRING_TIME_LIMIT        11.0
#define kHigh           @"High(1280x720)"
#define kMedium         @"Medium(480x360)"
#define k640x480        @"640x480"


#define kFPS_30        @"30"
#define kFPS_20        @"20"
#define kFPS_10        @"10"

#define kDuration_5    @"5"
#define kDuration_8    @"8"
#define kDuration_10   @"10"



@interface ViewController () {

    AVCaptureVideoPreviewLayer* _previewLayer;
    NSTimer* _recordingTimer;
    int elapsedTime;
    
    NSDictionary* dictResolution;
    NSDictionary* dictFrame;
    PBJVision *vision;
    NSString* quality;
    int frameRate;
    int recordingDuartion;

    
}

@property (strong, nonatomic) DownPicker *qulaityDownPicker;
@property (strong, nonatomic) DownPicker *fpsDownPicker;
@property (strong, nonatomic) DownPicker *durationDownPicker;


@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *lblRecordingDuration;

@property (weak, nonatomic) IBOutlet UITextField *tfResolutions;
@property (weak, nonatomic) IBOutlet UITextField *tfFPS;
@property (weak, nonatomic) IBOutlet UITextField *tfDuration;
@property (weak, nonatomic) IBOutlet UITextField *tfBitRate;

@end

@implementation ViewController

#pragma mark - Application Events

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
    recordingDuartion = [kDuration_5 intValue];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupCamera];
}


#pragma mark - UI Setup


- (void) initView {
    _previewView.backgroundColor = [UIColor blackColor];
    CGRect previewFrame = CGRectMake(0, 60.0f, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame));
    _previewView.frame = previewFrame;
    _previewLayer = [[PBJVision sharedInstance] previewLayer];
    _previewLayer.frame = _previewView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewView.layer addSublayer:_previewLayer];
    
    _lblRecordingDuration.text = @"00:00";
    
    [_tfBitRate setDelegate:self];

}

- (void) initDropDown {
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
    
    //
    NSMutableArray* durationArray = [[NSMutableArray alloc] init];
    
    // add some sample data
    [durationArray addObject:kDuration_5];
    [durationArray addObject:kDuration_8];
    [durationArray addObject:kDuration_10];
    
    
    // bind yourTextField to DownPicker
    self.durationDownPicker = [[DownPicker alloc] initWithTextField:self.tfDuration withData:durationArray];
    [self.durationDownPicker setPlaceholder:@"Select Duration"];
    [self.durationDownPicker addTarget:self
                           action:@selector(onDurationSelect:)
                 forControlEvents:UIControlEventValueChanged];
    
    [self.durationDownPicker setText:kDuration_5];
    
}

- (void)viewDidLayoutSubviews {
    _previewLayer.frame = _previewView.bounds;
}

- (NSString*) getDocumentPathToSaveVideo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    return documentsPath;
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
    vision.videoBitRate = 1500000;//PBJVideoBitRate1920x1080;
    vision.captureSessionPreset = AVCaptureSessionPresetHigh;
   // [vision setVideoFrameRate:30];
    [vision setCaptureDirectory:[self getDocumentPathToSaveVideo]];
    

    [vision startPreview];
    
    NSLog(@"\n\n----------\n");
    NSLog(@"Bit rate:%f", vision.videoBitRate);
    NSLog(@"FPS rate:%ld", vision.videoFrameRate);
    NSLog(@"Quality:%@", vision.captureSessionPreset);
    NSLog(@"\n----------\n\n");

    quality = kHigh;
    frameRate = 30;
    recordingDuartion = [kDuration_5 intValue];
}

#pragma mark - PBJVision Delegate

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
    NSURL *url = [NSURL fileURLWithPath:videoPath];

    NSLog(@"\n----------\n");
    NSLog(@"-> Video Path:%@", videoPath);
    NSLog(@"Bit rate:%f", vision.videoBitRate);
    NSLog(@"FPS rate:%ld", (long)vision.videoFrameRate);
    NSLog(@"Quality:%@", vision.captureSessionPreset);
    NSLog(@"\n----------\n");
    
    _lblRecordingDuration.text = @"00:00";
    
   //[self saveVideo:_vision videoURL:url];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self generateImagesFromVideo:url];
        
    });
    
}


- (void) saveVideo:(PBJVision *)_vision videoURL:(NSURL*) url {
    
    NSString* fileName = [NSString stringWithFormat:@"%@-%@-%ldfps.m4v", DeviceVersionNames[[SDVersion deviceVersion]], quality, (long)vision.videoFrameRate];
    NSLog(@"File Name:%@", fileName);
    
    __weak __typeof(self) weakSelf = self;

    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        //PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL URLWithString:videoPath]];
    
        PHAssetResourceType assetType = PHAssetResourceTypeVideo;
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        PHAssetResourceCreationOptions *creationOptions = [PHAssetResourceCreationOptions new];
        creationOptions.originalFilename = fileName;
        [request addResourceWithType:assetType fileURL:url options:creationOptions];
        
        
    } completionHandler:^(BOOL success, NSError *error) {
        
        if(error) {
            [weakSelf showAlert:@"Error" withMessage:error.description];
            return;
        }
        
        NSLog(@"Finished adding asset.");
        NSString* msg = [NSString stringWithFormat:@"%@ has been saved, Please check Photos app.", fileName];
        [weakSelf showAlert:@"Video Recording" withMessage:msg];
        [_vision freezePreview];
    }];
}


#pragma mark - Generate Image Method

- (void) generateImagesFromVideo:(NSURL*) url {

   
    /* for first frame */
    //UIImage* img = [MGImageGenerator getImageFromVideo:url];
   // NSArray* array = [NSArray arrayWithObjects:img, nil];
    //[self showPreviewScreen:array];
    
    
    
    [MGImageGenerator getImagesFromVideos:url videoDurationSeconds:recordingDuartion numberOfImages:50 completionHandler:^(NSArray* result, NSError*  error) {
       
        if(error) {
            NSLog(@"Error in image generation: %@", error);
            return ;
        }
        
        [self showPreviewScreen:result];
        [self discardVideo:url];
    }];
}



#pragma mark - Preview View Controller
- (void) showPreviewScreen:(NSArray*) images {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PreviewImageViewController* previewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"PreviewImageViewController"];
        [previewController setImageArray:images];
        [self.navigationController pushViewController:previewController animated:YES];
    });
  
}


#pragma mark - CleanUp Methods 

- (void) discardVideo:(NSURL*) url {

    if(!url)
        return;
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[url relativePath] error:&error];

    if(error)
        NSLog(@"Error occurred in removing video: %@", error.description);
    
}



#pragma mark - 

#pragma mark - Alert Mehtod

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
                                    [vision startPreview];
                                }];
    
    [alert addAction:yesButton];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
    

}

#pragma mark - Timer

- (void) startRecordingTimer {
    

    elapsedTime = 0;
    _recordingTimer = [NSTimer scheduledTimerWithTimeInterval:RECODRING_TIMER target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
 
    [_recordingTimer fire];
}


- (void) updateTime {
    

    if(elapsedTime >= recordingDuartion + 1 ) {
        [self stopRecording];
        return;
    }
    
    elapsedTime += 1;
    _lblRecordingDuration.text = [NSString stringWithFormat:@"00:%02d", elapsedTime];

}

- (void) stopRecording {
    [_recordingTimer invalidate];
    _recordingTimer = nil;
    [[PBJVision sharedInstance] endVideoCapture];
}

#pragma mark - IBAction

- (IBAction)onStartRecording:(id)sender {
    //[vision startPreview];
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
    
    quality = selectedValue;
    vision.captureSessionPreset = [dictResolution objectForKey:selectedValue];
    vision.videoFrameRate = frameRate;
}

-(void) onFPSSelect:(id)dp {
    NSString* selectedValue = [self.fpsDownPicker text];
    
    if( !selectedValue || [selectedValue isEqualToString:@""])
        return;
    frameRate = [selectedValue intValue];
    //vision.captureSessionPreset =  [dictResolution objectForKey:quality];
    vision.videoFrameRate = frameRate;
}

-(void) onDurationSelect:(id)dp {
    NSString* selectedValue = [self.durationDownPicker text];
    
    if( !selectedValue || [selectedValue isEqualToString:@""])
        return;
    
    recordingDuartion = [selectedValue intValue];
}

#pragma mark - UI TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {            // called when 'return' key pressed. return NO to ignore.
    
    [textField resignFirstResponder];
    
    NSString *bitrate = textField.text;
    
    if([bitrate isEqualToString:@""])
        return YES;
    
    [vision setVideoBitRate:[bitrate floatValue]];
    
    return YES;
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
