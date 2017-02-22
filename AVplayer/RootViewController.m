//
//  RootViewController.m
//  AVplayer
//
//  Created by qianfeng on 14-4-20.
//  Copyright (c) 2014年 aofel. All rights reserved.
//

#import "RootViewController.h"
#import "VideoView.h"
//带有avplayer要使用的常量和结构体参数。
#import <CoreMedia/CoreMedia.h>
@interface RootViewController ()
{
    VideoView * _videoView;//显示视频画面。
    AVPlayer *_player;//流媒体播放器
    UISlider *_progressSlider;//显示并调节进度
}
@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self uiConfig];
}
// ui布局
-(void)uiConfig
{
    _videoView=[[VideoView alloc]initWithFrame:CGRectMake(0, 64, 320, 240)];
    [self.view addSubview:_videoView];
    UIButton *play=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [play setTitle:@"播放" forState:UIControlStateNormal];
    play.frame=CGRectMake(110, 310, 100, 30);
    [play addTarget: self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:play];
    
    UIButton *pasue=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [pasue setTitle:@"暂停" forState:UIControlStateNormal];
    [pasue setFrame:CGRectMake(110, 350, 100, 30)];
    [pasue addTarget:self action:@selector(pasueVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pasue];
    _progressSlider=[[UISlider alloc]initWithFrame:CGRectMake(10, 390, 300, 30)];
    _progressSlider.maximumValue=1.0;
    _progressSlider.minimumValue=0.0;
    [_progressSlider addTarget:self action:@selector(sliderValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_progressSlider];
}
-(void)sliderValue:(UISlider *)sli
{
    float progress=sli.value;
    CMTime total=_player.currentItem.duration;
    //CMTimeMultiplyByFloat64  会根据 总的时长，和progress指示的进度，来算出视频需要跳转到的时间，
    //seekToTime  让播放器跳转到指定的时间。
    [_player seekToTime:CMTimeMultiplyByFloat64(total, progress)];
    
}
-(void)pasueVideo
{
    if (_player) {
        [_player pause];
    }
}
-(void)playVideo
{
   NSString * path=[[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"];
  //  NSString * path=@"http://v.ku6.com/fetchwebm/H3j0knEoQilXCL1OJs7Gmw...m3u8?rate=700";
    [self playVideoWithPath:path];
}

-(void)playVideoWithPath:(NSString *)path
{
    if (_player) {
        //播放器存在，调用play方法，暂停时，会继续播放，如果处于播放状态，play无效果。
        [_player play];
        return;
    }
    if (path.length==0) {
        NSLog(@"path错误");
        return;
    }
    NSURL *url;
    if ([path rangeOfString:@"http://"].location!=NSNotFound||[path rangeOfString:@"https://"].location!=NSNotFound) {
        url=[NSURL URLWithString:path];
            }
    else
    {
        url=[NSURL fileURLWithPath:path];
    }
    //AVAsset 对视频url资源进行缓冲的类。
    AVAsset * aset=[AVAsset assetWithURL:url];
    //AVAsset会根据tracks关键字，对视频资源进行异步的缓冲加载。
    [aset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"]  completionHandler:^{
        //加载完成后  判断资源的加载状态
        //加载状态通过关键字tracks关键字拿到.
        AVKeyValueStatus status=[aset statusOfValueForKey:@"tracks" error:nil];
        if (status==AVKeyValueStatusLoaded) {
            //视频正确，预加载完毕。
            //根据缓冲类得到一个item对象，AVPlayerItem会赋值给播放器，里面带有视频总时长，当前播放进度等信息。
            AVPlayerItem *playItem=[AVPlayerItem  playerItemWithAsset:aset];
            //得到一个流媒体视频播放器，
            _player=[[AVPlayer alloc]initWithPlayerItem:playItem];
            //播放器传递给videoview
            [_videoView setPlayer:_player];
            [_player play];
            //需要获取视频的播放进度
            //CMTime  是视频对应时间的结构体.包含一个32位和64位的值（1.0，1.0）可以看做一秒
            //视频播放器每隔一秒取一次视频播放时间，此操作比较耗时，需要在主线程之外开辟一个子线程。
            //两个地方对变量引用，一定是一强一弱引用。强强引用会造成 引用的死锁，变量不能被抛弃.
            __weak RootViewController *myRoot=self;
            [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_global_queue(0, 0) usingBlock:^(CMTime time) {
                //单独的线程
                RootViewController *blockVc=myRoot;
                //通过blockVC调用——player 不会造成{}block 中对_player强引用，
                //获取当前视频的播放时间
                // block 不会对_player进行强引用。
                CMTime current=blockVc->_player.currentItem.currentTime;
                //获取总时间
                CMTime total=blockVc->_player.currentItem.duration;
                //CMTimeGetSeconds 将CMtime 视频播放器使用的时间转化成秒
                float progress=CMTimeGetSeconds(current)/CMTimeGetSeconds(total);
                //回到主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progress>=0.0&&progress<=1.0) {
                        
                        blockVc->_progressSlider.value=progress;

                    }
               });
            }];
        }
    }];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
