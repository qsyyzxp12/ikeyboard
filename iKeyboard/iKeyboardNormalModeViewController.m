//
//  iKeyboardNormalModeViewController.m
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "iKeyboardNormalModeViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#define KEYBOARD_IMAGE_GAP_BETWEEN_KEYS 6
#define KEYBOARD_IMAGE_RIGHT_PADDING 5
#define KEYBOARD_IMAGE_LEFT_PADDING 3
#define KEYBOARD_IMAGE_TOP_PADDING 53
#define KEYBOARD_IMAGE_BUTTON_PADDING 3

@interface iKeyboardNormalModeViewController ()

@end

@implementation iKeyboardNormalModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lower_octave_no = 3;
    self.noteNameMap = [[NSArray alloc] initWithObjects:@"c", @"d", @"e", @"f", @"g", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"a", @"b", nil];
    
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
 /*   self.wholeKeyboardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyboard.png"]];
    [self.wholeKeyboardImageView.layer setBorderWidth:1];
   // [self.wholeKeyboardImageView.layer setBorderWidth:BORDER_WIDTH_OF_KEYBOARD_IMAGE];
    self.wholeKeyboardImageView.frame = CGRectMake(0, CGRectGetMinY(self.view.frame)+CGRectGetHeight(self.view.frame)/5, self.view.frame.size.width, self.view.frame.size.height/6);
    [self.view addSubview:self.wholeKeyboardImageView];
    
    self.frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frame.png"]];
    // [self.wholeKeyboardImageView.layer setBorderWidth:BORDER_WIDTH_OF_KEYBOARD_IMAGE];
    [self.frameImageView sizeToFit];
    self.frameImageView.frame = CGRectMake(251, CGRectGetMinY(self.wholeKeyboardImageView.frame), self.frameImageView.frame.size.width+4, self.frameImageView.frame.size.height);
    [self.view addSubview:self.frameImageView];
   */
    
    self.instrumentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"piano_outline.png"]];
    self.instrumentImageView.frame = CGRectMake(CGRectGetWidth(self.view.frame)*0.05, CGRectGetHeight(self.view.frame)*0.16, CGRectGetWidth(self.view.frame)*0.135, self.view.frame.size.height*0.495);
    [self.view addSubview:self.instrumentImageView];
    
    UIImageView* blueToothIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueToothIcon.png"]];
    [blueToothIcon sizeToFit];
    blueToothIcon.frame = CGRectMake(CGRectGetWidth(self.view.frame)*0.8, CGRectGetHeight(self.view.frame)*0.1, CGRectGetWidth(blueToothIcon.frame)*0.6, CGRectGetHeight(blueToothIcon.frame)*0.6);
    [self.view addSubview:blueToothIcon];
    
    self.keyboardBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"part_of_keyboard.png"]];
 //   [self.keyboardBgImageView.layer setBorderWidth:BORDER_WIDTH_OF_KEYBOARD_IMAGE];
   // self.keyboardBgImageView.backgroundColor = [UIColor yellowColor];
    self.keyboardBgImageView.frame = CGRectMake(0, CGRectGetMidY(self.view.frame), self.view.frame.size.width, self.view.frame.size.height/2);
    [self.view addSubview:self.keyboardBgImageView];
    
    
    
    CGFloat oneKeyWidth = (self.keyboardBgImageView.frame.size.width - KEYBOARD_IMAGE_RIGHT_PADDING -KEYBOARD_IMAGE_GAP_BETWEEN_KEYS*13 - KEYBOARD_IMAGE_LEFT_PADDING)/14;
    
    CGFloat keyX = KEYBOARD_IMAGE_LEFT_PADDING;
    CGFloat keyY = CGRectGetMinY(self.keyboardBgImageView.frame)+KEYBOARD_IMAGE_TOP_PADDING;
    CGFloat keyHeight = self.keyboardBgImageView.frame.size.height - KEYBOARD_IMAGE_TOP_PADDING - KEYBOARD_IMAGE_BUTTON_PADDING;
    
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
        
        [self.view addSubview:whiteKeyImageView];
        [self.whiteKeyImageViewArray addObject:whiteKeyImageView];
        
        UILabel* noLabel = [[UILabel alloc] initWithFrame:CGRectMake(keyX, CGRectGetMaxY(whiteKeyImageView.frame)-keyHeight*0.2, oneKeyWidth, keyHeight*0.2)];
        
        noLabel.textAlignment = NSTextAlignmentCenter;
        noLabel.text = [NSString stringWithFormat:@"%d", i%7+1];
        [self.view addSubview:noLabel];
        
        keyX += KEYBOARD_IMAGE_GAP_BETWEEN_KEYS + oneKeyWidth;
        
    }
/*
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
    [self.view addSubview:rArrowButton];*/
}

#pragma mark - Actions

- (void) arrowButtoClicked:(UIButton*) sender
{
    if(sender.tag == 0)
    {
        NSLog(@"left arrow clicked");
        if(self.lower_octave_no > 1)
        {
     //       [self.frameImageView setFrame:CGRectMake(self.frameImageView.frame.origin.x - self.frameImageView.frame.size.width, self.frameImageView.frame.origin.y, self.frameImageView.frame.size.width, self.frameImageView.frame.size.height)];
            self.lower_octave_no -= 2;
        }
    }
    else
    {
        NSLog(@"right arrow clicked");
        if(self.lower_octave_no < 7)
        {
       //     [self.frameImageView setFrame:CGRectMake(self.frameImageView.frame.origin.x + self.frameImageView.frame.size.width, self.frameImageView.frame.origin.y, self.frameImageView.frame.size.width, self.frameImageView.frame.size.height)];
            self.lower_octave_no += 2;
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
        if( keyNo > 6)
            octaveNo = self.lower_octave_no + 1;
        else
            octaveNo = self.lower_octave_no;
        
        NSDictionary* octaveDic = [self.octavesArray objectAtIndex:octaveNo];
        NSString* key = self.noteNameMap[keyNo];
        [[octaveDic objectForKey:key] play];
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        imageView.highlighted = NO;
        
        int octaveNo;
        if( keyNo > 6)
            octaveNo = self.lower_octave_no + 1;
        else
            octaveNo = self.lower_octave_no;
        
        NSDictionary* octaveDic = [self.octavesArray objectAtIndex:octaveNo];
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
