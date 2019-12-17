//
//  LaunchAnimationVC.m
//  Accompany
//
//  Created by Hock on 2019/12/16.
//  Copyright © 2019 chenlong. All rights reserved.
//
#define SCREEN_BOUNDS [UIScreen mainScreen].bounds

#import "LaunchAnimationVC.h"
#import <AVKit/AVKit.h>

@interface  LaunchAnimationVC () <AVPlayerViewControllerDelegate>

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation  LaunchAnimationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.videoUrl.length) {
        if (self.playFinished) {
            self.playFinished();
        }
        return;
    }
    
    NSURL *url;
    if ([self.videoUrl hasPrefix:@"http"]) {
        url = [NSURL URLWithString:self.videoUrl];
    } else {
        url = [NSURL fileURLWithPath:self.videoUrl];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    UIImage *image = [self getVideoPreViewImage:url];
    imageView.image = image;
    [self.view addSubview:imageView];
    
    [self play_AVPlayer:url];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)play_AVPlayer:(NSURL *)url {
    if (!url) {
        if (self.playFinished) {
            self.playFinished();
        }
        return;
    }
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = SCREEN_BOUNDS;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:playerLayer];
    [self.player play];
}

#pragma mark --- NSNotificationCenter
- (void)videoPlayEnd:(NSNotification *)notification {
    if (self.playFinished) {
        self.playFinished();
    }
}

// 根据url获取视频第一帧图片
- (UIImage*)getVideoPreViewImage:(NSURL *)url {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    return img;
}

// 旋转图片(如果有横竖屏，可以通过旋转获得图片)
- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation {
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = -M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
