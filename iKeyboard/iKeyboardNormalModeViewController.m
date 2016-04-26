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
        
        if(i < 7)
            whiteKeyImageView.tag = i+1;
        else
            whiteKeyImageView.tag = (i%7+1)*100;
        
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
    
    UIImageView* keyboardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyboard.png"]];
    keyboardImageView.frame = CGRectMake(0, CGRectGetMinY(keyboardBgImageView.frame), CGRectGetWidth(self.view.frame), self.keyboard_top_padding*0.8);
    [keyboardImageView.layer setBorderWidth:1];
    [self.view addSubview:keyboardImageView];
    
    UIImageView* grayBarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray.png"]];
    grayBarImageView.frame = CGRectMake(0, CGRectGetMaxY(keyboardImageView.frame), CGRectGetWidth(self.view.frame), self.keyboard_top_padding*0.2);
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
    NSArray* fileNameArray = [[NSArray alloc] initWithObjects:@"up.jpg", @"letItGo.jpg", @"canonInDMajor.jpg", nil];
    
    NSArray* fileNameLabelArray = [[NSArray alloc] initWithObjects:@"Pixar's Up-Theme Song", @"Frozen\nLet it Go", @"Pachelbel\nCanon in D major", nil];
    
    self.tablatureMenuScrollView = [[UIScrollView alloc] init];
    self.tablatureMenuScrollView.frame = CGRectMake(7, CGRectGetHeight(self.view.frame)*0.33, self.view.frame.size.width-14, self.view.frame.size.height*0.53);
    [self.tablatureMenuScrollView.layer setBorderWidth:2];
    self.tablatureMenuScrollView.backgroundColor = [UIColor whiteColor];
    
    for(int i=0; i<[fileNameArray count]; i++)
    {
        UIButton* icon = [[UIButton alloc] init];
        [icon setImage:[UIImage imageNamed:@"tablatureIcon.png"] forState:UIControlStateNormal];
        icon.tag = 1;
        icon.adjustsImageWhenHighlighted = NO;
        int x = i - (int)[fileNameArray count]/2;
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
 
    UIImageView* tablature = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"up.jpg"]];
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
    if([self.tablatureMenuScrollView isDescendantOfView:self.view])
        [self.tablatureMenuScrollView removeFromSuperview];
    if([self.instrumentMenuScrollView isDescendantOfView:self.view])
        [self.instrumentMenuScrollView removeFromSuperview];
}

-(void) changeTablatureButtonClicked:(UIButton*) sender
{
    [self.view addSubview:self.tablatureMenuScrollView];
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
/*    if(sender.state == UIGestureRecognizerStateBegan)
    {
        [self.view addSubview:self.mistView];
        [self.view addSubview:self.wholeKeyboardImageView];
        UIImageView* imageView = (UIImageView*)sender.view;
        if(imageView.tag == 0)
  */
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
 /*   }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
        int i=0;
        while(i < 1000000)
            i++;
        [self.mistView removeFromSuperview];
        [self.wholeKeyboardImageView removeFromSuperview];
    }*/
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
