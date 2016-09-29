//
//  iKeyboardNormalModeViewController.m
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "iKeyboardNormalModeViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AssetsLibrary/AssetsLibrary.h"
#import "iKeyboardMenuViewController.h"
#import "AppDelegate.h"

#define IPhone4 [[UIScreen mainScreen] bounds].size.width == (double)480
#define IPhone5 [[UIScreen mainScreen] bounds].size.width == (double)568
#define IPhone6 [[UIScreen mainScreen] bounds].size.width == (double)667
#define IPhone6sPlus [[UIScreen mainScreen] bounds].size.width == (double)736
#define viewW CGRectGetWidth(self.view.frame)
#define viewH CGRectGetHeight(self.view.frame)

#undef DEBUG

@interface iKeyboardNormalModeViewController ()

@end

@implementation iKeyboardNormalModeViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.x = malloc(sizeof(int)*4);
    bzero(self.x, sizeof(int)*4);
    self.count = 0;
    
    self.isRecording = NO;
    self.audioPlayerReady = NO;
    self.photoPickViewShowing = NO;
    self.isPlayingRecord = NO;

    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.keyPressingArray = malloc(sizeof(int)*4);
    bzero(self.keyPressingArray, sizeof(int)*4);
    
    //self.keyPressing = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0], nil];
    self.keyPressing = [[NSMutableArray alloc] init];
    
    self.showingSettingPage = NO;
    self.showingPlusPage = NO;
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
  //  self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    self.keyBeingTappedFrameArray = [[NSMutableArray alloc] initWithObjects:NSStringFromCGRect(CGRectZero), NSStringFromCGRect(CGRectZero), NSStringFromCGRect(CGRectZero), nil];
    self.keyBeingTappedIndexArray = malloc(sizeof(int)*4);
    bzero(self.keyBeingTappedIndexArray, sizeof(int)*4);
    
    self.lowerOctaveNo = 3;
    self.sheetSelectedNo = 1;
    self.sheetNo = 1;
    self.instrumentNo = 1;
    self.instrumentSelectedNo = 1;
    
    NSString* sheetPlistPath = [NSString stringWithFormat:@"%@/Documents/sheets.plist", NSHomeDirectory()];
    self.sheetNameMap = [NSMutableArray arrayWithContentsOfFile:sheetPlistPath];
    
 //   self.sheetNameMap = [[NSMutableArray alloc] initWithObjects:@"Moon Sonata", @"CANON in D", @"Fur Elise", nil];
    self.sheetButtonArray = [[NSMutableArray alloc] init];
    self.noteNameArray = [[NSArray alloc] initWithObjects:@"C", @"D", @"E", @"F", @"G", @"A", @"B", nil];
    self.halfStepArray = [[NSArray alloc] initWithObjects:@"C", @"D", @"F", @"G", @"A", nil];
    self.instrumentNameMap = [[NSArray alloc] initWithObjects:@"bass", @"piano", @"guitar", @"drum", nil];
    
    NSMutableArray* highlightedKeyImageViewArray = [[NSMutableArray alloc] init];
    for(int i=0; i<24; i++)
    {
        NSString* imageName = [NSString stringWithFormat:@"key%d_highlight.png", i];
        UIImageView* highlightedKeyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        highlightedKeyImageView.frame = self.view.frame;
        [highlightedKeyImageViewArray addObject:highlightedKeyImageView];
    }
    self.highlightedKeyImageViewArray = highlightedKeyImageViewArray;
    
    [self UIbuild];
    [self.view addSubview:self.mistView];
    [self.view addSubview:self.spinner];
    [NSThread detachNewThreadSelector:@selector(AVAudioPlayerInit) toTarget:self withObject:nil];
    
    //return app detecter
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

//do something when return
- (void)didBecomeActive:(NSNotification *)notification;
{
    [self AVAudioPlayerInit];
}

-(void) bluetoothMesHandler:(const char*) mes
{
    if(mes[0] != 0x02)
    {
        NSLog(@"Command code wrong: %02lX", (long)mes[0]);
        return;
    }
    
    if(!self.audioPlayerReady)
        return;
    int playingPointer = 0;
    for(int i=0; i<MIN((long)mes[1], 3); i++){
        int keyNo = (int)mes[i+2];
#ifdef DEBUG
        NSLog(@"%02lX", (long)mes[i+2]);
#endif
        if(keyNo){
            if(keyNo == 25)
                [self goLowerOctave];
            else if(keyNo == 26)
                [self goHigherOctave];
            else if(!self.showingSettingPage && _keyPressing.count > 0){
                //for(playingPointer; playingPointer < [_keyPressing count];playingPointer++){
                while(true){
                    if(playingPointer >= [_keyPressing count]){
                        [self.view addSubview:self.highlightedKeyImageViewArray[keyNo-1]];
                        [NSThread detachNewThreadSelector:@selector(tapBeganOnKey:) toTarget:self withObject:[NSNumber numberWithInt:keyNo-1]];
                        //[self tapBeganOnKey:keyNo-1];
                        NSNumber* newPlay = [NSNumber numberWithInt:keyNo-1];
                        [_keyPressing addObject:newPlay];
                        playingPointer++;
                        break;
                    }
                    else{
                        int playingKey = [_keyPressing[playingPointer] intValue];
                        if(playingKey > keyNo-1){
                            [self.view addSubview:self.highlightedKeyImageViewArray[keyNo-1]];
                            [NSThread detachNewThreadSelector:@selector(tapBeganOnKey:) toTarget:self withObject:[NSNumber numberWithInt:keyNo-1]];
                            //[self tapBeganOnKey:keyNo-1];
                            NSNumber* newPlay = [NSNumber numberWithInt:keyNo-1];
                            [_keyPressing insertObject:newPlay atIndex:playingPointer];
                            playingPointer++;
                            break;
                        }
                        else if(playingKey < keyNo-1){
                            [self.highlightedKeyImageViewArray[[self.keyPressing[playingPointer] intValue]] removeFromSuperview];
                            [NSThread detachNewThreadSelector:@selector(tapEndedOnKey:) toTarget:self withObject:self.keyPressing[playingPointer]];
                            [_keyPressing removeObjectAtIndex:playingPointer];
                        }
                        else {
                            playingPointer++;
                            break;
                        }
                    }
                }
                if(i == (MIN((long)mes[1], 3)-1) && playingPointer < [_keyPressing count]){
                    for(playingPointer; playingPointer < [_keyPressing count];playingPointer++){
                        [self.highlightedKeyImageViewArray[[self.keyPressing[playingPointer] intValue]] removeFromSuperview];
                        [NSThread detachNewThreadSelector:@selector(tapEndedOnKey:) toTarget:self withObject:self.keyPressing[playingPointer]];
                        [_keyPressing removeObjectAtIndex:playingPointer];
                        playingPointer--;
                    }
                }
            }
            else if(!self.showingSettingPage){
                //[self tapBeganOnKey:keyNo - 1];
                NSNumber* newPlay = [NSNumber numberWithInt:keyNo-1];
                [_keyPressing addObject:newPlay];
                [self.view addSubview:self.highlightedKeyImageViewArray[keyNo-1]];
                [NSThread detachNewThreadSelector:@selector(tapBeganOnKey:) toTarget:self withObject:[NSNumber numberWithInt:keyNo-1]];
                playingPointer++;
            }
        }
        else{
            for(int j = 0; j < [_keyPressing count];j++){
                [self.highlightedKeyImageViewArray[[self.keyPressing[j] intValue]] removeFromSuperview];
                [NSThread detachNewThreadSelector:@selector(tapEndedOnKey:) toTarget:self withObject:self.keyPressing[j]];
            }
            [_keyPressing removeAllObjects];
            break;
        }
    }
}


-(void) changeIkeyboMode:(CBPeripheral*)peripheral
{
    NSString* code = @"02";
    NSData* data = [self dataWithStringHex:code];
    [peripheral writeValue:data forCharacteristic:self.appDelegate.FFA1 type:CBCharacteristicWriteWithResponse];
}

- (NSData *)dataWithStringHex:(NSString *)string
{
    NSString *cleanString;
    cleanString = [string stringByReplacingOccurrencesOfString:@"<" withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@">" withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSInteger length = [cleanString length];
    uint8_t buffer[length/2];
    for (NSInteger i = 0; i < length; i+=2)
    {
        unsigned result = 0;
        NSScanner *scanner = [NSScanner scannerWithString:[cleanString substringWithRange:NSMakeRange(i, 2)]];
        [scanner scanHexInt:&result];
        buffer[i/2] = result;
    }
    return  [[NSMutableData alloc] initWithBytes:&buffer   length:length/2];
}

#pragma mark - AVAudio Player

-(void) AVAudioPlayerInit
{
    NSString* instrumentName = self.instrumentNameMap[self.instrumentNo];
    NSMutableArray* octavesArray = [[NSMutableArray alloc] init];
    NSString *path;
    AVAudioPlayer* player;
    for(int i=0; i<7; i++)
    {
        NSMutableArray*  playersArray= [[NSMutableArray alloc] init];
        [octavesArray addObject:playersArray];
        for(NSString* noteName in self.noteNameArray)
        {
            NSString* fileName = [NSString stringWithFormat:@"%@_%@%d", instrumentName, noteName, i+1];
            path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                      [NSURL fileURLWithPath:path] error:NULL];
            
            [player prepareToPlay];
            [playersArray addObject:player];
        }
        for(NSString* halfStep in self.halfStepArray)
        {
            NSString* fileName = [NSString stringWithFormat:@"%@_%@%d#", instrumentName, halfStep, i+1];
            path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                      [NSURL fileURLWithPath:path] error:NULL];
            [player prepareToPlay];
            [playersArray addObject:player];
        }
    }
    
    self.octavesArray = octavesArray;
        
    [self performSelectorOnMainThread:@selector(removeSpinnerAndMistView) withObject:nil waitUntilDone:NO];
    self.audioPlayerReady = YES;
}

#pragma mark - User Interface

-(void)removeSpinnerAndMistView
{
    [self.mistView removeFromSuperview];
    [self.spinner removeFromSuperview];
}

-(void) screenCheck
{
    if(IPhone4)
    {
        self.keyboard_left_padding = 40;
        self.keyboard_padding = 1;
        self.blackKeySize = CGSizeMake(20, 56);
        self.blackKeyOffsetVector = CGVectorMake(23, 15);
    }
    else if(IPhone5)
    {
        self.keyboard_left_padding = 10;
        self.keyboard_right_padding = 13;
        self.keyboard_padding = 1;
        self.blackKeySize = CGSizeMake(24, 45);
        self.blackKeyOffsetVector = CGVectorMake(22, 22);
    }
    else if(IPhone6)
    {
        self.keyboard_left_padding = 12;
        self.keyboard_right_padding = 15;
        self.keyboard_padding = 1;
        self.blackKeySize = CGSizeMake(28, 52);
        self.blackKeyOffsetVector = CGVectorMake(26, 26);
        self.keyboardHeight = 160;
    }
    else if(IPhone6sPlus)
    {
        self.keyboard_left_padding = 52;
        self.keyboard_padding = 2;
        self.blackKeySize = CGSizeMake(31, 75);
        self.blackKeyOffsetVector = CGVectorMake(36, 21);
    }
}

-(void) UIbuild
{
    [self screenCheck];
    
    UIImageView* BGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background0.png"]];
    BGImageView.frame = self.view.frame;
    [self.view addSubview:BGImageView];
 
    UIImageView* keyboardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Piano-1.png"]];
    keyboardImageView.frame = self.view.frame;
    [self.view addSubview:keyboardImageView];
    
    UIImageView* barImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bar_under_sheet-2.png"]];
    barImageView.frame = self.view.frame;
    [self.view addSubview:barImageView];
    
    
    UIImageView* settingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Menu_button3.png"]];
    settingImageView.frame = CGRectMake(viewW*0.015, viewH*0.006, viewW*0.031, viewH*0.055);
    [self.view addSubview:settingImageView];
    
    UIButton* settingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewW*0.08, viewH*0.1)];
    [settingButton addTarget:self action:@selector(settingButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingButton];
    
    UIImageView* bluetoothIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bluetooth_gray3.png"]];
    bluetoothIconImageView.frame = CGRectMake(viewW*0.95, 0, viewW*0.035, viewH*0.07);
    [self.view addSubview:bluetoothIconImageView];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewW*0.45, 0, viewW*0.1, viewH*0.07)];
    titleLabel.text = @"iKeybo";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];
  
    [self drawTablatureScrollView];
    
    self.littleKeyboImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Scrollnotes-1.png"]];
    self.littleKeyboImageView.frame = CGRectMake(viewW*0.311, viewH*0.593, viewW*0.266, viewH*0.114);
    [self.view addSubview:self.littleKeyboImageView];
    
    self.octaveView = [[UIView alloc] initWithFrame:CGRectMake(0, viewH*0.6, viewW, viewH*0.1)];
    [_octaveView setUserInteractionEnabled:YES];
    UISwipeGestureRecognizer *swipeOctiveRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(octaveSwiped:)];
    swipeOctiveRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeOctiveLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(octaveSwiped:)];
    swipeOctiveLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [_octaveView addGestureRecognizer:swipeOctiveLeft];
    [_octaveView addGestureRecognizer:swipeOctiveRight];
    [self.view addSubview:_octaveView];
    
    self.leftMistBar = [[UIView alloc] initWithFrame:CGRectMake(viewW*0.02, viewH*0.6, viewW*0.295, viewH*0.1)];
    self.leftMistBar.tag = 0;
    UITapGestureRecognizer* tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(arrowImageViewClicked:)];
    tapGest.numberOfTapsRequired = 1;
    tapGest.numberOfTouchesRequired = 1;
    [self.leftMistBar addGestureRecognizer:tapGest];
    [self.view addSubview:self.leftMistBar];
    
    self.rightMistBar = [[UIView alloc] initWithFrame:CGRectMake(viewW*0.573, viewH*0.6, viewW*0.402, viewH*0.1)];
    self.rightMistBar.tag = 1;
    tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(arrowImageViewClicked:)];
    tapGest.numberOfTapsRequired = 1;
    tapGest.numberOfTouchesRequired = 1;
    [self.rightMistBar addGestureRecognizer:tapGest];
    [self.view addSubview:self.rightMistBar];

    CGFloat oneKeyWidth = (viewW - self.keyboard_left_padding - self.keyboard_right_padding/* - self.keyboard_padding*13*/)/14;
    CGFloat keyX = self.keyboard_left_padding;
    CGFloat keyY = viewH*0.72;
    CGFloat keyHeight = viewH*0.28;
    
    NSMutableArray* keyViewArray = [[NSMutableArray alloc] init];
    
    //White Keys
    for(int i=0; i<14; i++)
    {
        UIView* whiteKeyView = [[UIImageView alloc] init];
        whiteKeyView.frame = CGRectMake(keyX, keyY, oneKeyWidth, keyHeight);
     //   whiteKeyView.backgroundColor = [UIColor redColor];
     //   whiteKeyView.alpha = 0.5;
        [self.view addSubview:whiteKeyView];
        keyX += /*self.keyboard_padding +*/ oneKeyWidth;
        [keyViewArray addObject:whiteKeyView];
        
    }

    //Black keys
    keyX = self.keyboard_left_padding;
    for(int i=0; i<10; i++)
    {
        UIView* blackKeyView = [[UIView alloc] init];
     //   blackKeyView.backgroundColor = [UIColor blueColor];
     //   blackKeyView.alpha = 0.5;
        switch (i)
        {
            case 0:
                keyX += self.blackKeyOffsetVector.dx;
                break;
            case 2: case 7:
                keyX += self.blackKeyOffsetVector.dx*2 + self.keyboard_padding;
                break;
            case 5:
                keyX += self.blackKeyOffsetVector.dx*2 + self.keyboard_padding - 2;
                break;
            default:
                keyX += self.blackKeyOffsetVector.dy;
                break;
        }
        
        blackKeyView.frame = CGRectMake(keyX, keyY, self.blackKeySize.width, self.blackKeySize.height);
        keyX += self.blackKeySize.width;
        [self.view addSubview:blackKeyView];
    
        [keyViewArray addObject:blackKeyView];
    }
    
    self.keyViewArray = keyViewArray;
   
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = CGRectMake(CGRectGetMidX(self.view.frame)-25, CGRectGetMidY(self.view.frame)-25, 50, 50);
    self.spinner.backgroundColor = [UIColor grayColor];
    //self.spinner.alpha = 0.7;
    self.spinner.layer.cornerRadius = 5;
    [self.spinner startAnimating];
   
    self.mistView = [[UIView alloc] initWithFrame:self.view.frame];
    self.mistView.backgroundColor = [UIColor blackColor];
    self.mistView.alpha = 0.5;
    
    self.fingerSensorView = [[UIView alloc] initWithFrame:CGRectMake(self.keyboard_left_padding, keyY, viewW-self.keyboard_left_padding-self.keyboard_right_padding, viewH*0.28)];
    self.fingerSensorView.backgroundColor = [UIColor clearColor];
    self.fingerSensorView.multipleTouchEnabled = YES;
 /*
    self.tapGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(tap:)];
    self.tapGestureRecognizer.delegate = self;
   // self.tapGestureRecognizer.numberOfTouchesRequired = 2;
    [self.tapGestureRecognizer setMinimumPressDuration:0.01];
    [self.fingerSensorView addGestureRecognizer:self.tapGestureRecognizer];
    
    self.tapGestureRecognizer2 = [[UILongPressGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(tap:)];
    self.tapGestureRecognizer2.delegate = self;
    [self.tapGestureRecognizer2 setMinimumPressDuration:0.01];
    [self.fingerSensorView addGestureRecognizer:self.tapGestureRecognizer2];
    
    self.tapGestureRecognizer3 = [[UILongPressGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(tap:)];
    self.tapGestureRecognizer3.delegate = self;
    [self.tapGestureRecognizer3 setMinimumPressDuration:0.01];
    [self.fingerSensorView addGestureRecognizer:self.tapGestureRecognizer3];
    */
  //  [self.fingerSensorView setMultipleTouchEnabled:YES];
    
    [self.view addSubview:self.fingerSensorView];
  
    [self drawSettingPageView];
    
    UIButton* recordButton = [[UIButton alloc] initWithFrame:CGRectMake(560, 50, 80, 25)];
    recordButton.layer.borderWidth = 1;
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
   // [recordButton setBackgroundColor:[UIColor redColor]];
    [recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(recordButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordButton];
    
    UIButton* playMenuButton = [[UIButton alloc] initWithFrame:CGRectMake(470, 50, 80, 25)];
    playMenuButton.layer.borderWidth = 1;
    playMenuButton.tag = 0;
    [playMenuButton setTitle:@"Play" forState:UIControlStateNormal];
    [playMenuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [playMenuButton addTarget:self action:@selector(playMenuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playMenuButton];
    
    self.recordView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, viewW, viewH-100)];
    self.recordView.backgroundColor = [UIColor whiteColor];
    self.recordView.layer.borderWidth = 1;
    
    NSFileManager* fm = [[NSFileManager alloc] init];
    NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
    if(![fm fileExistsAtPath:recordPlistPath])
    {
        NSString* orgRecordPlistPath = [[NSBundle mainBundle] pathForResource:@"record" ofType:@"plist"];
        [fm copyItemAtPath:orgRecordPlistPath toPath:recordPlistPath error:nil];
        recordPlistPath = orgRecordPlistPath;
    }
    
    NSArray* recordArray = [NSMutableArray arrayWithContentsOfFile:recordPlistPath];
    NSLog(@"%@", recordArray);
    int width = 80;
    for(int i=0; i<recordArray.count; i++)
    {
        if([fm fileExistsAtPath:recordArray[i]])
            NSLog(@"EXIST");
        UIButton* playerButton = [[UIButton alloc] initWithFrame:CGRectMake(50+width*i, 50, 80, 25)];
        playerButton.layer.borderWidth = 1;
        playerButton.tag = i;
        [playerButton setTitle:@"Play" forState:UIControlStateNormal];
        [playerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [playerButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.recordView addSubview:playerButton];
    }
}

-(void) drawSettingPageView
{
    self.settingPageView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImageView* BGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background1.png"]];
    BGImageView.frame = self.view.frame;
    [self.settingPageView addSubview:BGImageView];
    
    UIButton* leaveSettingPageButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0, CGRectGetHeight(self.view.frame)*0, CGRectGetWidth(self.view.frame)*0.1, CGRectGetHeight(self.view.frame)*0.15)];
    [leaveSettingPageButton addTarget:self action:@selector(settingButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.settingPageView addSubview:leaveSettingPageButton];

    
    //draw instructment menu
    self.instrumentMenuScrollView = [[UIScrollView alloc] init];
    self.instrumentMenuScrollView.frame = CGRectMake(viewW*0.084, viewH*0.58, viewW*0.832, viewH*0.243);
    for(int i=0; i<[self.instrumentNameMap count]; i++)
    {
        UIButton* instrumentButton = [[UIButton alloc] init];
        NSString* imageName = [NSString stringWithFormat:@"%@.png", self.instrumentNameMap[i]];
        [instrumentButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        instrumentButton.tag = i;
        instrumentButton.adjustsImageWhenHighlighted = NO;
        [instrumentButton setFrame:CGRectMake(CGRectGetWidth(self.instrumentMenuScrollView.frame)*(0.36+i*0.32), CGRectGetHeight(self.instrumentMenuScrollView.frame)*0.1
                                              , CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.28, self.instrumentMenuScrollView.frame.size.height*0.9)];
        [instrumentButton addTarget:self action:@selector(instrumentClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.instrumentMenuScrollView addSubview:instrumentButton];
    }
    [self.instrumentMenuScrollView setUserInteractionEnabled:YES];
    [self.instrumentMenuScrollView setScrollEnabled:NO];
    self.instrumentMenuScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.instrumentMenuScrollView.frame)*(0.72+0.32*[self.instrumentNameMap count]-0.04), CGRectGetHeight(self.instrumentMenuScrollView.frame));
    
    self.instrumentMenuScrollView.contentOffset = CGPointMake(self.instrumentMenuScrollView.contentOffset.x+CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.32, 0);
    
    [self.settingPageView addSubview:self.instrumentMenuScrollView];
    
    UIButton* lastInstrumentButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.instrumentMenuScrollView.frame), CGRectGetMinY(self.instrumentMenuScrollView.frame), CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.08, CGRectGetHeight(self.instrumentMenuScrollView.frame))];
    lastInstrumentButton.tag = 0;
    [lastInstrumentButton addTarget:self action:@selector(instrumentNextOrLastButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingPageView addSubview:lastInstrumentButton];
    
    UIButton* nextInstrumentButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.instrumentMenuScrollView.frame)+CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.967, CGRectGetMinY(self.instrumentMenuScrollView.frame), CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.08, CGRectGetHeight(self.instrumentMenuScrollView.frame))];
    nextInstrumentButton.tag = 1;
    [nextInstrumentButton addTarget:self action:@selector(instrumentNextOrLastButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingPageView addSubview:nextInstrumentButton];
    
    //add swipe Gesture
    UISwipeGestureRecognizer *swipeInstrumentRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(instrumentLastSwipe:)];
    swipeInstrumentRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeInstrumentLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(instrumentNextSwipe:)];
    swipeInstrumentLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [_instrumentMenuScrollView addGestureRecognizer:swipeInstrumentLeft];
    [_instrumentMenuScrollView addGestureRecognizer:swipeInstrumentRight];
    
    //draw tablature menu
    
    self.tablatureMenuScrollView = [[UIScrollView alloc] init];
    self.tablatureMenuScrollView.frame = CGRectMake(viewW*0.084, viewH*0.19, viewW*0.832, viewH*0.243);
    
    for(int i=0; i<[self.sheetNameMap count]; i++)
    {
        UIButton* icon = [[UIButton alloc] init];
        [icon setImage:[UIImage imageNamed:@"Sheets1.png"] forState:UIControlStateNormal];
        [icon setUserInteractionEnabled:NO];
     //   UIImageView* icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sheets1.png"]];
        icon.tag = i;
        int x = i - (int)[self.sheetNameMap count]/2;
        [icon setFrame:CGRectMake(CGRectGetWidth(self.tablatureMenuScrollView.frame)*(0.7+x*0.3), CGRectGetHeight(self.tablatureMenuScrollView.frame)*0.1, CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.2, self.tablatureMenuScrollView.frame.size.height*0.9)];
        [self.tablatureMenuScrollView addSubview:icon];
        [self.sheetButtonArray addObject:icon];
        
        UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(icon.frame), CGRectGetMaxY(icon.frame)-CGRectGetHeight(icon.frame)*0.3, CGRectGetWidth(icon.frame), CGRectGetHeight(icon.frame)*0.2)];
        nameLabel.text = [self.sheetNameMap objectAtIndex:i];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.numberOfLines = 2;
        nameLabel.adjustsFontSizeToFitWidth = YES;
        [self.tablatureMenuScrollView addSubview:nameLabel];
    }
    [self.tablatureMenuScrollView setUserInteractionEnabled:YES];
    [self.tablatureMenuScrollView setScrollEnabled:NO];
    self.tablatureMenuScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.tablatureMenuScrollView.frame)*(1.4+0.3*[self.instrumentNameMap count]-0.1), CGRectGetHeight(self.tablatureMenuScrollView.frame));
    self.tablatureMenuScrollView.contentOffset = CGPointMake(self.tablatureMenuScrollView.contentOffset.x+CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.3, 0);
    [self.settingPageView addSubview:self.tablatureMenuScrollView];
    
    UIButton* lastSheetButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.tablatureMenuScrollView.frame), CGRectGetMinY(self.tablatureMenuScrollView.frame), CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.08, CGRectGetHeight(self.tablatureMenuScrollView.frame))];
    lastSheetButton.tag = 0;
    [lastSheetButton addTarget:self action:@selector(sheetNextOrLastButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingPageView addSubview:lastSheetButton];
    
    UIButton* nextSheetButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.tablatureMenuScrollView.frame)+CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.967, CGRectGetMinY(self.tablatureMenuScrollView.frame), CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.08, CGRectGetHeight(self.tablatureMenuScrollView.frame))];
    nextSheetButton.tag = 1;
    [nextSheetButton addTarget:self action:@selector(sheetNextOrLastButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingPageView addSubview:nextSheetButton];
    
    //add swipe Gesture
    UISwipeGestureRecognizer *swipeSheetRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sheetLastSwipe:)];
    swipeSheetRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeSheetLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sheetNextSwipe:)];
    swipeSheetLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [_tablatureMenuScrollView addGestureRecognizer:swipeSheetLeft];
    [_tablatureMenuScrollView addGestureRecognizer:swipeSheetRight];
    
    UIButton* trashCanButton = [[UIButton alloc] initWithFrame:CGRectMake(viewW*0.79, viewH*0.1, 30, 30)];
    [trashCanButton addTarget:self action:@selector(trashCanButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [trashCanButton setImage:[UIImage imageNamed:@"trashCanIcon.png"] forState:UIControlStateNormal];
    [self.settingPageView addSubview:trashCanButton];
    
    UIButton* plusIconButton = [[UIButton alloc] initWithFrame:CGRectMake(viewW*0.86, viewH*0.1, 30, 30)];
    [plusIconButton addTarget:self action:@selector(plusIconClicked) forControlEvents:UIControlEventTouchUpInside];
    [plusIconButton setImage:[UIImage imageNamed:@"plusIcon.png"] forState:UIControlStateNormal];
    [self.settingPageView addSubview:plusIconButton];
    
    UIButton* doneButton = [[UIButton alloc] initWithFrame:CGRectMake(viewW*0.45, viewH*0.89, viewW*0.1, viewH*0.08)];
    [doneButton addTarget:self action:@selector(doneButtonInSettingPageClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.settingPageView addSubview:doneButton];
    
    [self drawPlusPage];
    [self drawPhotoPickPage];
}

-(void) drawPhotoPickPage
{
    self.photoPickView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImageView* BGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Add_Sheet3.png"]];
    BGImageView.frame = self.photoPickView.frame;
    [self.photoPickView addSubview:BGImageView];
    
    UIButton* plusIconButton = [[UIButton alloc] initWithFrame:CGRectMake(viewW*0.86, viewH*0.1, 30, 30)];
    [plusIconButton addTarget:self action:@selector(plusIconClicked) forControlEvents:UIControlEventTouchUpInside];
    [plusIconButton setImage:[UIImage imageNamed:@"plusIcon.png"] forState:UIControlStateNormal];
    [self.photoPickView addSubview:plusIconButton];
    
    NSMutableArray* photoButtonArray = [[NSMutableArray alloc] init];
    CGFloat x = viewW*0.197;
    CGFloat y = viewH*0.27;
    CGFloat width = viewW*0.13;
    CGFloat height = viewH*0.21;
    for(int i=0; i<17; i++)
    {
        UIButton* photoButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [photoButton addTarget:self action:@selector(photoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        photoButton.tag = i;
        [photoButton setBackgroundColor:[UIColor whiteColor]];
        photoButton.alpha = 0.5;
        photoButton.layer.cornerRadius = 5;
        [photoButton.layer setMasksToBounds:YES];
        [photoButton setUserInteractionEnabled:NO];
        
        [self.photoPickView addSubview:photoButton];
        
        if(!((i+2)%6))
        {
            x -= (width + viewW*0.007)*5;
            y += height + viewH*0.024;
        }
        else
            x += width + viewW*0.007;
        
        [photoButtonArray addObject:photoButton];
    }
    self.photoButtonArray = photoButtonArray;
    
    UIButton* cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(viewW*0.06, viewH*0.27, width, height)];
    [cameraButton addTarget:self action:@selector(cameraButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.photoPickView addSubview:cameraButton];
}

-(void)drawPlusPage
{
    self.plusPageView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImageView* BGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Add_Sheet4.png"]];
    BGImageView.frame = self.plusPageView.frame;
    [self.plusPageView addSubview:BGImageView];
    
    UIImageView* uploadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(viewW*0.613, viewH*0.27, viewW*0.24, viewH*0.38)];
    uploadImageView.tag = 1;
    uploadImageView.backgroundColor = [UIColor whiteColor];
    uploadImageView.alpha = 0.3;
    uploadImageView.layer.cornerRadius = 10;
    [uploadImageView.layer setMasksToBounds:YES];
    
    [self.plusPageView addSubview:uploadImageView];
    
    UIButton* uploadButton = [[UIButton alloc] initWithFrame:CGRectMake(viewW*0.648, viewH*0.34, viewW*0.17, viewH*0.24)];
    [uploadButton setImage:[UIImage imageNamed:@"Upload_Sheet4.png"] forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(uploadButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.plusPageView addSubview:uploadButton];
    
    UIButton* plusIconButton = [[UIButton alloc] initWithFrame:CGRectMake(viewW*0.86, viewH*0.1, 30, 30)];
    [plusIconButton addTarget:self action:@selector(plusIconClicked) forControlEvents:UIControlEventTouchUpInside];
    [plusIconButton setImage:[UIImage imageNamed:@"plusIcon.png"] forState:UIControlStateNormal];
    [self.plusPageView addSubview:plusIconButton];
    
    UITextField* sheetNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(viewW*0.613, viewH*0.67, viewW*0.24, viewH*0.07)];
    sheetNameTextField.alpha = 0.5;
    sheetNameTextField.backgroundColor = [UIColor grayColor];
    sheetNameTextField.layer.cornerRadius = 10;
    sheetNameTextField.layer.borderWidth = 2;
    sheetNameTextField.layer.borderColor=[[UIColor whiteColor] CGColor];
    sheetNameTextField.delegate = self;
    sheetNameTextField.textAlignment = NSTextAlignmentCenter;
    sheetNameTextField.textColor = [UIColor whiteColor];
    [self.plusPageView addSubview:sheetNameTextField];
  
    UIButton* doneButton = [[UIButton alloc] initWithFrame: CGRectMake(viewW*0.68, viewH*0.8, viewW*0.1, viewW*0.043)];
    [doneButton setImage:[UIImage imageNamed:@"DONE_button.png"] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonInPlusPageClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.plusPageView addSubview:doneButton];
}

-(void) drawTablatureScrollView
{
    self.tablatureScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(viewW*0.02, viewH*0.085, viewW*0.962, viewH*0.47)];
    [self.view addSubview:self.tablatureScrollView];
 
    self.tablatureImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CANON in D.jpg"]];
    self.tablatureImageView.backgroundColor = [UIColor whiteColor];
    [self.tablatureImageView sizeToFit];
    float scale = CGRectGetWidth(self.tablatureScrollView.frame)/self.tablatureImageView.frame.size.width;
    self.tablatureImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tablatureScrollView.frame), self.tablatureImageView.frame.size.height*scale);
    [self.tablatureScrollView addSubview:self.tablatureImageView];
    
    self.tablatureScrollView.contentSize = self.tablatureImageView.frame.size;
}

#pragma mark - Actions

-(void)playMenuButtonClicked:(UIButton*)sender
{
    if(!sender.tag)
    {
        [self.view addSubview:self.recordView];
        sender.tag = 1;
        NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
        self.recordArray = [NSMutableArray arrayWithContentsOfFile:recordPlistPath];
        int buttonCount = (int)self.recordArray.count;
        for(int i=0; i<5; i++)
        {
            if([self.recordView viewWithTag:i] && i >= buttonCount)
                [[self.recordView viewWithTag:i] removeFromSuperview];
            else if(![self.recordView viewWithTag:i] && i < buttonCount)
            {
                int x;
                if(i == 0)
                    x = 50;
                else
                    x = [self.recordView viewWithTag:i-1].frame.origin.x;
                UIButton* playerButton = [[UIButton alloc] initWithFrame:CGRectMake(x, 50, 80, 25)];
                playerButton.layer.borderWidth = 1;
                playerButton.tag = i;
                [playerButton setTitle:@"Play" forState:UIControlStateNormal];
                [playerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [playerButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.recordView addSubview:playerButton];
            }
        }
    }
    else
    {
        [self.recordView removeFromSuperview];
        sender.tag = 0;
    }
}

-(void)playButtonClicked:(UIButton*)sender
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSError * error;

    NSURL* url = [NSURL URLWithString:self.recordArray[sender.tag]];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.delegate = self;
    BOOL success = [self.audioPlayer play];
    if (success) {
        NSLog(@"播放成功");
    }else{
        NSLog(@"播放失败");
    }

}

-(void) recordButtonClicked
{
    if(!self.isRecording)
    {
        NSError* error;
        NSString * url = NSHomeDirectory();
        url = [url stringByAppendingString:[NSString stringWithFormat:@"%f.wav", [[NSDate date] timeIntervalSince1970]]];
        NSMutableDictionary* settings = [[NSMutableDictionary alloc] init];
        [settings setObject:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
        [settings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [settings setObject:@1 forKey:AVNumberOfChannelsKey];
        [settings setObject:@16 forKey:AVLinearPCMBitDepthKey];
        
        NSFileManager* fm = [[NSFileManager alloc] init];
        NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
        NSMutableArray* recordArray = [NSMutableArray arrayWithContentsOfFile:recordPlistPath];

        if(recordArray.count == 5)
        {
            NSString* deletePath = recordArray[0];
            if([fm fileExistsAtPath:deletePath])
                [fm removeItemAtPath:deletePath error:nil];
            for(int i=0; i<4; i++)
                recordArray[i] = recordArray[i+1];
            [recordArray setObject:url atIndexedSubscript:4];
        }
        else
            [recordArray addObject:url];
        
  //      NSLog(@"%d", [recordArray writeToFile:recordPlistPath atomically:YES]);
        
        self.audioRecorder = [[AVAudioRecorder  alloc] initWithURL:[NSURL fileURLWithPath:url] settings:settings error:&error];
        self.audioRecorder.meteringEnabled = YES;
        self.audioRecorder.delegate = self;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
        BOOL success = [self.audioRecorder record];
        if(success)
        {
            NSLog(@"Success");
            self.isRecording = YES;
        }
        else
            NSLog(@"Fail");
    }
    else
    {
        [self.audioRecorder stop];
        self.isRecording = NO;
    }
}

-(void) uploadButtonClicked
{
    [self.view addSubview:self.photoPickView];
    self.photoPickViewShowing = YES;
}

-(void) cameraButtonClicked
{
    
}

-(void)doneButtonInPlusPageClicked
{
}

-(void)instrumentClicked:(UIButton*) sender{
    if(self.instrumentSelectedNo > (int)sender.tag){
        self.instrumentMenuScrollView.contentOffset = CGPointMake(self.instrumentMenuScrollView.contentOffset.x-CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.32, 0);
    }
    else if(self.instrumentSelectedNo < (int)sender.tag){
        self.instrumentMenuScrollView.contentOffset = CGPointMake(self.instrumentMenuScrollView.contentOffset.x+CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.32, 0);
    }
    
    self.instrumentSelectedNo = (int)sender.tag;
    
    [self doneButtonInSettingPageClicked];
}

-(void)doneButtonInSettingPageClicked
{
    if(self.sheetNo != self.sheetSelectedNo)
    {
        NSString* imageName = [NSString stringWithFormat:@"%@.jpg", self.sheetNameMap[self.sheetSelectedNo]];
        [self.tablatureImageView setImage: [UIImage imageNamed:imageName]];
        [self.tablatureImageView sizeToFit];
        float scale = CGRectGetWidth(self.tablatureScrollView.frame)/self.tablatureImageView.frame.size.width;
        self.tablatureImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tablatureScrollView.frame), self.tablatureImageView.frame.size.height*scale);
    
        self.tablatureScrollView.contentSize = self.tablatureImageView.frame.size;
        
        self.sheetNo = self.sheetSelectedNo;
    }
    
    if(self.instrumentNo != self.instrumentSelectedNo)
    {
        [self.view addSubview:self.mistView];
        [self.view addSubview:self.spinner];
        self.instrumentNo = self.instrumentSelectedNo;
        [NSThread detachNewThreadSelector:@selector(AVAudioPlayerInit) toTarget:self withObject:nil];
    }
    
    [self.settingPageView removeFromSuperview];
    self.showingSettingPage = NO;
}

-(void)trashCanButtonClicked
{
    for(UIButton* sheetIcon in self.sheetButtonArray)
    {
        [sheetIcon setImage:[UIImage imageNamed:@"Sheets_delete2.png"] forState:UIControlStateNormal];
        [sheetIcon setUserInteractionEnabled:YES];
    }
}

-(void)photoButtonClicked:(UIButton*)sender
{
    ((UIImageView*)([self.plusPageView viewWithTag:1])).image = self.photoArray[sender.tag];
    ((UIImageView*)([self.plusPageView viewWithTag:1])).alpha = 0.8;
    [self.photoPickView removeFromSuperview];
}

-(void)plusIconClicked
{
    if(self.photoPickViewShowing)
    {
        [self.photoPickView removeFromSuperview];
        self.photoPickViewShowing = NO;
    }
    else if(!self.showingPlusPage)
    {
        [self.view addSubview:self.mistView];
        [self.view addSubview:self.plusPageView];
        
        ((UIImageView*)([self.plusPageView viewWithTag:1])).image = NULL;
        ((UIImageView*)([self.plusPageView viewWithTag:1])).alpha = 0.3;
        for(int i=0; i<16; i++)
        {
            if(i < [self.photoArray count])
            {
                [self.photoButtonArray[i] setImage:self.photoArray[i] forState:UIControlStateNormal];
                ((UIButton*)(self.photoButtonArray[i])).alpha = 1;
                [((UIButton*)(self.photoButtonArray[i])) setUserInteractionEnabled:YES];
            }
            else
            {
                ((UIButton*)(self.photoButtonArray[i])).alpha = 0.5;
                [((UIButton*)(self.photoButtonArray[i])) setUserInteractionEnabled:NO];
            }
        }
        self.showingPlusPage = YES;
    }
    else
    {
        [self.mistView removeFromSuperview];
        [self.plusPageView removeFromSuperview];
        self.showingPlusPage = NO;
    }
}

- (ALAssetsLibrary *)sharedAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *assetsLibrary = nil;
    dispatch_once(&pred, ^{
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    });
    return assetsLibrary;
}

-(void)sheetNextOrLastButtonClicked:(UIButton*)sender
{
    if(!sender.tag)
    {
        if(self.sheetSelectedNo > 0)
        {
            self.tablatureMenuScrollView.contentOffset = CGPointMake(self.tablatureMenuScrollView.contentOffset.x-CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.3, 0);
            self.sheetSelectedNo--;
        }
    }
    else
    {
        if(self.sheetSelectedNo < 3-1)
        {
            self.tablatureMenuScrollView.contentOffset = CGPointMake(self.tablatureMenuScrollView.contentOffset.x+CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.3, 0);
            self.sheetSelectedNo++;
        }
    }
}

-(void)sheetNextSwipe:(UISwipeGestureRecognizer *)gestureRecognizer{
    if(self.sheetSelectedNo < 3-1)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.tablatureMenuScrollView.contentOffset = CGPointMake(self.tablatureMenuScrollView.contentOffset.x+CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.3, 0);
        }];
        self.sheetSelectedNo++;
        
    }
}

-(void)sheetLastSwipe:(UISwipeGestureRecognizer *)gestureRecognizer{
    if(self.sheetSelectedNo > 0)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.tablatureMenuScrollView.contentOffset = CGPointMake(self.tablatureMenuScrollView.contentOffset.x-CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.3, 0);
        }];
        self.sheetSelectedNo--;
    }
}

-(void)instrumentNextOrLastButtonClicked:(UIButton*)sender
{
    if(!sender.tag)
    {
        if(self.instrumentSelectedNo > 0)
        {
            self.instrumentMenuScrollView.contentOffset = CGPointMake(self.instrumentMenuScrollView.contentOffset.x-CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.32, 0);
            self.instrumentSelectedNo--;
        }
    }
    else
    {
        if(self.instrumentSelectedNo < [self.instrumentNameMap count]-1)
        {
            self.instrumentMenuScrollView.contentOffset = CGPointMake(self.instrumentMenuScrollView.contentOffset.x+CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.32, 0);
            self.instrumentSelectedNo++;
        }
    }
}

-(void)instrumentNextSwipe:(UISwipeGestureRecognizer *)gestureRecognizer{
    if(self.instrumentSelectedNo < [self.instrumentNameMap count]-1)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.instrumentMenuScrollView.contentOffset = CGPointMake(self.instrumentMenuScrollView.contentOffset.x+CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.32, 0);
        }];
        self.instrumentSelectedNo++;
    }
}
-(void)instrumentLastSwipe:(UISwipeGestureRecognizer *)gestureRecognizer{
    if(self.instrumentSelectedNo > 0)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.instrumentMenuScrollView.contentOffset = CGPointMake(self.instrumentMenuScrollView.contentOffset.x-CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.32, 0);
        }];
        self.instrumentSelectedNo--;
    }
}


-(void)settingButtonClicked
{
    if(!self.showingSettingPage)
    {
        [self.view addSubview:self.settingPageView];
        self.showingSettingPage = YES;
        
        /*self.photoArray = [[NSMutableArray alloc] init];
        
        ALAssetsGroupEnumerationResultsBlock resultBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result && [[result valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto])
            {
                UIImage* image = [UIImage imageWithCGImage:result.defaultRepresentation.fullResolutionImage];
                [self.photoArray addObject:image];
            }
        };
        
        ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group && group.numberOfAssets > 0)
            {
                [group enumerateAssetsWithOptions:0
                                       usingBlock:nil];
                //[group enumerateAssetsUsingBlock:resultBlock];
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
            
        };
        
        ALAssetsGroupType type = ALAssetsGroupAll;
        
        [self.sharedAssetsLibrary enumerateGroupsWithTypes:type
                                                usingBlock:resultsBlock
                                              failureBlock:failureBlock];
         */
    }
    else
    {
        /*self.tablatureMenuScrollView.contentOffset = CGPointMake(self.tablatureMenuScrollView.contentOffset.x+CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.3*(self.sheetNo-self.sheetSelectedNo), 0);
         self.instrumentMenuScrollView.contentOffset = CGPointMake(self.instrumentMenuScrollView.contentOffset.x+CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.31*(self.instrumentNo-self.instrumentSelectedNo), 0);
         */
        
        //self.sheetSelectedNo = self.sheetNo;
        //self.instrumentSelectedNo = self.instrumentNo;
        
        [self doneButtonInSettingPageClicked];
        
        [self.settingPageView removeFromSuperview];
        self.showingSettingPage = NO;
    }
}

-(void)tap:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:self.view];
    
    int gestNo;
    if(sender == (UIGestureRecognizer*)self.tapGestureRecognizer)
        gestNo = 0;
    else if(sender == (UIGestureRecognizer*)self.tapGestureRecognizer2)
        gestNo = 1;
    else// if(sender == (UIGestureRecognizer*)self.tapGestureRecognizer3)
        gestNo = 2;
    
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"tapped began!");
        for(int i=(int)[self.keyViewArray count]-1; i >= 0; i--)
        {
            CGRect keyRect = ((UIView*)self.keyViewArray[i]).frame;
            if(CGRectContainsPoint(keyRect, point))
            {
                [self.keyBeingTappedFrameArray setObject:NSStringFromCGRect(keyRect) atIndexedSubscript:gestNo];
                self.keyBeingTappedIndexArray[gestNo] = i;
                NSNumber* playKey = [NSNumber numberWithInt:i];
                [self.view addSubview:self.highlightedKeyImageViewArray[i]];
                [self tapBeganOnKey:playKey];
                break;
            }
        }
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
      //  NSLog(@"tapped end!");
        if(![self.keyBeingTappedFrameArray[gestNo] isEqualToString:NSStringFromCGRect(CGRectZero)])
        {
            [self.highlightedKeyImageViewArray[self.keyBeingTappedIndexArray[gestNo]] removeFromSuperview];
            [NSThread detachNewThreadSelector:@selector(tapEndedOnKey:) toTarget:self withObject:[NSNumber numberWithInt:self.keyBeingTappedIndexArray[gestNo]]];
    
            self.keyBeingTappedFrameArray[gestNo] = NSStringFromCGRect(CGRectZero);
        }
    }
    else if(sender.state == UIGestureRecognizerStateChanged)
    {
       // NSLog(@"tapped changed!");
        if(![self.keyBeingTappedFrameArray[gestNo] isEqualToString:NSStringFromCGRect(CGRectZero)])
        {
            CGRect keyBeingTappedFrame = CGRectFromString(self.keyBeingTappedFrameArray[gestNo]);
            if(!CGRectContainsPoint(keyBeingTappedFrame, point))
            {
                [self.highlightedKeyImageViewArray[self.keyBeingTappedIndexArray[gestNo]] removeFromSuperview];
                [NSThread detachNewThreadSelector:@selector(tapEndedOnKey:) toTarget:self withObject:[NSNumber numberWithInt:self.keyBeingTappedIndexArray[gestNo]]];
                self.keyBeingTappedFrameArray[gestNo] = NSStringFromCGRect(CGRectZero);
            }
        }
        else
        {
            for(int i=(int)[self.keyViewArray count]-1; i >= 0; i--)
            {
                CGRect keyRect = ((UIView*)self.keyViewArray[i]).frame;
                if(CGRectContainsPoint(keyRect, point))
                {
                    self.keyBeingTappedFrameArray[gestNo] = NSStringFromCGRect(keyRect);
                    self.keyBeingTappedIndexArray[gestNo] = i;
                    [self.view addSubview:self.highlightedKeyImageViewArray[i]];
                    NSNumber* playKey = [NSNumber numberWithInt:i];
                    [self tapBeganOnKey:playKey];
                    break;
                }
            }
        }
    }
}

-(void) tapBeganOnKey:(NSNumber*)indexNum
{
    int index = [indexNum intValue];
  //  ((UIImageView*)(self.keyViewArray[index])).highlighted = YES;
    //int index = [NSindex intValue];
    self.startVolume = self.instrumentSelectedNo == 1 || self.instrumentSelectedNo == 3 ? 0.7 : 0.1 ;
    
    
    int octaveNo = self.lowerOctaveNo;
    int keyNo = index;
 
    if(index < 7);
    else if(index>6 && index<14)
    {
        octaveNo++;
        keyNo -= 7;
    }
    else if(index > 13 && index < 19)
        keyNo -= 7;
    else
    {
        octaveNo++;
        keyNo -= 12;
    }
    
    NSArray* playersArray = self.octavesArray[octaveNo-1];
    AVAudioPlayer* player = [playersArray objectAtIndex:keyNo];
    if(![player isPlaying])
    {
        player.volume = self.startVolume;
        [player play];
    }
    else
    {
        [player stop];
        player.volume = self.startVolume;
        player.currentTime = 0;
        [player play];
    }
    
}

-(void) tapEndedOnKey:(NSNumber*)index
{
    if(self.instrumentSelectedNo != 3)
    {
        int octaveNo = self.lowerOctaveNo;
        int keyNo = index.intValue;
    
        if(index.intValue < 7);
        else if(index.intValue > 6 && index.intValue < 14)
        {
            octaveNo++;
            keyNo -= 7;
        }
        else if(index.intValue > 13 && index.intValue < 19)
            keyNo -= 7;
        else
        {
            octaveNo++;
            keyNo -= 12;
        }
    
        NSArray* playersArray = self.octavesArray[octaveNo-1];
        AVAudioPlayer *player = [playersArray objectAtIndex:keyNo];
    
        int i=0;
        float de = 0.0004;
        while (i<1000000 && player.volume > 0.001)
        {
            i++;
            if (player.volume < 0.1)
                de = 0.00003;
            player.volume -= de;
        }
    }
}

-(void)goHigherOctave
{
    if(self.lowerOctaveNo < 6)
    {
        self.lowerOctaveNo++;
        self.leftMistBar.frame = CGRectMake(CGRectGetMinX(self.leftMistBar.frame), CGRectGetMinY(self.leftMistBar.frame), CGRectGetWidth(self.leftMistBar.frame)+viewW*0.129, CGRectGetHeight(self.leftMistBar.frame));
        
        self.rightMistBar.frame = CGRectMake(CGRectGetMinX(self.rightMistBar.frame)+viewW*0.129, CGRectGetMinY(self.rightMistBar.frame), CGRectGetWidth(self.rightMistBar.frame)-viewW*0.129, CGRectGetHeight(self.rightMistBar.frame));
        
        self.littleKeyboImageView.frame = CGRectMake(CGRectGetMinX(self.littleKeyboImageView.frame)+viewW*0.129, CGRectGetMinY(self.littleKeyboImageView.frame), CGRectGetWidth(self.littleKeyboImageView.frame), CGRectGetHeight(self.littleKeyboImageView.frame));
    }
}

-(void) goLowerOctave
{
    if(self.lowerOctaveNo > 1)
    {
        self.lowerOctaveNo--;
        self.leftMistBar.frame = CGRectMake(CGRectGetMinX(self.leftMistBar.frame), CGRectGetMinY(self.leftMistBar.frame), CGRectGetWidth(self.leftMistBar.frame)-viewW*0.129, CGRectGetHeight(self.leftMistBar.frame));
        self.rightMistBar.frame = CGRectMake(CGRectGetMinX(self.rightMistBar.frame)-viewW*0.129, CGRectGetMinY(self.rightMistBar.frame), CGRectGetWidth(self.rightMistBar.frame)+viewW*0.129, CGRectGetHeight(self.rightMistBar.frame));
        self.littleKeyboImageView.frame = CGRectMake(CGRectGetMinX(self.littleKeyboImageView.frame)-viewW*0.129, CGRectGetMinY(self.littleKeyboImageView.frame), CGRectGetWidth(self.littleKeyboImageView.frame), CGRectGetHeight(self.littleKeyboImageView.frame));
    }
}

- (void) arrowImageViewClicked:(UITapGestureRecognizer*) sender
{
    UIImageView* senderImageView = (UIImageView*)sender.view;
    if(senderImageView.tag == 0){
        [UIView animateWithDuration:0.1 animations:^{
            [self goLowerOctave];
        }];
    }
    else{
        [UIView animateWithDuration:0.1 animations:^{
            [self goHigherOctave];
        }];
    }
}

- (void) octaveSwiped:(UISwipeGestureRecognizer*) sender
{
    if(sender.direction == UISwipeGestureRecognizerDirectionLeft){
        [UIView animateWithDuration:0.1 animations:^{
            [self goLowerOctave];
        }];
    }
    else{
        [UIView animateWithDuration:0.1 animations:^{
            [self goHigherOctave];
        }];
    }
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    CGPoint firstPoint = [gestureRecognizer locationInView:self.view];
    CGPoint secPoint = [otherGestureRecognizer locationInView:self.view];
  //  NSLog(@"Fst: (%f, %f) Sec: (%f, %f)", firstPoint.x, firstPoint.y, secPoint.x, secPoint.y);
    if(!CGPointEqualToPoint(firstPoint, secPoint))
        return  YES;
    
    return NO;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)Event
{
    NSLog(@"Began");
    for(int i=0; i < [[touches allObjects] count]; i++)
    {
        UITouch *touch = [[touches allObjects] objectAtIndex:i];
        CGPoint point = [touch locationInView:self.view];
        for(int j=23; j >= 0; j--)
        {
            CGRect keyRect = ((UIView*)self.keyViewArray[j]).frame;
            if(CGRectContainsPoint(keyRect, point))
            {
                int top = 0;
                while(top < 3 && self.x[top] != 0)
                    top++;
                if(top == 3)
                    break;
                self.x[top] = j;
                self.count++;
                NSNumber* playKey = [NSNumber numberWithInt:j];
                [self.view addSubview:self.highlightedKeyImageViewArray[j]];
                [self tapBeganOnKey:playKey];
                break;
            }
        }
    }
    NSLog(@"%@", [NSString stringWithFormat:@"%d, %d, %d", self.x[0], self.x[1], self.x[2]]);

}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
 //   NSLog(@"move: %d", (int)[[touches allObjects] count]);
    for(int i=0; i < [[touches allObjects] count]; i++)
    {
        UITouch *touch = [[touches allObjects] objectAtIndex:i];
        CGPoint point = [touch locationInView:self.view];
        CGPoint prevPoint = [touch previousLocationInView:self.view];
        for(int j=0; j<self.count; j++)
        {
            int index = self.x[j];
            CGRect keyRect = ((UIView*)self.keyViewArray[index]).frame;
            if(CGRectContainsPoint(keyRect, prevPoint))
            {
                if(CGRectContainsPoint(keyRect, point))
                    break;
                else
                {
                    [self.highlightedKeyImageViewArray[index] removeFromSuperview];
                    [NSThread detachNewThreadSelector:@selector(tapEndedOnKey:) toTarget:self withObject:[NSNumber numberWithInt:index]];
                    
                    for(int k=23; k >= 0; k--)
                    {
                        CGRect keyRect = ((UIView*)self.keyViewArray[k]).frame;
                        if(CGRectContainsPoint(keyRect, point))
                        {
                            self.x[j] = k;
                            NSNumber* playKey = [NSNumber numberWithInt:k];
                            [self.view addSubview:self.highlightedKeyImageViewArray[k]];
                            [self tapBeganOnKey:playKey];
                            break;
                        }
                    }
                }
            }
        }
    }
 //   NSLog(@"%@", [NSString stringWithFormat:@"%d, %d, %d", self.x[0], self.x[1], self.x[2]]);
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"End");
    
    for(int i=0; i < [[touches allObjects] count]; i++)
    {
        UITouch *touch = [[touches allObjects] objectAtIndex:i];
        CGPoint point = [touch locationInView:self.view];
        for(int j=(int)[self.keyViewArray count]-1; j >= 0; j--)
        {
            CGRect keyRect = ((UIView*)self.keyViewArray[j]).frame;
            if(CGRectContainsPoint(keyRect, point))
            {
                for(int k=0; k<3; k++)
                    if(self.x[k] == j)
                    {
                        self.x[k] = 0;
                        self.count--;
                        break;
                    }
                [self.highlightedKeyImageViewArray[j] removeFromSuperview];
                [NSThread detachNewThreadSelector:@selector(tapEndedOnKey:) toTarget:self withObject:[NSNumber numberWithInt:j]];
                break;
            }
        }
    }
    NSLog(@"%@", [NSString stringWithFormat:@"%d, %d, %d", self.x[0], self.x[1], self.x[2]]);
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(0, self.view.frame.origin.y-self.keyboardHeight, self.view.frame.size.width, self.view.frame.size.height);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.view.frame = CGRectMake(0, self.view.frame.origin.y+self.keyboardHeight, self.view.frame.size.width, self.view.frame.size.height);
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
  //  UIImage * image=[info objectForKey:UIImagePickerControllerOriginalImage];
}

#pragma mark - the others

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CBPeripheralDelegate

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"didDiscoverServices:\n");
#endif
    //   if( peripheral.UUID == NULL  ) return; // zach ios6 added
    if (!error)
    {
#ifdef DEBUG
        NSLog(@"====%@\n",peripheral.name);
#endif
        
        for (CBService *s in peripheral.services)
        {
#ifdef DEBUG
            NSLog(@"Service found with UUID: %@\n", s.UUID);
#endif
            [peripheral discoverCharacteristics:nil forService:s];
        }
        
    }
    else
        NSLog(@"Service discovery was unsuccessfull !\n");
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
#ifdef DEBUG
    NSLog(@"=========== Service UUID %@ ===========\n",service.UUID);
#endif
    if (!error)
    {
#ifdef DEBUG
        NSLog(@"=========== %lu Characteristics of service ",service.characteristics.count);
#endif
        for(CBCharacteristic *c in service.characteristics)
        {
#ifdef DEBUG
            NSLog(@" %@ \n",c.UUID);
#endif
            if(service.UUID == NULL || s.UUID == NULL)
                return;
            
            if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFA0"]])
            {
                if ([c.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]])
                {
                    self.appDelegate.FFA1 = c;
                    [self changeIkeyboMode:peripheral];
                }
                else if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFA3"]])
                    [peripheral setNotifyValue:YES forCharacteristic:c];
            }
        }
    }
    else
    {
        NSLog(@"Characteristic discorvery unsuccessfull !\n");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"UUID = %@", characteristic.UUID);
#endif
    if (error)
    {
        NSLog(@"Error reading characteristics: %@", [error localizedDescription]);
        return;
    }
    if (characteristic.value != nil)
    {
        NSData* data = characteristic.value;
//        char* datas = data.bytes;
        [_soundLockTimer invalidate];
        _soundLockTimer = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self           selector:@selector(releaseLock:) userInfo:data repeats:NO];
//        [self bluetoothMesHandler:datas];
    }
}

-(void)releaseLock:(NSTimer*) timer{
    NSData *data = (NSData*)[timer userInfo];
    char* datas = data.bytes;
    [self bluetoothMesHandler:datas];
}

/*-(void)reConnectButtonClicked
{
    NSInteger* pageID = 0;
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    //if([self.delegate respondsToSelector:@selector(keyboViewDismissed:)])
    //{
        [self.delegate keyboViewDismissed:pageID];
    //}
}*/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%f", scrollView.contentOffset.x);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.scrollStop = YES;
    //scrollView.pagingEnabled = YES;
    CGFloat newx = scrollView.contentOffset.x;
    if([self scrollStop]){
        if(NSLocationInRange(scrollView.contentOffset.x, NSMakeRange(0, 89)))
            newx = 0;
        else if(NSLocationInRange(scrollView.contentOffset.x, NSMakeRange(89, 178)))
            newx = 178;
        else if(NSLocationInRange(scrollView.contentOffset.x, NSMakeRange(267, 178)))newx = 356;
        else if(NSLocationInRange(scrollView.contentOffset.x, NSMakeRange(445, 178)))
            newx = 534;
        [UIView animateWithDuration:0.5 animations:^{
            [scrollView setContentOffset:CGPointMake(newx, 0)];
        }];
    }
    //scrollView.pagingEnabled = NO;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat newx = 0;
    if(NSLocationInRange(scrollView.contentOffset.x, NSMakeRange(0, 89))){
        newx = 0;
    }
    else if(NSLocationInRange(scrollView.contentOffset.x, NSMakeRange(89, 267))){
        newx = 178;
    }
    else if(NSLocationInRange(scrollView.contentOffset.x, NSMakeRange(267, 445))){
        newx = 356;
    }
    else {
        newx = 534;
    }
    [UIView animateWithDuration:0.1 animations:^{
        [scrollView setContentOffset:CGPointMake(newx, 0)];
    }];
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"%s", __func__);
    self.url = recorder.url;
    self.audioRecorder.delegate = nil;
    self.audioRecorder = nil;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error
{
    NSLog(@"%@", error);
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"%s", __func__);
    self.audioPlayer.delegate = nil;
    self.audioPlayer = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    NSLog(@"%@", error);
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
