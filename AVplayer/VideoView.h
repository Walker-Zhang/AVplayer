//
//  VideoView.h
//  AVplayer
//
//  Created by qianfeng on 14-4-20.
//  Copyright (c) 2014年 aofel. All rights reserved.
//

#import <UIKit/UIKit.h>
//带有AVPlayer的视频播放器和AVAudioPlay的音频播放器。
#import <AVFoundation/AVFoundation.h>
@interface VideoView : UIView
//定制播放视频的View
//传递视频播放器
//AVPlayer 流媒体视频播放器，能够播放大多数固定格式的视频，和大多数m3u8格式的视频，范围比movieplayer要广。
-(void)setPlayer:(AVPlayer *)myPlayer;
@end
