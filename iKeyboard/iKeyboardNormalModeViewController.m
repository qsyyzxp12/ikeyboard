//
//  iKeyboardNormalModeViewController.m
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "iKeyboardNormalModeViewController.h"

#define BORDER_WIDTH_OF_KEYBOARD_IMAGE 2

@interface iKeyboardNormalModeViewController ()

@end

@implementation iKeyboardNormalModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self UIbuild];
    // Do any additional setup after loading the view.
}

#pragma mark - User Interface

-(void) UIbuild
{
    self.wholeKeyboardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyboard.png"]];
   // [self.wholeKeyboardImageView.layer setBorderWidth:BORDER_WIDTH_OF_KEYBOARD_IMAGE];
    self.wholeKeyboardImageView.frame = CGRectMake(0, CGRectGetMinY(self.view.frame)+CGRectGetHeight(self.view.frame)/5, self.view.frame.size.width, self.view.frame.size.height/6);
    [self.view addSubview:self.wholeKeyboardImageView];
    
    self.frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frame.png"]];
    // [self.wholeKeyboardImageView.layer setBorderWidth:BORDER_WIDTH_OF_KEYBOARD_IMAGE];
    [self.frameImageView sizeToFit];
    self.frameImageView.frame = CGRectMake(252, CGRectGetMinY(self.wholeKeyboardImageView.frame), self.frameImageView.frame.size.width+3, self.frameImageView.frame.size.height);
    [self.view addSubview:self.frameImageView];
    
    //55
    NSLog(@"%f, %f", self.wholeKeyboardImageView.frame.size.width, self.wholeKeyboardImageView.frame.size.height);
    
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
        UIImageView* whiteKeyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
//        whiteKeyImageView.backgroundColor = [UIColor redColor];
        whiteKeyImageView.frame = CGRectMake(keyX, keyY, oneKeyWidth, keyHeight);
        whiteKeyImageView.tag = i;
        [whiteKeyImageView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(keyTapped:)];
        [tapGestureRecognizer setNumberOfTapsRequired:1];
        [tapGestureRecognizer setNumberOfTouchesRequired:1];
        [whiteKeyImageView addGestureRecognizer:tapGestureRecognizer];
        
        [self.view addSubview:whiteKeyImageView];
        [self.whiteKeyImageViewArray addObject:whiteKeyImageView];
        keyX += BORDER_WIDTH_OF_KEYBOARD_IMAGE + oneKeyWidth;
    }
}

#pragma mark - Actions

- (void) keyTapped:(UIPanGestureRecognizer*) recognizer
{
    int keyNo = (int)recognizer.view.tag;
    NSLog(@"tap key %d", keyNo);
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
