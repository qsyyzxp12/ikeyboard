//
//  iKeyboardNormalModeViewController.h
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

// 從文件中可知道建議最佳Buffer數量為3
static const int kNumberOfBuffers = 3;

// 定義自己的strct
typedef struct {
    AudioStreamBasicDescription mDataFormat;        // 檔案格式的描述
    AudioQueueRef mQueue;                           // Audio Queue
    AudioQueueBufferRef mBuffers[kNumberOfBuffers]; // 用來暫存的buffer
    AudioFileID mAudioFile;                         // 檔案來源
    UInt32 bufferByteSize;                          // buffer 所需大小
    SInt64 mCurrentPacket;                          // 目前讀取到的packet數量
    UInt32 mNumberPacketToRead;                     // 總共的packet
    AudioStreamPacketDescription *mPacketDecription;// 音檔packet的描述
    bool mIsRunning;                                // 用來判斷是否正在播放
} MCAudioPlayerState;

@interface iKeyboardNormalModeViewController : UIViewController
{
    MCAudioPlayerState aqData;
}

@property UIImageView *wholeKeyboardImageView;
@property UIImageView *frameImageView;
@property UIImageView *keyboardBgImageView;
@property NSMutableArray* whiteKeyImageViewArray;
@property int octaveNo;
@property int graphSampleRate;

@end
