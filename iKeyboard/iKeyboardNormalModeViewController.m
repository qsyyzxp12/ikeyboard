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
    
    [self AVAudioPlayerInit];
    [self UIbuild];
    
  //  AudioServicesPlaySystemSound(playSoundID);
    // Do any additional setup after loading the view.
}

-(void) AVAudioPlayerInit
{
    NSMutableArray* octavesArray = [[NSMutableArray alloc] initWithCapacity:9];
    NSString *path;
    AVAudioPlayer* player;
    for(int i=0; i<9; i++)
    {
        NSMutableDictionary* octaveDic = [[NSMutableDictionary alloc] init];
        octavesArray[i] = octaveDic;
        if(i == 0)
        {
            path = [[NSBundle mainBundle] pathForResource:@"piano_a0" ofType:@"wav"];
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                                     [NSURL fileURLWithPath:path] error:NULL];
            [player prepareToPlay];
            [octaveDic setObject:player forKey:@"a"];
            
            path = [[NSBundle mainBundle] pathForResource:@"piano_b0" ofType:@"wav"];
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                                     [NSURL fileURLWithPath:path] error:NULL];
            [player prepareToPlay];
            [octaveDic setObject:player forKey:@"b"];
            continue;
        }
        else if(i == 8)
        {
            path = [[NSBundle mainBundle] pathForResource:@"piano_c8" ofType:@"wav"];
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                      [NSURL fileURLWithPath:path] error:NULL];
            [player prepareToPlay];
            [octaveDic setObject:player forKey:@"b"];
            continue;
        }
        for(int j=(int)'a'; j<(int)'h'; j++)
        {
            NSString* fileName = [NSString stringWithFormat:@"piano_%c%d", (char)j, i];
            path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                      [NSURL fileURLWithPath:path] error:NULL];
            [player prepareToPlay];
            NSString* key = [NSString stringWithFormat:@"%c", (char)j];
            [octaveDic setObject:player forKey:key];
        }
    }
    
    self.octavesArray = octavesArray;
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
        
        if(i >= 0 && i < 5)
            whiteKeyImageView.tag = 99 + i;
        else
            whiteKeyImageView.tag = 92 + i;
        
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
        int keyNo = (int)imageView.tag;
        NSLog(@"tap key %c", (char)keyNo);
        imageView.highlighted = YES;
        NSDictionary* octaveDic = [self.octavesArray objectAtIndex:self.octaveNo];
        NSString* key = [NSString stringWithFormat:@"%c", (char)keyNo];
        self.playingPlayer = [octaveDic objectForKey:key];
        [self.playingPlayer play];
        
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"end");
        imageView.highlighted = NO;
        [self.playingPlayer stop];
        self.playingPlayer.currentTime = 0;
        [self.playingPlayer prepareToPlay];
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
