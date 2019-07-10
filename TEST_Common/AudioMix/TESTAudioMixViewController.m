//
//  TESTAudioMixViewController.m
//  TEST_Common
//
//  Created by luxiaoming on 2019/7/9.
//  Copyright © 2019 luxiaoming. All rights reserved.
//

#import "TESTAudioMixViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TESTAudioMixViewController ()


@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVMutableAudioMix *audioMix;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UISlider *slider1;
@property (nonatomic, strong) UISlider *slider2;



@end

@implementation TESTAudioMixViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self testAudioMix];
}

#pragma mark - PrivateMethod



- (void)setupUI {
    
    UISlider *slider1 = [[UISlider alloc] initWithFrame:CGRectMake(50, 100, kLXMScreenWidth - 100, 30)];
    slider1.value = 1;
    [slider1 addTarget:self action:@selector(handleSlider:) forControlEvents: UIControlEventValueChanged];
    [self.view addSubview:slider1];
    self.slider1 = slider1;
    
    UISlider *slider2 = [[UISlider alloc] initWithFrame:CGRectMake(50, 200, kLXMScreenWidth - 100, 30)];
    slider2.value = 1;
    [slider2 addTarget:self action:@selector(handleSlider:) forControlEvents: UIControlEventValueChanged];
    [self.view addSubview:slider2];
    self.slider2 = slider2;
    
}

#pragma mark - Action

- (void)handleSlider:(UISlider *)sender {
    
    // 必须重新创建一个AVMutableAudioMix，否则不会生效
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *parameters1 = [[self.audioMix.inputParameters objectAtIndex:0] mutableCopy];
    [parameters1 setVolume:self.slider1.value atTime:kCMTimeZero];
    
    AVMutableAudioMixInputParameters *parameters2 = [[self.audioMix.inputParameters objectAtIndex:1] mutableCopy];
    [parameters2 setVolume:self.slider2.value atTime:kCMTimeZero];
    
    audioMix.inputParameters = @[parameters1, parameters2];
    self.playerItem.audioMix = audioMix;
    
}

- (void)testAudioMix {
    
    NSString *videoPathString = [[NSBundle mainBundle] pathForResource:@"testVideo" ofType:@"mp4"];
    NSURL *videoURL = [NSURL fileURLWithPath:videoPathString];
    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:videoURL];
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    NSString *audioPathString = [[NSBundle mainBundle] pathForResource:@"testMusic" ofType:@"mp3"];
    NSURL *audioURL = [NSURL fileURLWithPath:audioPathString];
    AVURLAsset *audioAsset = [AVURLAsset assetWithURL:audioURL];
    
    AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *audioTrack1 = [videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    AVAssetTrack *audioTrack2 = [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoCompositionTrack insertTimeRange:videoTimeRange ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *audioCompositionTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioCompositionTrack1 insertTimeRange:videoTimeRange ofTrack:audioTrack1 atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *audioCompositionTrack2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioCompositionTrack2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:audioTrack2 atTime:kCMTimeZero error:nil];
    
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *inputParameters1 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioCompositionTrack1];
    [inputParameters1 setVolume:1 atTime:kCMTimeZero];
    
    AVMutableAudioMixInputParameters *inputParameters2 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioCompositionTrack2];
    [inputParameters2 setVolume:1 atTime:kCMTimeZero];
    audioMix.inputParameters = @[inputParameters1, inputParameters2];
    self.audioMix = audioMix;
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:composition];
    playerItem.audioMix = audioMix;
    self.playerItem = playerItem;
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    self.player = player;
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    self.playerLayer.frame = CGRectMake(0, kLXMNavigationBarHeight, kLXMScreenWidth, kLXMScreenHeight - kLXMNavigationBarHeight - kLXMBottomMarginHeight);
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.view.layer insertSublayer:self.playerLayer atIndex:0];
    
    [player play];
    
}


@end
