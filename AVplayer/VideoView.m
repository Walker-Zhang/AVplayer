//
//  VideoView.m
//  AVplayer
//
//  Created by qianfeng on 14-4-20.
//  Copyright (c) 2014年 aofel. All rights reserved.
//

#import "VideoView.h"

@implementation VideoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
//CALayer (层的对象)，每个UIView都附着在一个和View一样大，但不可见的层上。我们对UIView进行一些操作，需要对层进行处理。（想改变view的形状，需要通过层来改变。对view添加动画，需要在层上添加动画效果。将视频画面渲染给层，层会将画面传递给view显示，）
//调用self.layer会自动触发此方法，重写此方法，来保证返回的class为AVPlayerlayer，而不是普通的layer。
+(Class)layerClass
{
    return [AVPlayerLayer class];
}

-(void)setPlayer:(AVPlayer *)myPlayer
{
    //视频播放的层能够接受播放器的视频画面。
    AVPlayerLayer*playLayer=(AVPlayerLayer *)self.layer;
    [playLayer setPlayer:myPlayer];
    
}
@end
