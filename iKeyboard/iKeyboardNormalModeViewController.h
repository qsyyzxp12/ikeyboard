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

//UI
@property UIImageView *wholeKeyboardImageView;
@property UIImageView *frameImageView;
@property UIImageView* instrumentImageView;
@property UIImageView* tablatureImageView;
@property UILabel* blueToothStatusLabel;
@property UIScrollView* instrumentMenuScrollView;
@property UIScrollView* tablatureMenuScrollView;
@property UIScrollView* tablatureScrollView;
@property UIView* mistView;
@property UIView* leftMistBar;
@property UIView* rightMistBar;

@property NSMutableArray* whiteKeyImageViewArray;
@property NSMutableArray* octavesArray;

//No.
@property int instrumentNo;
@property int lowerOctaveNo;

//Name map
@property NSArray* instrumentNameMap;
@property NSArray* noteNameArray;
@property NSArray* halfStepArray;
@property NSArray* tablatureFileNameArray;

//Screen Size control
@property CGFloat screenHeight;
@property int keyboard_top_padding;
@property int keyboard_left_padding;
@property int keyboard_right_padding;
@property int keyboard_button_padding;
@property int keyboard_gap_between_keys;
@property CGSize blackKeySize;

@property UIActivityIndicatorView* spinner;
@end
