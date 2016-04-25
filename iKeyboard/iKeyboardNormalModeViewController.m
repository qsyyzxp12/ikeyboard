//
//  iKeyboardNormalModeViewController.m
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "iKeyboardNormalModeViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#define IPhone4 [[UIScreen mainScreen] bounds].size.width == (double)480
#define IPhone5 [[UIScreen mainScreen] bounds].size.width == (double)568
#define IPhone6 [[UIScreen mainScreen] bounds].size.width == (double)667
#define IPhone6sPlus [[UIScreen mainScreen] bounds].size.width == (double)736

@interface iKeyboardNormalModeViewController ()

@end

@implementation iKeyboardNormalModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lowerOctaveNo = 3;
    self.instrumentNo = 1;
    self.preloadInstrumentFinishedOctaveNo = 0;
    
    self.noteArray = [[NSArray alloc] initWithObjects:@"C", @"D", @"E", @"F", @"G", @"A", @"B", nil];
    self.halfStepArray = [[NSArray alloc] initWithObjects:@"C", @"D", @"F", @"G", @"A", nil];
    self.instrumentNameMap = [[NSArray alloc] initWithObjects:@"guitar", @"piano", @"string", nil];
    
    self.screenHeight = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height;
    
    [self AVAudioPlayerInit];
    [self UIbuild];
}

#pragma mark - AVAudio Player

-(void) AVAudioPlayerInit
{
    NSMutableArray* playersArray = [[NSMutableArray alloc] init];
    
    for(int j=3; j<5; j++)
    {
        for(NSString* noteName in self.noteArray)
        {
           // NSLog(@"%@", [NSString stringWithFormat:@"%@_%@%d", self.instrumentNameMap[self.instrumentNo], noteName, j]);
            NSString* whiteKeySoundFileName = [NSString stringWithFormat:@"%@_%@%d", self.instrumentNameMap[self.instrumentNo], noteName, j];
            NSString* path = [[NSBundle mainBundle] pathForResource:whiteKeySoundFileName ofType:@"mp3"];
            AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                                         [NSURL fileURLWithPath:path] error:NULL];
                
            [player prepareToPlay];
            [playersArray addObject:player];
        }
    }
    
    
    for(int i=3; i<5; i++)
    {
        for(NSString* halfStepNote in self.halfStepArray)
        {
            NSLog(@"%@", [NSString stringWithFormat:@"%@_%@%d#", self.instrumentNameMap[self.instrumentNo], halfStepNote, i]);
            NSString* blackKeySoundFileName = [NSString stringWithFormat:@"%@_%@%d#", self.instrumentNameMap[self.instrumentNo], halfStepNote, i];
            NSString* path = [[NSBundle mainBundle] pathForResource:blackKeySoundFileName ofType:@"mp3"];
            AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                                         [NSURL fileURLWithPath:path] error:NULL];
            [player prepareToPlay];
            [playersArray addObject:player];
        }
    }
    
    self.playersArray = playersArray;
    NSArray* argu = [NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:0], nil];
    NSThread *newThread = [[NSThread alloc] initWithTarget:self selector:@selector(preloadPlayers:) object:argu];
    [newThread start];
    
    NSArray* argu2 = [NSArray arrayWithObjects:[NSNumber numberWithInt:4], [NSNumber numberWithInt:1], nil];
    NSThread *newThread2 = [[NSThread alloc] initWithTarget:self selector:@selector(preloadPlayers:) object:argu2];
    [newThread2 start];
    
    NSThread* newThread3 = [[NSThread alloc] initWithTarget:self selector:@selector(preloadOtherInstrument:) object:[NSNumber numberWithInt:self.lowerOctaveNo]];
    [newThread3 start];
}

-(void)preloadOtherInstrument:(NSNumber*)lowerOctaveNo
{
    
    NSMutableDictionary* instrumentPlayersDic = [[NSMutableDictionary alloc] init];
    for(NSString* name in self.instrumentNameMap)
    {
        if(![name isEqualToString:self.instrumentNameMap[self.instrumentNo]])
        {
            NSArray* playersArray = [self loadTwoOctaveWithLowerOctave:lowerOctaveNo.intValue instrumentName:name];
            [instrumentPlayersDic setObject:playersArray forKey:name];
        }
    }
    self.instrumentPlayersDic = instrumentPlayersDic;
    self.preloadInstrumentFinishedOctaveNo = lowerOctaveNo.intValue;
}

-(void)avaudioPlayerGoUpper:(BOOL)isGoUpper
{
    if(isGoUpper)
    {
        self.lastPlayersArray = self.playersArray;
        self.playersArray = self.nextPlayersArray;
        if(self.lowerOctaveNo != 6)
        {
            NSArray* argu = [NSArray arrayWithObjects:[NSNumber numberWithInt:self.lowerOctaveNo+1], [NSNumber numberWithInt:1], nil];
            NSThread* newThread = [[NSThread alloc] initWithTarget:self selector:@selector(preloadPlayers:) object:argu];
            [newThread start];
        }
    }
    else
    {
        self.nextPlayersArray = self.playersArray;
        self.playersArray = self.lastPlayersArray;
        if(self.lowerOctaveNo != 1)
        {
            NSArray* argu = [NSArray arrayWithObjects:[NSNumber numberWithInt:self.lowerOctaveNo-1], [NSNumber numberWithInt:0], nil];
            NSThread* newThread = [[NSThread alloc] initWithTarget:self selector:@selector(preloadPlayers:) object:argu];
            [newThread start];
        }
    }
}

-(void)preloadPlayers:(NSArray*)argu
{
    int lowerOctave = ((NSNumber*)(argu[0])).intValue;;
    if(((NSNumber*)(argu[1])).intValue == 1)
        self.nextPlayersArray = [self loadTwoOctaveWithLowerOctave:lowerOctave instrumentName:self.instrumentNameMap[self.instrumentNo]];
    else
        self.lastPlayersArray = [self loadTwoOctaveWithLowerOctave:lowerOctave instrumentName:self.instrumentNameMap[self.instrumentNo]];
}

-(NSMutableArray*) loadTwoOctaveWithLowerOctave:(int)lowerOctave instrumentName:(NSString*)instrumentName
{
    NSMutableArray* playersArray = [[NSMutableArray alloc] init];
    for(int i = lowerOctave; i < lowerOctave+2; i++)
    {
        for(NSString* noteName in self.noteArray)
        {
            NSString* whiteKeySoundFileName = [NSString stringWithFormat:@"%@_%@%d", instrumentName, noteName, i];
            NSString* path = [[NSBundle mainBundle] pathForResource:whiteKeySoundFileName ofType:@"mp3"];
            AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                                     [NSURL fileURLWithPath:path] error:NULL];
            
            [player prepareToPlay];
            [playersArray addObject:player];
        }
        for(NSString* halfStep in self.halfStepArray)
        {
            NSString* blackkeySoundFileName = [NSString stringWithFormat:@"%@_%@%d#", instrumentName, halfStep, i];
            NSString* path = [[NSBundle mainBundle] pathForResource:blackkeySoundFileName ofType:@"mp3"];
            AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                                     [NSURL fileURLWithPath:path] error:NULL];
            
            [player prepareToPlay];
            [playersArray addObject:player];
        }
    }
    return playersArray;
}

#pragma mark - User Interface

-(void) screenCheck
{
    if(IPhone4)
    {
        self.keyboard_top_padding = 40;
        self.keyboard_button_padding = 1;
        self.keyboard_left_padding = 2;
        self.keyboard_right_padding = 4;
        self.keyboard_gap_between_keys = 4;
    }
    else if(IPhone5)
    {
        self.keyboard_top_padding = 40;
        self.keyboard_button_padding = 1;
        self.keyboard_left_padding = 3;
        self.keyboard_right_padding = 5;
        self.keyboard_gap_between_keys = 6;
    }
    else if(IPhone6)
    {
        self.keyboard_top_padding = 47;
        self.keyboard_button_padding = 2;
        self.keyboard_left_padding = 3;
        self.keyboard_right_padding = 5;
        self.keyboard_gap_between_keys = 6;
        self.blackKeySize = CGSizeMake(28, 65);
    }
    else if(IPhone6sPlus)
    {
        self.keyboard_top_padding = 52;
        self.keyboard_button_padding = 2;
        self.keyboard_left_padding = 3;
        self.keyboard_right_padding = 5;
        self.keyboard_gap_between_keys = 6;
    }
}

-(void) UIbuild
{
    [self screenCheck];
    
    self.instrumentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"piano_outline.png"]];
    self.instrumentImageView.frame = CGRectMake(CGRectGetWidth(self.view.frame)*0.05, self.navigationController.navigationBar.frame.size.height+self.screenHeight*0.1, CGRectGetWidth(self.view.frame)*0.135, self.screenHeight*0.56);
    [self.view addSubview:self.instrumentImageView];
    
    UIButton* instrumentButton = [[UIButton alloc] init];
    instrumentButton.adjustsImageWhenHighlighted = NO;
    [instrumentButton setFrame:CGRectMake(CGRectGetMinX(self.instrumentImageView.frame), CGRectGetMinY(self.instrumentImageView.frame), CGRectGetWidth(self.instrumentImageView.frame), CGRectGetHeight(self.instrumentImageView.frame)/2)];
    [instrumentButton addTarget:self action:@selector(instrumentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:instrumentButton];
  
    UIImageView* blueToothIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueToothIcon.png"]];
    [blueToothIcon sizeToFit];
    blueToothIcon.frame = CGRectMake(CGRectGetWidth(self.view.frame)*0.8, self.navigationController.navigationBar.frame.size.height+5, CGRectGetWidth(blueToothIcon.frame)*0.6, CGRectGetHeight(blueToothIcon.frame)*0.6);
    [self.view addSubview:blueToothIcon];
    
    self.blueToothStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(blueToothIcon.frame), CGRectGetMinY(blueToothIcon.frame), CGRectGetMaxX(self.view.frame)-CGRectGetMaxX(blueToothIcon.frame)-5, CGRectGetHeight(blueToothIcon.frame))];
    self.blueToothStatusLabel.text = @"Unconnected";
    self.blueToothStatusLabel.numberOfLines = 1;
    self.blueToothStatusLabel.adjustsFontSizeToFitWidth = YES;
    self.blueToothStatusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.blueToothStatusLabel];
    
    self.wholeKeyboardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyboard.png"]];
    [self.wholeKeyboardImageView.layer setBorderWidth:2];
    self.wholeKeyboardImageView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height+self.screenHeight/8, self.view.frame.size.width, self.screenHeight/4);
    
    
    //MistView
    self.mistView = [[UIView alloc] initWithFrame:self.view.frame];
    self.mistView.alpha = 0.8;
    self.mistView.backgroundColor = [UIColor grayColor];
    UITapGestureRecognizer* tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mistViewTapped)];
    tapGest.numberOfTapsRequired = 1;
    tapGest.numberOfTouchesRequired = 1;
    [self.mistView addGestureRecognizer:tapGest];
    
    //Keyboard backgorund
    UIImageView* keyboardBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"part_of_keyboard.png"]];
    keyboardBgImageView.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame)-self.screenHeight/2, self.view.frame.size.width, self.screenHeight/2);
    [self.view addSubview:keyboardBgImageView];
    
    CGFloat oneKeyWidth = (keyboardBgImageView.frame.size.width - self.keyboard_right_padding -self.keyboard_gap_between_keys*13 - self.keyboard_left_padding)/14;
    
    CGFloat keyX = self.keyboard_left_padding;
    CGFloat keyY = CGRectGetMinY(keyboardBgImageView.frame)+self.keyboard_top_padding;
    CGFloat keyHeight = keyboardBgImageView.frame.size.height - self.keyboard_top_padding - self.keyboard_button_padding;
    
    
    //White Keys
    for(int i=0; i<14; i++)
    {
        NSString* imageName = [NSString stringWithFormat:@"wkey%d.png", i+1];
        NSString* highlightImageName = [NSString stringWithFormat:@"wkey%d_highlight.png", i+1];
        UIImageView* whiteKeyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName] highlightedImage:[UIImage imageNamed:highlightImageName]];
        whiteKeyImageView.frame = CGRectMake(keyX, keyY, oneKeyWidth, keyHeight);

        whiteKeyImageView.tag = i;
        
        [whiteKeyImageView setUserInteractionEnabled:YES];
        
        UILongPressGestureRecognizer *tapGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                              initWithTarget:self
                                                              action:@selector(keyTapped:)];
        [tapGestureRecognizer setMinimumPressDuration:0.01];
        
        [whiteKeyImageView addGestureRecognizer:tapGestureRecognizer];
       // whiteKeyImageView.backgroundColor = [UIColor redColor];
        [self.view addSubview:whiteKeyImageView];
        
        UILabel* noLabel = [[UILabel alloc] initWithFrame:CGRectMake(keyX, CGRectGetMaxY(whiteKeyImageView.frame)-keyHeight*0.2, oneKeyWidth, keyHeight*0.2)];
        
        noLabel.textAlignment = NSTextAlignmentCenter;
        noLabel.text = [NSString stringWithFormat:@"%d", i%7+1];
        [self.view addSubview:noLabel];
        
        keyX += self.keyboard_gap_between_keys + oneKeyWidth;
        
    }

    //Black keys
    CGFloat offset1 = 30;
    CGFloat offset2 = 20;
    keyX = self.keyboard_left_padding;
    for(int i=0; i<10; i++)
    {
        UIImageView* blackKeyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkey.png"] highlightedImage:[UIImage imageNamed:@"bkey_highlight.png"]];
        blackKeyImageView.tag = 14+i;
        
        [blackKeyImageView setUserInteractionEnabled:YES];
        UILongPressGestureRecognizer *tapGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                              initWithTarget:self
                                                              action:@selector(keyTapped:)];
        [tapGestureRecognizer setMinimumPressDuration:0.01];
        
        [blackKeyImageView addGestureRecognizer:tapGestureRecognizer];
        
        switch (i)
        {
            case 0:
                keyX += offset1;
                break;
            case 2: case 5: case 7:
                keyX += offset1*2 + self.keyboard_gap_between_keys;
                break;
            default:
                keyX += offset2;
                break;
        }
        
        blackKeyImageView.frame = CGRectMake(keyX, keyY, self.blackKeySize.width, self.blackKeySize.height);
        keyX += self.blackKeySize.width;
        [self.view addSubview:blackKeyImageView];
    }
    
    UIImageView* lArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftArrow.png"]];
    lArrowImageView.tag = 0;
    [lArrowImageView setUserInteractionEnabled:YES];
    lArrowImageView.frame = CGRectMake(20, CGRectGetMinY(keyboardBgImageView.frame)+15, 50, 20);
    UILongPressGestureRecognizer *tapGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(arrowImageViewClicked:)];
    [tapGestureRecognizer setMinimumPressDuration:0.01];
    [lArrowImageView addGestureRecognizer:tapGestureRecognizer];
    [self.view addSubview:lArrowImageView];
    
    UIImageView* rArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightArrow.png"]];
    rArrowImageView.tag = 1;
    [rArrowImageView setUserInteractionEnabled:YES];
    rArrowImageView.frame = CGRectMake(CGRectGetMaxX(self.view.frame)-70, CGRectGetMinY(keyboardBgImageView.frame)+15, 50, 20);
    tapGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(arrowImageViewClicked:)];
    [tapGestureRecognizer setMinimumPressDuration:0.01];
    [rArrowImageView addGestureRecognizer:tapGestureRecognizer];
    [self.view addSubview:rArrowImageView];

    [self drawInstrumentMenu];
    [self drawTablatureScrollView];
}

-(void) drawTablatureScrollView
{
    self.tablatureScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(CGRectGetWidth(self.view.frame)*0.23, self.navigationController.navigationBar.frame.size.height+5, CGRectGetWidth(self.view.frame)*0.55, self.screenHeight/2-10)];
    [self.tablatureScrollView.layer setBorderWidth:2];
    [self.view addSubview:self.tablatureScrollView];
 
    UIImageView* tablature = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablature.jpg"]];
    [tablature sizeToFit];
    float scale = CGRectGetWidth(self.tablatureScrollView.frame)/tablature.frame.size.width;
    tablature.frame = CGRectMake(0, 0, CGRectGetWidth(self.tablatureScrollView.frame), tablature.frame.size.height*scale);
    [self.tablatureScrollView addSubview:tablature];
    
    self.tablatureScrollView.contentSize = tablature.frame.size;
}

-(void) drawInstrumentMenu
{
    self.instrumentMenuScrollView = [[UIScrollView alloc] init];
    self.instrumentMenuScrollView.frame = CGRectMake(7, CGRectGetHeight(self.view.frame)*0.33, self.view.frame.size.width-14, self.view.frame.size.height*0.53);
    [self.instrumentMenuScrollView.layer setBorderWidth:2];
    self.instrumentMenuScrollView.backgroundColor = [UIColor whiteColor];
    
    UIButton* instrumentButton = [[UIButton alloc] init];
    [instrumentButton setImage:[UIImage imageNamed:@"piano_outline.png"] forState:UIControlStateNormal];
    instrumentButton.tag = 1;
    instrumentButton.adjustsImageWhenHighlighted = NO;
    [instrumentButton setFrame:CGRectMake(CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.41, CGRectGetHeight(self.instrumentMenuScrollView.frame)*0.2, CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.18, self.instrumentMenuScrollView.frame.size.height*1.2)];
    [instrumentButton addTarget:self action:@selector(changeInstrumentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.instrumentMenuScrollView addSubview:instrumentButton];
    
    instrumentButton = [[UIButton alloc] init];
    [instrumentButton setImage:[UIImage imageNamed:@"guitar_outline.png"] forState:UIControlStateNormal];
    instrumentButton.tag = 0;
    instrumentButton.adjustsImageWhenHighlighted = NO;
    [instrumentButton setFrame:CGRectMake(CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.13, CGRectGetHeight(self.instrumentMenuScrollView.frame)*0.2, CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.18, self.instrumentMenuScrollView.frame.size.height*1.2)];
    [instrumentButton addTarget:self action:@selector(changeInstrumentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.instrumentMenuScrollView addSubview:instrumentButton];
    
    instrumentButton = [[UIButton alloc] init];
    [instrumentButton setImage:[UIImage imageNamed:@"string_outline.png"] forState:UIControlStateNormal];
    instrumentButton.tag = 2;
    instrumentButton.adjustsImageWhenHighlighted = NO;
    [instrumentButton setFrame:CGRectMake(CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.69, CGRectGetHeight(self.instrumentMenuScrollView.frame)*0.2, CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.18, self.instrumentMenuScrollView.frame.size.height*1.2)];
    [instrumentButton addTarget:self action:@selector(changeInstrumentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.instrumentMenuScrollView addSubview:instrumentButton];
}

#pragma mark - Actions

-(void)mistViewTapped
{
    [self.mistView removeFromSuperview];
    [self.instrumentMenuScrollView removeFromSuperview];
}

-(void)changeInstrumentButtonClicked:(UIButton*) sender
{
    while (self.preloadInstrumentFinishedOctaveNo != self.lowerOctaveNo)
    {
        NSLog(@"x");
    }
    [self.instrumentPlayersDic setObject:self.playersArray forKey:self.instrumentNameMap[self.instrumentNo]];
    
    self.instrumentNo = (int)sender.tag;
    NSString* pictureName = [NSString stringWithFormat:@"%@_outline.png", self.instrumentNameMap[self.instrumentNo]];
    [self.instrumentImageView setImage:[UIImage imageNamed:pictureName]];
   // [self AVAudioPlayerInit];
    
    self.playersArray = [self.instrumentPlayersDic objectForKey:self.instrumentNameMap[self.instrumentNo]];
    
    if(self.lowerOctaveNo != 1)
    {
        NSArray* argu = [NSArray arrayWithObjects:[NSNumber numberWithInt:self.lowerOctaveNo-1], [NSNumber numberWithInt:0], nil];
        NSThread *newThread = [[NSThread alloc] initWithTarget:self selector:@selector(preLoadPlayers:) object:argu];
        [newThread start];
    }
    
    if(self.lowerOctaveNo != 6)
    {
        NSArray* argu = [NSArray arrayWithObjects:[NSNumber numberWithInt:self.lowerOctaveNo+1], [NSNumber numberWithInt:1], nil];
        NSThread *newThread = [[NSThread alloc] initWithTarget:self selector:@selector(preLoadPlayers:) object:argu];
        [newThread start];
    }
    
    [self.mistView removeFromSuperview];
    [self.instrumentMenuScrollView removeFromSuperview];
}

-(void)instrumentButtonClicked
{
    [self.view addSubview:self.mistView];
    [self.view addSubview:self.instrumentMenuScrollView];
}

- (void) arrowImageViewClicked:(UITapGestureRecognizer*) sender
{
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        [self.view addSubview:self.mistView];
        [self.view addSubview:self.wholeKeyboardImageView];
        UIImageView* imageView = (UIImageView*)sender.view;
        if(imageView.tag == 0)
        {
            if(self.lowerOctaveNo > 1)
            {
                self.lowerOctaveNo--;
                [self avaudioPlayerGoUpper:NO];
                self.preloadInstrumentFinishedOctaveNo = 0;
                NSThread* newThread = [[NSThread alloc] initWithTarget:self selector:@selector(preloadOtherInstrument:) object:[NSNumber numberWithInt:self.lowerOctaveNo]];
                [newThread start];
            }
        }
        else
        {
            if(self.lowerOctaveNo < 6)
            {
                self.lowerOctaveNo++;
                [self avaudioPlayerGoUpper:YES];
                self.preloadInstrumentFinishedOctaveNo = 0;
                NSThread* newThread = [[NSThread alloc] initWithTarget:self selector:@selector(preloadOtherInstrument:) object:[NSNumber numberWithInt:self.lowerOctaveNo]];
                [newThread start];
            }
        }
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
        int i=0;
        while(i < 1000000)
            i++;
        [self.mistView removeFromSuperview];
        [self.wholeKeyboardImageView removeFromSuperview];
    }
}

- (void) keyTapped:(UILongPressGestureRecognizer*) recognizer
{
    UIImageView* imageView = (UIImageView*)recognizer.view;
    int keyNo = (int)imageView.tag;
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        imageView.highlighted = YES;
        [self.playersArray[keyNo] play];
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        imageView.highlighted = NO;
        int i=0;
        while (i<10000000)
            i++;

        [self.playersArray[keyNo] stop];
        ((AVAudioPlayer*)self.playersArray[keyNo]).currentTime = 0;
        [self.playersArray[keyNo] prepareToPlay];
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
