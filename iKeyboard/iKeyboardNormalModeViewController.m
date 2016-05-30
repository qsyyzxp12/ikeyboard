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
#define viewW CGRectGetWidth(self.view.frame)
#define viewH CGRectGetHeight(self.view.frame)

@interface iKeyboardNormalModeViewController ()

@end

@implementation iKeyboardNormalModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.showingSettingPage = NO;
    self.showingPlusPage = NO;
    self.keyBeingTappedFrameArray = [[NSMutableArray alloc] initWithObjects:NSStringFromCGRect(CGRectZero), NSStringFromCGRect(CGRectZero), NSStringFromCGRect(CGRectZero), nil];
    self.keyBeingTappedIndexArray = malloc(sizeof(int)*4);
    bzero(self.keyBeingTappedIndexArray, sizeof(int)*4);
    
    self.lowerOctaveNo = 3;
    self.sheetSelectedNo = 1;
    self.sheetNo = 1;
    self.instrumentNo = 1;
    self.instrumentSelectedNo = 1;
    self.sheetNameMap = [[NSMutableArray alloc] initWithObjects:@"Moon Sonata", @"CANON in D", @"Fur Elise", nil];
    self.noteNameArray = [[NSArray alloc] initWithObjects:@"C", @"D", @"E", @"F", @"G", @"A", @"B", nil];
    self.halfStepArray = [[NSArray alloc] initWithObjects:@"C", @"D", @"F", @"G", @"A", nil];
    self.instrumentNameMap = [[NSArray alloc] initWithObjects:@"bass", @"piano", @"guitar", @"Saxophone", nil];
    self.screenHeight = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height;
    
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
        self.keyboard_left_padding = 40;
        self.keyboard_padding = 1;
        self.blackKeySize = CGSizeMake(24, 56);
        self.blackKeyOffsetVector = CGVectorMake(35, 22);
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
    
    UIButton* settingButton = [[UIButton alloc] initWithFrame:CGRectMake(viewW*0.011, viewH*0.01, viewW*0.03, viewH*0.05)];
    [settingButton setImage:[UIImage imageNamed:@"Menu_button3.png"] forState:UIControlStateNormal];
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
  //  self.littleKeyboImageView.alpha = 0.5;
    [self.view addSubview:self.littleKeyboImageView];
   
    self.leftMistBar = [[UIView alloc] initWithFrame:CGRectMake(viewW*0.02, viewH*0.6, viewW*0.295, viewH*0.1)];
 //   self.leftMistBar.alpha = 0.5;
    self.leftMistBar.tag = 0;
 //   self.leftMistBar.backgroundColor = [UIColor blueColor];
    UITapGestureRecognizer* tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(arrowImageViewClicked:)];
    tapGest.numberOfTapsRequired = 1;
    tapGest.numberOfTouchesRequired = 1;
    [self.leftMistBar addGestureRecognizer:tapGest];
    [self.view addSubview:self.leftMistBar];
    
    self.rightMistBar = [[UIView alloc] initWithFrame:CGRectMake(viewW*0.573, viewH*0.6, viewW*0.402, viewH*0.1)];
  //  self.rightMistBar.alpha = 0.5;
    self.rightMistBar.tag = 1;
  //  self.rightMistBar.backgroundColor = [UIColor blueColor];
    tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(arrowImageViewClicked:)];
    tapGest.numberOfTapsRequired = 1;
    tapGest.numberOfTouchesRequired = 1;
    [self.rightMistBar addGestureRecognizer:tapGest];
    [self.view addSubview:self.rightMistBar];

    CGFloat oneKeyWidth = (viewW - self.keyboard_left_padding - self.keyboard_right_padding - self.keyboard_padding*13)/14;
    CGFloat keyX = self.keyboard_left_padding;
    CGFloat keyY = viewH*0.72;
    CGFloat keyHeight = viewH*0.28;
    
    NSMutableArray* keyViewArray = [[NSMutableArray alloc] init];
    
    //White Keys
    for(int i=0; i<14; i++)
    {
        UIView* whiteKeyView = [[UIImageView alloc] init];
        whiteKeyView.frame = CGRectMake(keyX, keyY, oneKeyWidth, keyHeight);
        [self.view addSubview:whiteKeyView];
        keyX += self.keyboard_padding + oneKeyWidth;
        [keyViewArray addObject:whiteKeyView];
    }

    //Black keys
    keyX = self.keyboard_left_padding;
    for(int i=0; i<10; i++)
    {
        UIView* blackKeyView = [[UIView alloc] init];
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
    self.spinner.backgroundColor = [UIColor whiteColor];
    [self.spinner startAnimating];
   
    self.mistView = [[UIView alloc] initWithFrame:self.view.frame];
    self.mistView.backgroundColor = [UIColor blackColor];
    self.mistView.alpha = 0.5;
    
    UIView* fingerSensorView = [[UIView alloc] initWithFrame:CGRectMake(self.keyboard_left_padding, keyY, viewW-self.keyboard_left_padding-self.keyboard_right_padding, viewH*0.28)];
    fingerSensorView.backgroundColor = [UIColor clearColor];
    
    self.tapGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(tap:)];
    self.tapGestureRecognizer.delegate = self;
    [self.tapGestureRecognizer setMinimumPressDuration:0.01];
    [fingerSensorView addGestureRecognizer:self.tapGestureRecognizer];
    
    self.tapGestureRecognizer2 = [[UILongPressGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(tap:)];
    self.tapGestureRecognizer2.delegate = self;
    [self.tapGestureRecognizer2 setMinimumPressDuration:0.01];
    [fingerSensorView addGestureRecognizer:self.tapGestureRecognizer2];
    
    self.tapGestureRecognizer3 = [[UILongPressGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(tap:)];
    self.tapGestureRecognizer3.delegate = self;
    [self.tapGestureRecognizer3 setMinimumPressDuration:0.01];
    [fingerSensorView addGestureRecognizer:self.tapGestureRecognizer3];
    
    [self.view addSubview:fingerSensorView];
    
    [self drawSettingPageView];
}

-(void) drawSettingPageView
{
    self.settingPageView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImageView* BGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background1.png"]];
    BGImageView.frame = self.view.frame;
    [self.settingPageView addSubview:BGImageView];
    
    UIButton* leaveSettingPageButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.015, CGRectGetHeight(self.view.frame)*0.008, CGRectGetWidth(self.view.frame)*0.031, CGRectGetHeight(self.view.frame)*0.052)];
    [leaveSettingPageButton addTarget:self action:@selector(settingButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.settingPageView addSubview:leaveSettingPageButton];
    
    //draw instructment menu
    self.instrumentMenuScrollView = [[UIScrollView alloc] init];
    self.instrumentMenuScrollView.frame = CGRectMake(viewW*0.084, viewH*0.58, viewW*0.832, viewH*0.243);
    
    for(int i=0; i<[self.instrumentNameMap count]; i++)
    {
        UIButton* instrumentButton = [[UIButton alloc] init];
        NSString* imageName = [NSString stringWithFormat:@"%@1.png", self.instrumentNameMap[i]];
        [instrumentButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        instrumentButton.tag = i;
        instrumentButton.adjustsImageWhenHighlighted = NO;
        [instrumentButton setFrame:CGRectMake(CGRectGetWidth(self.instrumentMenuScrollView.frame)*(0.37+i*0.31), CGRectGetHeight(self.instrumentMenuScrollView.frame)*0.2, CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.26, self.instrumentMenuScrollView.frame.size.height*0.8)];
        [self.instrumentMenuScrollView addSubview:instrumentButton];
    }
    [self.instrumentMenuScrollView setUserInteractionEnabled:NO];
    self.instrumentMenuScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.instrumentMenuScrollView.frame)*(0.74+0.31*[self.instrumentNameMap count]-0.05), CGRectGetHeight(self.instrumentMenuScrollView.frame));
    
    self.instrumentMenuScrollView.contentOffset = CGPointMake(self.instrumentMenuScrollView.contentOffset.x+CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.31, 0);
    [self.settingPageView addSubview:self.instrumentMenuScrollView];
    
    UIButton* lastInstrumentButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.instrumentMenuScrollView.frame), CGRectGetMinY(self.instrumentMenuScrollView.frame), CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.033, CGRectGetHeight(self.instrumentMenuScrollView.frame))];
    lastInstrumentButton.tag = 0;
    [lastInstrumentButton addTarget:self action:@selector(instrumentNextOrLastButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingPageView addSubview:lastInstrumentButton];
    
    UIButton* nextInstrumentButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.instrumentMenuScrollView.frame)+CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.967, CGRectGetMinY(self.instrumentMenuScrollView.frame), CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.033, CGRectGetHeight(self.instrumentMenuScrollView.frame))];
    nextInstrumentButton.tag = 1;
    [nextInstrumentButton addTarget:self action:@selector(instrumentNextOrLastButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingPageView addSubview:nextInstrumentButton];
    
    
    //draw tablature menu
    
    self.tablatureMenuScrollView = [[UIScrollView alloc] init];
    self.tablatureMenuScrollView.frame = CGRectMake(viewW*0.084, viewH*0.19, viewW*0.832, viewH*0.243);
    
    for(int i=0; i<[self.sheetNameMap count]; i++)
    {
        UIImageView* icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sheets1.png"]];
        icon.tag = i;
        int x = i - (int)[self.sheetNameMap count]/2;
        [icon setFrame:CGRectMake(CGRectGetWidth(self.tablatureMenuScrollView.frame)*(0.7+x*0.3), CGRectGetHeight(self.tablatureMenuScrollView.frame)*0.1, CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.2, self.tablatureMenuScrollView.frame.size.height*0.9)];
        [self.tablatureMenuScrollView addSubview:icon];
        
        UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(icon.frame), CGRectGetMaxY(icon.frame)-CGRectGetHeight(icon.frame)*0.3, CGRectGetWidth(icon.frame), CGRectGetHeight(icon.frame)*0.2)];
        nameLabel.text = [self.sheetNameMap objectAtIndex:i];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.numberOfLines = 2;
        nameLabel.adjustsFontSizeToFitWidth = YES;
        [self.tablatureMenuScrollView addSubview:nameLabel];
    }
    [self.tablatureMenuScrollView setUserInteractionEnabled:NO];
    self.tablatureMenuScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.tablatureMenuScrollView.frame)*(1.4+0.3*[self.instrumentNameMap count]-0.1), CGRectGetHeight(self.tablatureMenuScrollView.frame));
    self.tablatureMenuScrollView.contentOffset = CGPointMake(self.tablatureMenuScrollView.contentOffset.x+CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.3, 0);
    [self.settingPageView addSubview:self.tablatureMenuScrollView];
    
    UIButton* lastSheetButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.tablatureMenuScrollView.frame), CGRectGetMinY(self.tablatureMenuScrollView.frame), CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.033, CGRectGetHeight(self.tablatureMenuScrollView.frame))];
    lastSheetButton.tag = 0;
    [lastSheetButton addTarget:self action:@selector(sheetNextOrLastButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingPageView addSubview:lastSheetButton];
    
    UIButton* nextSheetButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.tablatureMenuScrollView.frame)+CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.967, CGRectGetMinY(self.tablatureMenuScrollView.frame), CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.033, CGRectGetHeight(self.tablatureMenuScrollView.frame))];
    nextSheetButton.tag = 1;
    [nextSheetButton addTarget:self action:@selector(sheetNextOrLastButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingPageView addSubview:nextSheetButton];
    
    UIButton* trashCanButton = [[UIButton alloc] initWithFrame:CGRectMake(viewW*0.79, viewH*0.1, 30, 30)];
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
}

-(void)drawPlusPage
{
    self.plusPageView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImageView* BGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Add_Sheet3.png"]];
    BGImageView.frame = self.plusPageView.frame;
    [self.plusPageView addSubview:BGImageView];
    
    UIButton* plusIconButton = [[UIButton alloc] initWithFrame:CGRectMake(viewW*0.855, viewH*0.127, viewW*0.03, viewH*0.05)];
    [plusIconButton addTarget:self action:@selector(plusIconClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.plusPageView addSubview:plusIconButton];
    
    UITextField* sheetNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(viewW*0.615, viewH*0.67, viewW*0.231, viewH*0.07)];
    sheetNameTextField.delegate = self;
    sheetNameTextField.textAlignment = NSTextAlignmentCenter;
    sheetNameTextField.textColor = [UIColor whiteColor];
    [self.plusPageView addSubview:sheetNameTextField];
    
    UIButton* doneButton = [[UIButton alloc] initWithFrame: CGRectMake(viewW*0.68, viewH*0.8, viewW*0.1, viewW*0.043)];
    [doneButton addTarget:self action:@selector(doneButtonInPlusPageClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.plusPageView addSubview:doneButton];
}

-(void) drawTablatureScrollView
{
    self.tablatureScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(CGRectGetWidth(self.view.frame)*0.02, self.navigationController.navigationBar.frame.size.height, CGRectGetWidth(self.view.frame)*0.962, CGRectGetHeight(self.view.frame)*0.47)];
    [self.view addSubview:self.tablatureScrollView];
 
    self.tablatureImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CANON in D.jpg"]];
    self.tablatureImageView.backgroundColor = [UIColor whiteColor];
    [self.tablatureImageView sizeToFit];
    float scale = CGRectGetWidth(self.tablatureScrollView.frame)/self.tablatureImageView.frame.size.width;
    self.tablatureImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tablatureScrollView.frame), self.tablatureImageView.frame.size.height*scale);
    [self.tablatureScrollView addSubview:self.tablatureImageView];
    
    self.tablatureScrollView.contentSize = self.tablatureImageView.frame.size;
}

-(void) drawTablatureMenu
{
}

-(void) drawInstrumentMenu
{
}

#pragma mark - Actions

-(void)doneButtonInPlusPageClicked
{
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
    //    [self.view addSubview:self.mistView];
      //  [self.view addSubview:self.spinner];
        self.instrumentNo = self.instrumentSelectedNo;
  //      [NSThread detachNewThreadSelector:@selector(AVAudioPlayerInit) toTarget:self withObject:nil];
    }
    
    [self.settingPageView removeFromSuperview];
    self.showingSettingPage = NO;
}

-(void)plusIconClicked
{
    if(!self.showingPlusPage)
    {
        [self.view addSubview:self.plusPageView];
        self.showingPlusPage = YES;
    }
    else
    {
        [self.plusPageView removeFromSuperview];
        self.showingPlusPage = NO;
    }
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

-(void)instrumentNextOrLastButtonClicked:(UIButton*)sender
{
    if(!sender.tag)
    {
        if(self.instrumentSelectedNo > 0)
        {
            self.instrumentMenuScrollView.contentOffset = CGPointMake(self.instrumentMenuScrollView.contentOffset.x-CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.31, 0);
            self.instrumentSelectedNo--;
        }
    }
    else
    {
        if(self.instrumentSelectedNo < [self.instrumentNameMap count]-1)
        {
            self.instrumentMenuScrollView.contentOffset = CGPointMake(self.instrumentMenuScrollView.contentOffset.x+CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.31, 0);
            self.instrumentSelectedNo++;
        }
    }
}

-(void)settingButtonClicked
{
    if(!self.showingSettingPage)
    {
        [self.view addSubview:self.settingPageView];
        self.showingSettingPage = YES;
    }
    else
    {
        self.tablatureMenuScrollView.contentOffset = CGPointMake(self.tablatureMenuScrollView.contentOffset.x+CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.3*(self.sheetNo-self.sheetSelectedNo), 0);
        self.instrumentMenuScrollView.contentOffset = CGPointMake(self.instrumentMenuScrollView.contentOffset.x+CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.31*(self.instrumentNo-self.instrumentSelectedNo), 0);
        
        
        self.sheetSelectedNo = self.sheetNo;
        self.instrumentSelectedNo = self.instrumentNo;
        
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
      //  NSLog(@"tapped began!");
        for(int i=(int)[self.keyViewArray count]-1; i >= 0; i--)
        {
            CGRect keyRect = ((UIView*)self.keyViewArray[i]).frame;
            if(CGRectContainsPoint(keyRect, point))
            {
                [self.keyBeingTappedFrameArray setObject:NSStringFromCGRect(keyRect) atIndexedSubscript:gestNo];
                self.keyBeingTappedIndexArray[gestNo] = i;
                [self tapBeganOnKey:i];
                break;
            }
        }
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
      //  NSLog(@"tapped end!");
        if(![self.keyBeingTappedFrameArray[gestNo] isEqualToString:NSStringFromCGRect(CGRectZero)])
        {
           // ((UIView*)(self.keyImageViewArray[self.keyBeingTappedIndexArray[gestNo]])).highlighted = NO;
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
              //  ((UIImageView*)(self.keyImageViewArray[self.keyBeingTappedIndexArray[gestNo]])).highlighted = NO;
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
                    [self tapBeganOnKey:i];
                    break;
                }
            }
        }
    }
}

-(void) tapBeganOnKey:(int)index
{
  //  ((UIImageView*)(self.keyViewArray[index])).highlighted = YES;
    [self.view addSubview:self.highlightedKeyImageViewArray[index]];
    
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
        player.volume = 1;
        [player play];
    }
    else
    {
        player.volume = 1;
        player.currentTime = 0;
    }
}

-(void) tapEndedOnKey:(NSNumber*)index
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
    AVAudioPlayer* player = [playersArray objectAtIndex:keyNo];
    int i=0;
    while (i<10000000)
        i++;
    player.volume = 0.1;
    
    i=0;
    while (i<40000000)
        i++;
    
 //   player.volume = 1;
  //  NSLog(@"%f", player.currentTime);
    if(player.currentTime > 0.17)
    {
    //    NSLog(@"%f", player.currentTime);
        [player stop];
        player.currentTime = 0;
        [player prepareToPlay];
    }
}

-(void)mistViewTapped
{
    [self.mistView removeFromSuperview];
}

-(void)tablatureButtonClicked
{
    [self.view addSubview:self.mistView];
    [self.view addSubview:self.tablatureMenuScrollView];
}

-(void)instrumentButtonClicked
{
    [self.view addSubview:self.mistView];
    [self.view addSubview:self.instrumentMenuScrollView];
}

- (void) arrowImageViewClicked:(UITapGestureRecognizer*) sender
{
    UIImageView* senderImageView = (UIImageView*)sender.view;
    if(senderImageView.tag == 0)
    {
        if(self.lowerOctaveNo > 1)
        {
            self.lowerOctaveNo--;
            self.leftMistBar.frame = CGRectMake(CGRectGetMinX(self.leftMistBar.frame), CGRectGetMinY(self.leftMistBar.frame), CGRectGetWidth(self.leftMistBar.frame)-viewW*0.129, CGRectGetHeight(self.leftMistBar.frame));
            self.rightMistBar.frame = CGRectMake(CGRectGetMinX(self.rightMistBar.frame)-viewW*0.129, CGRectGetMinY(self.rightMistBar.frame), CGRectGetWidth(self.rightMistBar.frame)+viewW*0.129, CGRectGetHeight(self.rightMistBar.frame));
            self.littleKeyboImageView.frame = CGRectMake(CGRectGetMinX(self.littleKeyboImageView.frame)-viewW*0.129, CGRectGetMinY(self.littleKeyboImageView.frame), CGRectGetWidth(self.littleKeyboImageView.frame), CGRectGetHeight(self.littleKeyboImageView.frame));
        }
    }
    else
    {
        if(self.lowerOctaveNo < 6)
        {
            self.lowerOctaveNo++;
            self.leftMistBar.frame = CGRectMake(CGRectGetMinX(self.leftMistBar.frame), CGRectGetMinY(self.leftMistBar.frame), CGRectGetWidth(self.leftMistBar.frame)+viewW*0.129, CGRectGetHeight(self.leftMistBar.frame));
            
            self.rightMistBar.frame = CGRectMake(CGRectGetMinX(self.rightMistBar.frame)+viewW*0.129, CGRectGetMinY(self.rightMistBar.frame), CGRectGetWidth(self.rightMistBar.frame)-viewW*0.129, CGRectGetHeight(self.rightMistBar.frame));
            
            self.littleKeyboImageView.frame = CGRectMake(CGRectGetMinX(self.littleKeyboImageView.frame)+viewW*0.129, CGRectGetMinY(self.littleKeyboImageView.frame), CGRectGetWidth(self.littleKeyboImageView.frame), CGRectGetHeight(self.littleKeyboImageView.frame));
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    CGPoint firstPoint = [gestureRecognizer locationInView:self.view];
    CGPoint secPoint = [otherGestureRecognizer locationInView:self.view];
    
    if(!CGPointEqualToPoint(firstPoint, secPoint))
        return  YES;
    
    return NO;
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
