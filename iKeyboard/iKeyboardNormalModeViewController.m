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
    
    self.noteNameArray = [[NSArray alloc] initWithObjects:@"C", @"D", @"E", @"F", @"G", @"A", @"B", nil];
    self.halfStepArray = [[NSArray alloc] initWithObjects:@"C", @"D", @"F", @"G", @"A", nil];
    self.instrumentNameMap = [[NSArray alloc] initWithObjects:@"guitar", @"piano", @"string", nil];
    self.tablatureFileNameArray = [[NSArray alloc] initWithObjects:@"up.jpg", @"letItGo.jpg", @"canonInDMajor.jpg", nil];
    self.screenHeight = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height;

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
        self.keyboard_top_padding = 40;
        self.keyboard_padding = 1;
        self.blackKeySize = CGSizeMake(20, 56);
        self.blackKeyOffsetVector = CGVectorMake(23, 15);
    }
    else if(IPhone5)
    {
        self.keyboard_top_padding = 40;
        self.keyboard_padding = 1;
        self.blackKeySize = CGSizeMake(24, 56);
        self.blackKeyOffsetVector = CGVectorMake(27, 18);
    }
    else if(IPhone6)
    {
        self.keyboard_top_padding = 47;
        self.keyboard_padding = 2;
        self.blackKeySize = CGSizeMake(28, 69);
        self.blackKeyOffsetVector = CGVectorMake(32, 20);
    }
    else if(IPhone6sPlus)
    {
        self.keyboard_top_padding = 52;
        self.keyboard_padding = 2;
        self.blackKeySize = CGSizeMake(31, 75);
        self.blackKeyOffsetVector = CGVectorMake(36, 21);
    }
}

-(void) UIbuild
{
    [self screenCheck];
    
    self.instrumentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"piano_outline.png"]];
    self.instrumentImageView.frame = CGRectMake(CGRectGetWidth(self.view.frame)*0.025, self.navigationController.navigationBar.frame.size.height+self.screenHeight*0.23, CGRectGetWidth(self.view.frame)*0.07, self.screenHeight*0.28);
    [self.view addSubview:self.instrumentImageView];
    
    UIButton* instrumentButton = [[UIButton alloc] init];
    instrumentButton.adjustsImageWhenHighlighted = NO;
    [instrumentButton setFrame:CGRectMake(CGRectGetMinX(self.instrumentImageView.frame), CGRectGetMinY(self.instrumentImageView.frame), CGRectGetWidth(self.instrumentImageView.frame), CGRectGetHeight(self.instrumentImageView.frame)/2)];
    [instrumentButton addTarget:self action:@selector(instrumentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:instrumentButton];
  
    UIButton* tablatureButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(instrumentButton.frame), CGRectGetMaxY(self.navigationController.navigationBar.frame)+ 15, CGRectGetWidth(instrumentButton.frame), CGRectGetWidth(instrumentButton.frame))];
    [tablatureButton setImage:[UIImage imageNamed:@"book.png"] forState:UIControlStateNormal];
    [tablatureButton addTarget:self action:@selector(tablatureButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tablatureButton];
    
    
    UIImageView* blueToothIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueToothIcon.png"]];
    blueToothIcon.frame = CGRectMake(CGRectGetWidth(self.view.frame)*0.93, CGRectGetMinY(tablatureButton.frame), CGRectGetWidth(self.view.frame)*0.05, CGRectGetWidth(self.view.frame)*0.05);
    [self.view addSubview:blueToothIcon];
 
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
    UIImageView* keyboardBgImageView = [[UIImageView alloc] init];
    keyboardBgImageView.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame)-self.screenHeight/2, self.view.frame.size.width, self.screenHeight/2);
    [self.view addSubview:keyboardBgImageView];
    
    CGFloat oneKeyWidth = (keyboardBgImageView.frame.size.width - self.keyboard_padding*15)/14;
    
    CGFloat keyX = self.keyboard_padding;
    CGFloat keyY = CGRectGetMinY(keyboardBgImageView.frame)+self.keyboard_top_padding;
    CGFloat keyHeight = keyboardBgImageView.frame.size.height - self.keyboard_padding - self.keyboard_top_padding;
    
    
    //White Keys
    for(int i=0; i<14; i++)
    {
        NSString* imageName = [NSString stringWithFormat:@"wkey.png"];
        NSString* highlightImageName = [NSString stringWithFormat:@"key_highlight.png"];
        UIImageView* whiteKeyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName] highlightedImage:[UIImage imageNamed:highlightImageName]];
        whiteKeyImageView.frame = CGRectMake(keyX, keyY, oneKeyWidth, keyHeight);
        
        if(i < 7)
            whiteKeyImageView.tag = i+1;
        else
            whiteKeyImageView.tag = (i%7+1)*100;
        
        [whiteKeyImageView setUserInteractionEnabled:YES];
        
        UILongPressGestureRecognizer *tapGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                              initWithTarget:self
                                                              action:@selector(keyTapped:)];
        [tapGestureRecognizer setMinimumPressDuration:0.01];
        [whiteKeyImageView.layer setBorderWidth:2];
        
        [whiteKeyImageView addGestureRecognizer:tapGestureRecognizer];
       // whiteKeyImageView.backgroundColor = [UIColor redColor];
        [self.view addSubview:whiteKeyImageView];
        
        UILabel* noLabel = [[UILabel alloc] initWithFrame:CGRectMake(keyX, CGRectGetMaxY(whiteKeyImageView.frame)-keyHeight*0.2, oneKeyWidth, keyHeight*0.2)];
        
        noLabel.textAlignment = NSTextAlignmentCenter;
        noLabel.text = [NSString stringWithFormat:@"%d", i%7+1];
        [self.view addSubview:noLabel];
        
        keyX += self.keyboard_padding + oneKeyWidth;
        
    }

    //Black keys
    keyX = self.keyboard_padding;
    for(int i=0; i<10; i++)
    {
        UIImageView* blackKeyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkey.png"] highlightedImage:[UIImage imageNamed:@"key_highlight.png"]];
        //UIImageView* blackKeyImageView = [[UIImageView alloc] init];
        //blackKeyImageView.backgroundColor = [UIColor redColor];
        if(i < 5)
            blackKeyImageView.tag = 8+i;
        else
            blackKeyImageView.tag = 800 + (i%5)*100;
        
        
        [blackKeyImageView setUserInteractionEnabled:YES];
        UILongPressGestureRecognizer *tapGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                              initWithTarget:self
                                                              action:@selector(keyTapped:)];
        [tapGestureRecognizer setMinimumPressDuration:0.01];
        
        [blackKeyImageView addGestureRecognizer:tapGestureRecognizer];
        
        switch (i)
        {
            case 0:
                keyX += self.blackKeyOffsetVector.dx;
                break;
            case 2: case 5: case 7:
                keyX += self.blackKeyOffsetVector.dx*2 + self.keyboard_padding;
                break;
            default:
                keyX += self.blackKeyOffsetVector.dy;
                break;
        }
        
        blackKeyImageView.frame = CGRectMake(keyX, keyY, self.blackKeySize.width, self.blackKeySize.height);
        keyX += self.blackKeySize.width;
        [self.view addSubview:blackKeyImageView];
    }
    
    UIImageView* keyboardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyboard.png"]];
    keyboardImageView.frame = CGRectMake(0, CGRectGetMinY(keyboardBgImageView.frame), CGRectGetWidth(self.view.frame), self.keyboard_top_padding*0.8);
    [keyboardImageView.layer setBorderWidth:1];
    [self.view addSubview:keyboardImageView];
    
    UIImageView* grayBarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray.png"]];
    grayBarImageView.frame = CGRectMake(0, CGRectGetMaxY(keyboardImageView.frame), CGRectGetWidth(self.view.frame), self.keyboard_top_padding*0.2+2);
    [grayBarImageView.layer setBorderWidth:1];
    [self.view addSubview:grayBarImageView];
    
    UIImageView* lightGrayBarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lightGray.png"]];
    lightGrayBarImageView.frame = CGRectMake(0, CGRectGetMinY(keyboardImageView.frame)-self.keyboard_top_padding*0.2, CGRectGetWidth(self.view.frame), self.keyboard_top_padding*0.2);
    [lightGrayBarImageView.layer setBorderWidth:1];
    [self.view addSubview:lightGrayBarImageView];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = CGRectMake(CGRectGetMidX(self.view.frame)-25, CGRectGetMidY(self.view.frame)-25, 50, 50);
    self.spinner.backgroundColor = [UIColor whiteColor];
    [self.spinner startAnimating];
    
    self.leftMistBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(keyboardImageView.frame), 0, CGRectGetHeight(keyboardImageView.frame))];
    self.leftMistBar.alpha = 0.5;
    self.leftMistBar.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.leftMistBar];
    
    self.rightMistBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(keyboardImageView.frame), 0, CGRectGetHeight(keyboardImageView.frame))];
    self.rightMistBar.alpha = 0.5;
    self.rightMistBar.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.rightMistBar];
    [self adjustMistBar];    

    UIButton* octaveDownButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(keyboardImageView.frame), self.view.frame.size.width/2, CGRectGetHeight(keyboardImageView.frame))];
    octaveDownButton.tag = 0;
    [octaveDownButton addTarget:self action:@selector(arrowImageViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    octaveDownButton.adjustsImageWhenHighlighted = NO;
    [self.view addSubview:octaveDownButton];

    UIButton* octaveUpButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, CGRectGetMinY(keyboardImageView.frame), self.view.frame.size.width/2, CGRectGetHeight(keyboardImageView.frame))];
    octaveUpButton.tag = 1;
    [octaveUpButton addTarget:self action:@selector(arrowImageViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    octaveUpButton.adjustsImageWhenHighlighted = NO;
    [self.view addSubview:octaveUpButton];
    
    [self drawInstrumentMenu];
    [self drawTablatureScrollView];
    [self drawTablatureMenu];
}

-(void) drawTablatureMenu
{
    NSArray* fileNameLabelArray = [[NSArray alloc] initWithObjects:@"Pixar's Up-Theme Song", @"Frozen\nLet it Go", @"Pachelbel\nCanon in D major", nil];
    
    self.tablatureMenuScrollView = [[UIScrollView alloc] init];
    self.tablatureMenuScrollView.frame = CGRectMake(7, CGRectGetHeight(self.view.frame)*0.33, self.view.frame.size.width-14, self.view.frame.size.height*0.53);
    [self.tablatureMenuScrollView.layer setBorderWidth:2];
    self.tablatureMenuScrollView.backgroundColor = [UIColor whiteColor];
    
    for(int i=0; i<[self.tablatureFileNameArray count]; i++)
    {
        UIButton* icon = [[UIButton alloc] init];
        [icon setImage:[UIImage imageNamed:@"tablatureIcon.png"] forState:UIControlStateNormal];
        icon.tag = i;
        icon.adjustsImageWhenHighlighted = NO;
        int x = i - (int)[self.tablatureFileNameArray count]/2;
        [icon setFrame:CGRectMake(CGRectGetWidth(self.tablatureMenuScrollView.frame)*(0.43+x*0.26), CGRectGetHeight(self.tablatureMenuScrollView.frame)*0.1, CGRectGetWidth(self.tablatureMenuScrollView.frame)*0.14, self.tablatureMenuScrollView.frame.size.height*0.6)];
        [icon addTarget:self action:@selector(changeTablatureButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.tablatureMenuScrollView addSubview:icon];
        
        UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(icon.frame), CGRectGetMaxY(icon.frame), CGRectGetWidth(icon.frame), CGRectGetHeight(self.tablatureMenuScrollView.frame)*0.2)];
        nameLabel.text = [fileNameLabelArray objectAtIndex:i];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.numberOfLines = 2;
        nameLabel.adjustsFontSizeToFitWidth = YES;
        [self.tablatureMenuScrollView addSubview:nameLabel];
        
    }
}

-(void) adjustMistBar
{
    CGFloat octaveWidth = self.view.frame.size.width/7;
    self.leftMistBar.frame = CGRectMake(0, CGRectGetMinY(self.leftMistBar.frame), octaveWidth*(self.lowerOctaveNo-1), CGRectGetHeight(self.leftMistBar.frame));
    self.rightMistBar.frame = CGRectMake(CGRectGetMaxX(self.leftMistBar.frame)+octaveWidth*2, CGRectGetMinY(self.rightMistBar.frame), octaveWidth*(6-self.lowerOctaveNo), CGRectGetHeight(self.rightMistBar.frame));
}

-(void) drawTablatureScrollView
{
    self.tablatureScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(CGRectGetWidth(self.view.frame)*0.12, self.navigationController.navigationBar.frame.size.height+5, CGRectGetWidth(self.view.frame)*0.78, self.screenHeight/2-10-self.keyboard_top_padding*0.2)];
    [self.tablatureScrollView.layer setBorderWidth:2];
    [self.view addSubview:self.tablatureScrollView];
 
    self.tablatureImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"up.jpg"]];
    [self.tablatureImageView sizeToFit];
    float scale = CGRectGetWidth(self.tablatureScrollView.frame)/self.tablatureImageView.frame.size.width;
    self.tablatureImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tablatureScrollView.frame), self.tablatureImageView.frame.size.height*scale);
    [self.tablatureScrollView addSubview:self.tablatureImageView];
    
    self.tablatureScrollView.contentSize = self.tablatureImageView.frame.size;
}

-(void) drawInstrumentMenu
{
    self.instrumentMenuScrollView = [[UIScrollView alloc] init];
    self.instrumentMenuScrollView.frame = CGRectMake(7, CGRectGetHeight(self.view.frame)*0.33, self.view.frame.size.width-14, self.view.frame.size.height*0.53);
    [self.instrumentMenuScrollView.layer setBorderWidth:2];
    self.instrumentMenuScrollView.backgroundColor = [UIColor whiteColor];
    
    for(int i=0; i<[self.instrumentNameMap count]; i++)
    {
        UIButton* instrumentButton = [[UIButton alloc] init];
        NSString* imageName = [NSString stringWithFormat:@"%@_outline.png", self.instrumentNameMap[i]];
        [instrumentButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        instrumentButton.tag = i;
        instrumentButton.adjustsImageWhenHighlighted = NO;
        int x = i - (int)[self.instrumentNameMap count]/2;
        [instrumentButton setFrame:CGRectMake(CGRectGetWidth(self.instrumentMenuScrollView.frame)*(0.41+x*0.28), CGRectGetHeight(self.instrumentMenuScrollView.frame)*0.2, CGRectGetWidth(self.instrumentMenuScrollView.frame)*0.18, self.instrumentMenuScrollView.frame.size.height*1.2)];
        [instrumentButton addTarget:self action:@selector(changeInstrumentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.instrumentMenuScrollView addSubview:instrumentButton];
    }
}

#pragma mark - Actions

-(void)mistViewTapped
{
    [self.mistView removeFromSuperview];
    if([self.tablatureMenuScrollView isDescendantOfView:self.view])
        [self.tablatureMenuScrollView removeFromSuperview];
    if([self.instrumentMenuScrollView isDescendantOfView:self.view])
        [self.instrumentMenuScrollView removeFromSuperview];
}

-(void) changeTablatureButtonClicked:(UIButton*) sender
{
    [self.tablatureImageView setImage: [UIImage imageNamed:self.tablatureFileNameArray[sender.tag]]];
    [self.tablatureImageView sizeToFit];
    float scale = CGRectGetWidth(self.tablatureScrollView.frame)/self.tablatureImageView.frame.size.width;
    self.tablatureImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tablatureScrollView.frame), self.tablatureImageView.frame.size.height*scale);
    
    self.tablatureScrollView.contentSize = self.tablatureImageView.frame.size;
   
    [self.mistView removeFromSuperview];
    [self.tablatureMenuScrollView removeFromSuperview];
}

-(void)changeInstrumentButtonClicked:(UIButton*) sender
{
    self.instrumentNo = (int)sender.tag;
    NSString* pictureName = [NSString stringWithFormat:@"%@_outline.png", self.instrumentNameMap[self.instrumentNo]];
    [self.instrumentImageView setImage:[UIImage imageNamed:pictureName]];
   // [self AVAudioPlayerInit];
    [self.instrumentMenuScrollView removeFromSuperview];
    [self.view addSubview:self.spinner];
    [NSThread detachNewThreadSelector:@selector(AVAudioPlayerInit) toTarget:self withObject:nil];
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

- (void) arrowImageViewClicked:(UIButton*) sender
{
        if(sender.tag == 0)
        {
            if(self.lowerOctaveNo > 1)
            {
                self.lowerOctaveNo--;
                [self adjustMistBar];
            }
        }
        else
        {
            if(self.lowerOctaveNo < 6)
            {
                self.lowerOctaveNo++;
                [self adjustMistBar];
            }
        }
}

- (void) keyTapped:(UILongPressGestureRecognizer*) recognizer
{
    UIImageView* imageView = (UIImageView*)recognizer.view;
    int keyNo = (int)imageView.tag;
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        imageView.highlighted = YES;

        int octaveNo;
        if( keyNo >= 100)
        {
            octaveNo = self.lowerOctaveNo + 1;
            keyNo /= 100;
        }
        else
            octaveNo = self.lowerOctaveNo;
        
        NSArray* playersArray = self.octavesArray[octaveNo-1];
        [[playersArray objectAtIndex:keyNo-1] play];
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        imageView.highlighted = NO;
        int i=0;
        while (i<10000000)
            i++;

        int octaveNo;
        if( keyNo >= 100)
        {
            octaveNo = self.lowerOctaveNo + 1;
            keyNo /= 100;
        }
        else
            octaveNo = self.lowerOctaveNo;
        
        NSArray* playersArray = self.octavesArray[octaveNo-1];
        
        [[playersArray objectAtIndex:keyNo-1] stop];
        ((AVAudioPlayer*)[playersArray objectAtIndex:keyNo-1]).currentTime = 0;
        [[playersArray objectAtIndex:keyNo-1] prepareToPlay];
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
