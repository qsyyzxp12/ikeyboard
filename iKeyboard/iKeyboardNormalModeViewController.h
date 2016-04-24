//
//  iKeyboardNormalModeViewController.h
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface iKeyboardNormalModeViewController : UIViewController

@property UIImageView *wholeKeyboardImageView;
@property UIImageView *frameImageView;
@property UIButton* instrumentButton;
@property UILabel* blueToothStatusLabel;
@property UIScrollView* instrumentMenuScrollView;
@property UIScrollView* tablatureScrollView;
@property UIView* mistView;

@property NSMutableArray* whiteKeyImageViewArray;
@property NSMutableArray* instrumentOctavesArray;

@property int instrumentNo;
@property int lower_octave_no;

@property NSArray* noteNameMap;
@property NSArray* instrumentNameMap;

@property CGFloat screenHeight;
@property int keyboard_top_padding;
@property int keyboard_left_padding;
@property int keyboard_right_padding;
@property int keyboard_button_padding;
@property int keyboard_gap_between_keys;
@property CGSize blackKeySize;
@end
