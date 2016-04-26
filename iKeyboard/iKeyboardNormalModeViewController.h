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
@property NSArray* keyImageViewArray;

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
@property int keyboard_padding; //include left, right, button padding and the gap size between wkeys.
@property CGSize blackKeySize;
@property CGVector blackKeyOffsetVector;

@property UIActivityIndicatorView* spinner;
@property CGRect keyBeingTappedFrame;
@property int keyBeingTappedIndex;
@end
