//
//  iKeyboardNormalModeViewController.m
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "iKeyboardNormalModeViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#define BORDER_WIDTH_OF_KEYBOARD_IMAGE 2

@interface iKeyboardNormalModeViewController ()

@end

@implementation iKeyboardNormalModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.octaveNo = 4;
    
    [self MCPlayerInit];
    [self UIbuild];
    
    
  //  AudioServicesPlaySystemSound(playSoundID);
    // Do any additional setup after loading the view.
}

-(void) MCPlayerInit
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"piano_a0" ofType:@"wav"];
    NSURL* urlPath = [NSURL fileURLWithPath:path];
    CFURLRef url = (__bridge CFURLRef)urlPath;
    
    OSStatus status = AudioFileOpenURL(url, kAudioFileReadPermission, 0, &aqData.mAudioFile);
    if (status == noErr)
    {
        // 透過AudioFileGetProperty從檔案中獲得音檔資訊
        UInt32 dataFormat = sizeof(aqData.mDataFormat);
        AudioFileGetProperty(aqData.mAudioFile, kAudioFilePropertyDataFormat, &dataFormat, &aqData.mDataFormat);
        
        // 建立Audio Queue
        AudioQueueNewOutput(&aqData.mDataFormat, HandleOutputBuffer, &aqData, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &aqData.mQueue);
        
        // 取出最大的packet size計算buffer會需要
        UInt32 maxPacketSize;
        UInt32 propertySize = sizeof(maxPacketSize);
        AudioFileGetProperty(aqData.mAudioFile, kAudioFilePropertyPacketSizeUpperBound, &propertySize, &maxPacketSize);
        
        // 計算需要讀取的packet
        DeriveBufferSize(aqData.mDataFormat, maxPacketSize, 0.5, &aqData.bufferByteSize, &aqData.mNumberPacketToRead);
        
        // 如果是VBR的話會有packet description
        BOOL isFormatVBR = aqData.mDataFormat.mBytesPerPacket == 0 || aqData.mDataFormat.mFramesPerPacket == 0;
        if (isFormatVBR) {
            aqData.mPacketDecription = (AudioStreamPacketDescription *) malloc(aqData.mNumberPacketToRead * sizeof(AudioStreamPacketDescription));
        }
        else {  // CBR不需要設定
            aqData.mPacketDecription = NULL;
        }
        
        // 調整音量
        Float32 gain = 1.0;
        AudioQueueSetParameter(aqData.mQueue, kAudioQueueParam_Volume, gain);
        
        // 初始化設定
        aqData.mCurrentPacket = 0;
        aqData.mIsRunning = true;
        
        // 這邊就是開始初始化buffer並且丟入我們剛剛寫的callback之中取讀取資料
        for (int i = 0; i<kNumberOfBuffers; i++) {
            AudioQueueAllocateBuffer(aqData.mQueue, aqData.bufferByteSize, &aqData.mBuffers[i]);
            HandleOutputBuffer(&aqData, aqData.mQueue, aqData.mBuffers[i]);
        }
        
        // 萬事俱備後就可以開始播放
        AudioQueuePrime(aqData.mQueue, kNumberOfBuffers, NULL);
    }
}

void DeriveBufferSize(AudioStreamBasicDescription asbd, UInt32 maxPacketSize, Float64 seconds, UInt32 *outputBufferSize, UInt32 *outputNumberOfPacketToRead)
{
    static const int maxBufferSize = 0x50000;    //320k
    static const int minBufferSize = 0x4000;     //64k
    
    // 如果有取得到frame資訊，就去計算一段時間內(seconds)需要取得多少packet
    if (asbd.mFramesPerPacket!=0) {
        Float64 numberPacketForTime = asbd.mSampleRate / asbd.mFramesPerPacket * seconds;
        *outputBufferSize = numberPacketForTime * maxPacketSize;
    }
    else {
        // 如果沒有就取最大packet或是buffer的size
        *outputBufferSize = MAX(maxBufferSize, maxPacketSize);
    }
    
    // 限制buffer size在定義的range裡面
    if (*outputBufferSize > maxBufferSize && *outputBufferSize > maxPacketSize) {
        *outputBufferSize = maxBufferSize;
    }
    else {
        if (*outputBufferSize < minBufferSize) {
            *outputBufferSize = minBufferSize;
        }
    }
    
    *outputNumberOfPacketToRead = *outputBufferSize / maxPacketSize;
}

static void HandleOutputBuffer(void *inAqData, AudioQueueRef inQueue, AudioQueueBufferRef inBuffer)
{
    MCAudioPlayerState *aqData = inAqData;
    if (aqData->mIsRunning ==0)
        return;
    
    
    // 從檔案讀取出需要播放的packet數量以及使用多少byte
    UInt32 numberBytesReadFromFile;
    UInt32 numberPackets = aqData->mNumberPacketToRead;
    AudioFileReadPackets(aqData->mAudioFile, false, &numberBytesReadFromFile, aqData->mPacketDecription, aqData->mCurrentPacket, &numberPackets, inBuffer->mAudioData);
    
    if (numberPackets>0) {
        // 設定buffer所使用的byte大小
        inBuffer->mAudioDataByteSize = numberBytesReadFromFile;
        
        // 將buffer放進queue之中
        AudioQueueEnqueueBuffer(aqData->mQueue, inBuffer, (aqData->mPacketDecription ? numberPackets : 0), aqData->mPacketDecription);
        
        // 將讀取packet位置往前移
        aqData->mCurrentPacket += numberPackets;
    }
    else {
        // 如果沒有packet要讀取，代表已經讀完檔案
        AudioQueueStop(aqData->mQueue, false);
        aqData->mIsRunning = false;
    }
}

#pragma mark - User Interface

-(void) UIbuild
{
    self.wholeKeyboardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyboard.png"]];
    [self.wholeKeyboardImageView.layer setBorderWidth:1];
   // [self.wholeKeyboardImageView.layer setBorderWidth:BORDER_WIDTH_OF_KEYBOARD_IMAGE];
    self.wholeKeyboardImageView.frame = CGRectMake(0, CGRectGetMinY(self.view.frame)+CGRectGetHeight(self.view.frame)/5, self.view.frame.size.width, self.view.frame.size.height/6);
    [self.view addSubview:self.wholeKeyboardImageView];
    
    self.frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frame.png"]];
    // [self.wholeKeyboardImageView.layer setBorderWidth:BORDER_WIDTH_OF_KEYBOARD_IMAGE];
    [self.frameImageView sizeToFit];
    self.frameImageView.frame = CGRectMake(251, CGRectGetMinY(self.wholeKeyboardImageView.frame), self.frameImageView.frame.size.width+4, self.frameImageView.frame.size.height);
    [self.view addSubview:self.frameImageView];
    
    self.keyboardBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"part_of_keyboard.png"]];
    [self.keyboardBgImageView.layer setBorderWidth:BORDER_WIDTH_OF_KEYBOARD_IMAGE];
   // self.keyboardBgImageView.backgroundColor = [UIColor yellowColor];
    self.keyboardBgImageView.frame = CGRectMake(0, CGRectGetMidY(self.view.frame), self.view.frame.size.width, self.view.frame.size.height/2);
    [self.view addSubview:self.keyboardBgImageView];
    
    CGFloat oneKeyWidth = (self.keyboardBgImageView.frame.size.width-BORDER_WIDTH_OF_KEYBOARD_IMAGE*8)/7;
    
    CGFloat keyX = BORDER_WIDTH_OF_KEYBOARD_IMAGE;
    CGFloat keyY = CGRectGetMinY(self.keyboardBgImageView.frame)+BORDER_WIDTH_OF_KEYBOARD_IMAGE;
    CGFloat keyHeight = self.keyboardBgImageView.frame.size.height-BORDER_WIDTH_OF_KEYBOARD_IMAGE;
    
    self.whiteKeyImageViewArray = [[NSMutableArray alloc] init];
  
    for(int i=0; i<7; i++)
    {
        NSString* imageName = [NSString stringWithFormat:@"white%d.png", i+1];
        NSString* highlightImageName = [NSString stringWithFormat:@"white%d_highlight.png", i+1];
        UIImageView* whiteKeyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName] highlightedImage:[UIImage imageNamed:highlightImageName]];

        whiteKeyImageView.frame = CGRectMake(keyX, keyY, oneKeyWidth, keyHeight);
        whiteKeyImageView.tag = i;
        [whiteKeyImageView setUserInteractionEnabled:YES];
        
        UILongPressGestureRecognizer *tapGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(keyTapped:)];
        [tapGestureRecognizer setMinimumPressDuration:0.01];
  //      [tapGestureRecognizer setNumberOfTapsRequired:1];
  //      [tapGestureRecognizer setNumberOfTouchesRequired:1];
        [whiteKeyImageView addGestureRecognizer:tapGestureRecognizer];
        
        [self.view addSubview:whiteKeyImageView];
        [self.whiteKeyImageViewArray addObject:whiteKeyImageView];
        keyX += BORDER_WIDTH_OF_KEYBOARD_IMAGE + oneKeyWidth;
    }
    
    UIButton* lArrowButton = [[UIButton alloc] init];
    lArrowButton.tag = 0;
    [lArrowButton setImage:[UIImage imageNamed:@"leftArrow.png"] forState:UIControlStateNormal];
    [lArrowButton setFrame:CGRectMake(20, CGRectGetMinY(self.keyboardBgImageView.frame)-30, 50, 20)];
    [lArrowButton addTarget:self action:@selector(arrowButtoClicked:) forControlEvents:UIControlEventTouchUpInside];
 //   [self.switchModeButton setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:lArrowButton];
    
    UIButton* rArrowButton = [[UIButton alloc] init];
    rArrowButton.tag = 1;
    [rArrowButton setImage:[UIImage imageNamed:@"rightArrow.png"] forState:UIControlStateNormal];
    [rArrowButton setFrame:CGRectMake(500, CGRectGetMinY(self.keyboardBgImageView.frame)-30, 50, 20)];
    [rArrowButton addTarget:self action:@selector(arrowButtoClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rArrowButton];
}

#pragma mark - Actions

- (void) arrowButtoClicked:(UIButton*) sender
{
    if(sender.tag == 0)
    {
        NSLog(@"left arrow clicked");
        if(self.octaveNo > 1)
        {
            [self.frameImageView setFrame:CGRectMake(self.frameImageView.frame.origin.x - self.frameImageView.frame.size.width, self.frameImageView.frame.origin.y, self.frameImageView.frame.size.width, self.frameImageView.frame.size.height)];
            self.octaveNo--;
        }
    }
    else
    {
        NSLog(@"right arrow clicked");
        if(self.octaveNo < 7)
        {
            [self.frameImageView setFrame:CGRectMake(self.frameImageView.frame.origin.x + self.frameImageView.frame.size.width, self.frameImageView.frame.origin.y, self.frameImageView.frame.size.width, self.frameImageView.frame.size.height)];
            self.octaveNo++;
        }
    }
}

- (void) keyTapped:(UILongPressGestureRecognizer*) recognizer
{
    UIImageView* imageView = (UIImageView*)recognizer.view;
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        AudioQueueStart(aqData.mQueue, NULL);
        int keyNo = (int)imageView.tag;
        NSLog(@"tap key %d", keyNo);
        imageView.highlighted = YES;
       
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"end");
        imageView.highlighted = NO;
        AudioQueueStop(aqData.mQueue, YES);
        
        aqData.mCurrentPacket = 0;
        aqData.mIsRunning = true;
        
        // 這邊就是開始初始化buffer並且丟入我們剛剛寫的callback之中取讀取資料
        for (int i = 0; i<kNumberOfBuffers; i++) {
            AudioQueueAllocateBuffer(aqData.mQueue, aqData.bufferByteSize, &aqData.mBuffers[i]);
            HandleOutputBuffer(&aqData, aqData.mQueue, aqData.mBuffers[i]);
        }
        AudioQueuePrime(aqData.mQueue, kNumberOfBuffers, NULL);
    }
}

#pragma mark - the others

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
