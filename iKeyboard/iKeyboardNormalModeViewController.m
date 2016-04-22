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
    self.noteNameMap = [[NSArray alloc] initWithObjects:@"c", @"d", @"e", @"f", @"g", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"a", @"b", nil];
    self.instrumentNameMap = [[NSArray alloc] initWithObjects:@"guitar_outline.png", @"piano_outline.png", @"violin_outline.png", nil];
    
    self.screenHeight = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height;
    
    NSLog(@"%f",[[UIScreen mainScreen] bounds].size.width);
    
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
    
    self.blueToothStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(blueToothIcon.frame), CGRectGetMinY(blueToothIcon.frame), 100, CGRectGetHeight(blueToothIcon.frame))];
    self.blueToothStatusLabel.text = @"Unconnected";
    //self.blueToothStatusLabel.backgroundColor = [UIColor redColor];
    [self.blueToothStatusLabel setFont:[UIFont systemFontOfSize:15]];
    self.blueToothStatusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.blueToothStatusLabel];
    
    self.mistView = [[UIView alloc] initWithFrame:self.view.frame];
    self.mistView.alpha = 0.5;
    self.mistView.backgroundColor = [UIColor grayColor];
    UITapGestureRecognizer* tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mistViewTapped)];
    tapGest.numberOfTapsRequired = 1;
    tapGest.numberOfTouchesRequired = 1;
    [self.mistView addGestureRecognizer:tapGest];
    
    UIImageView* keyboardBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"part_of_keyboard.png"]];
    keyboardBgImageView.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame)-self.screenHeight/2, self.view.frame.size.width, self.screenHeight/2);
    [self.view addSubview:keyboardBgImageView];
    
    CGFloat oneKeyWidth = (keyboardBgImageView.frame.size.width - self.keyboard_right_padding -self.keyboard_gap_between_keys*13 - self.keyboard_left_padding)/14;
    
    CGFloat keyX = self.keyboard_left_padding;
    CGFloat keyY = CGRectGetMinY(keyboardBgImageView.frame)+self.keyboard_top_padding;
    CGFloat keyHeight = keyboardBgImageView.frame.size.height - self.keyboard_top_padding - self.keyboard_button_padding;
    
    NSLog(@"%f", keyHeight);
    NSLog(@"%f", keyHeight/keyboardBgImageView.frame.size.height);
    
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
        whiteKeyImageView.backgroundColor = [UIColor redColor];
        [self.view addSubview:whiteKeyImageView];
        [self.whiteKeyImageViewArray addObject:whiteKeyImageView];
        
        UILabel* noLabel = [[UILabel alloc] initWithFrame:CGRectMake(keyX, CGRectGetMaxY(whiteKeyImageView.frame)-keyHeight*0.2, oneKeyWidth, keyHeight*0.2)];
        
        noLabel.textAlignment = NSTextAlignmentCenter;
        noLabel.text = [NSString stringWithFormat:@"%d", i%7+1];
        [self.view addSubview:noLabel];
        
        keyX += self.keyboard_gap_between_keys + oneKeyWidth;
        
    }

    UIButton* lArrowButton = [[UIButton alloc] init];
    lArrowButton.tag = 0;
    [lArrowButton setImage:[UIImage imageNamed:@"leftArrow.png"] forState:UIControlStateNormal];
    [lArrowButton setFrame:CGRectMake(20, CGRectGetMinY(keyboardBgImageView.frame)+15, 50, 20)];
    [lArrowButton addTarget:self action:@selector(arrowButtoClicked:) forControlEvents:UIControlEventTouchUpInside];
 //   [self.switchModeButton setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:lArrowButton];
    
    UIButton* rArrowButton = [[UIButton alloc] init];
    rArrowButton.tag = 1;
    [rArrowButton setImage:[UIImage imageNamed:@"rightArrow.png"] forState:UIControlStateNormal];
    [rArrowButton setFrame:CGRectMake(CGRectGetMaxX(self.view.frame)-70, CGRectGetMinY(keyboardBgImageView.frame)+15, 50, 20)];
    [rArrowButton addTarget:self action:@selector(arrowButtoClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rArrowButton];
    
    [self drawInstrumentMenu];
    [self drawTablatureScrollView];
}

-(void) drawTablatureScrollView
{
    NSLog(@"%f", self.navigationController.navigationBar.frame.size.height);
    
    self.tablatureScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(CGRectGetWidth(self.view.frame)*0.23, self.navigationController.navigationBar.frame.size.height+5, CGRectGetWidth(self.view.frame)*0.55, self.screenHeight/2-10)];
    [self.tablatureScrollView.layer setBorderWidth:2];
    [self.view addSubview:self.tablatureScrollView];
   
    UIImageView* tablature = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablature.png"]];
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
    [self.instrumentButton setImage:[UIImage imageNamed:self.instrumentNameMap[sender.tag]] forState:UIControlStateNormal];
    [self.mistView removeFromSuperview];
    [self.instrumentMenuScrollView removeFromSuperview];
}

-(void)instrumentButtonClicked
{
    [self.view addSubview:self.mistView];
    [self.view addSubview:self.instrumentMenuScrollView];
}

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
