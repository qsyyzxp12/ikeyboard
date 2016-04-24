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
    
    self.lower_octave_no = 3;
    self.instrumentNo = 1;
    self.noteNameMap = [[NSArray alloc] initWithObjects:@"C", @"D", @"E", @"F", @"G", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"A", @"B", @"C#", @"D#", @"F#", @"G#", @"A#", @"C#", @"D#", @"F#", @"G#", @"A#", nil];
    self.instrumentNameMap = [[NSArray alloc] initWithObjects:@"guitar", @"piano", @"string", nil];
    
    self.screenHeight = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height;
    
    [self AVAudioPlayerInit];
    [self UIbuild];
}

-(void) AVAudioPlayerInit
{
    self.instrumentOctavesArray = [[NSMutableArray alloc] init];
    
    NSArray* halfStepArray = [[NSArray alloc] initWithObjects:@"A", @"C", @"D", @"F", @"G", nil];
    
    for(NSString* instrumentName in self.instrumentNameMap)
    {
        if(instrumentName)
        {
            NSLog(@"instrument name = %@", instrumentName);
            NSMutableArray* octavesArray = [[NSMutableArray alloc] initWithCapacity:7];
            NSString *path;
            AVAudioPlayer* player;
            for(int i=0; i<7; i++)
            {
                NSMutableDictionary* octaveDic = [[NSMutableDictionary alloc] init];
                octavesArray[i] = octaveDic;
                NSLog(@"\tOctave %d", i+1);
                for(int j=(int)'A'; j<(int)'H'; j++)
                {
                    NSLog(@"\t\twhite key %c", (char)j);
                    NSString* fileName = [NSString stringWithFormat:@"%@_%c%d", instrumentName, (char)j, i+1];
                    path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
                    player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                              [NSURL fileURLWithPath:path] error:NULL];
                    [player prepareToPlay];
                    NSString* key = [NSString stringWithFormat:@"%c", (char)j];
                    if(!player)
                        NSLog(@"xx");
                    [octaveDic setObject:player forKey:key];
                }
                for(NSString* halfStep in halfStepArray)
                {
                    NSLog(@"\t\tblack key %@", halfStep);
                    NSString* fileName = [NSString stringWithFormat:@"%@_%@%d#", instrumentName, halfStep, i+1];
                    path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
                    player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                              [NSURL fileURLWithPath:path] error:NULL];
                    [player prepareToPlay];
                    NSString* key = [NSString stringWithFormat:@"%@#", halfStep];
                    [octaveDic setObject:player forKey:key];
                }
            }
            
            [self.instrumentOctavesArray addObject:octavesArray];
        }
    }
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
    self.instrumentButton = [[UIButton alloc] init];
    [self.instrumentButton setImage:[UIImage imageNamed:@"piano_outline.png"] forState:UIControlStateNormal];
    self.instrumentButton.adjustsImageWhenHighlighted = NO;
    [self.instrumentButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.05, self.navigationController.navigationBar.frame.size.height+self.screenHeight*0.1, CGRectGetWidth(self.view.frame)*0.135, self.screenHeight*0.56)];
    [self.instrumentButton addTarget:self action:@selector(instrumentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.instrumentButton];
    
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
    self.whiteKeyImageViewArray = [[NSMutableArray alloc] init];
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
        [self.whiteKeyImageViewArray addObject:whiteKeyImageView];
        
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
    [instrumentButton setImage:[UIImage imageNamed:@"violin_outline.png"] forState:UIControlStateNormal];
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
    NSString* pictureName = [NSString stringWithFormat:@"%@_outline.png", self.instrumentNameMap[sender.tag]];
    [self.instrumentButton setImage:[UIImage imageNamed:pictureName] forState:UIControlStateNormal];
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
        UIImageView* imageView = (UIImageView*)sender.view;
        if(imageView.tag == 0)
        {
            if(self.lower_octave_no > 1)
                self.lower_octave_no--;
        }
        else
        {
            if(self.lower_octave_no < 6)
                self.lower_octave_no++;
        }
        [self.view addSubview:self.mistView];
        [self.view addSubview:self.wholeKeyboardImageView];
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
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

        int octaveNo;
        if( (keyNo > 6 && keyNo < 14) || keyNo > 18)
            octaveNo = self.lower_octave_no + 1;
        else
            octaveNo = self.lower_octave_no;
        
        NSArray* octavesArray = [self.instrumentOctavesArray objectAtIndex:self.instrumentNo];
        NSDictionary* octaveDic = [octavesArray objectAtIndex:octaveNo-1];
        NSString* key = self.noteNameMap[keyNo];
        [[octaveDic objectForKey:key] play];
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        imageView.highlighted = NO;
        int i=0;
        while (i<10000000)
            i++;

        int octaveNo;
        if( (keyNo > 6 && keyNo < 14) || keyNo > 18)
            octaveNo = self.lower_octave_no + 1;
        else
            octaveNo = self.lower_octave_no;
        
        NSArray* octavesArray = [self.instrumentOctavesArray objectAtIndex:self.instrumentNo];
        NSDictionary* octaveDic = [octavesArray objectAtIndex:octaveNo-1];
        NSString* key = self.noteNameMap[keyNo];
        
        [[octaveDic objectForKey:key] stop];
        ((AVAudioPlayer*)[octaveDic objectForKey:key]).currentTime = 0;
        [[octaveDic objectForKey:key] prepareToPlay];
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
