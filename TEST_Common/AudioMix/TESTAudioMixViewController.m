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
@property (nonatomic, strong) AVMutableComposition *composition;


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
    
    
    
    /*
     注意：audioMix.inputParameters属性关键字是copy！！！
     所以直接调用self.audioMix.inputParameters[0]修改音量是不会生效的!
     必须要重新生成AVMutableAudioMixInputParameters才行,
     可以用mutableCopy复制一个，也可以拿到原来的track重新生成一个
     */
    
    // 方法1
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *parameters1 = [[self.audioMix.inputParameters objectAtIndex:0] mutableCopy];
    [parameters1 setVolume:self.slider1.value atTime:kCMTimeZero];
    
    AVMutableAudioMixInputParameters *parameters2 = [[self.audioMix.inputParameters objectAtIndex:1] mutableCopy];
    [parameters2 setVolume:self.slider2.value atTime:kCMTimeZero];
    
    audioMix.inputParameters = @[parameters1, parameters2];
    self.playerItem.audioMix = audioMix;
     
    
    
    // 方法2
//    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
//    NSArray<AVAssetTrack *> *audioAssetTrackArray = [self.composition tracksWithMediaType:AVMediaTypeAudio];
//    AVMutableAudioMixInputParameters *parameters1 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:[audioAssetTrackArray objectAtIndex:0]];
//    [parameters1 setVolume:self.slider1.value atTime:kCMTimeZero];
//
//    AVMutableAudioMixInputParameters *parameters2 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:[audioAssetTrackArray objectAtIndex:1]];
//    [parameters2 setVolume:self.slider2.value atTime:kCMTimeZero];
//    audioMix.inputParameters = @[parameters1, parameters2];
//    self.playerItem.audioMix = audioMix;
    
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
    self.composition = composition;
    
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    
    // 注意：这里必须要用audioCompositionTrack1而不能用audioTrack1，否则会因为trackId不一致而不生效
    AVMutableAudioMixInputParameters *inputParameters1 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioCompositionTrack1];
    [inputParameters1 setVolume:1 atTime:kCMTimeZero];
    
    AVMutableAudioMixInputParameters *inputParameters2 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioCompositionTrack2];
    [inputParameters2 setVolume:1 atTime:kCMTimeZero];
    audioMix.inputParameters = @[inputParameters1, inputParameters2];
    self.audioMix = audioMix;
    
    // videoComposition在这个场景下是没有必要的
//    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:composition];
    
    
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
