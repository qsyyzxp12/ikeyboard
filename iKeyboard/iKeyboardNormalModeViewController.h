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

//@property UIImageView *wholeKeyboardImageView;
//@property UIImageView *frameImageView;
@property UIImageView *instrumentImageView;
@property UIImageView *keyboardBgImageView;
@property NSMutableArray* whiteKeyImageViewArray;
@property int lower_octave_no;
@property int graphSampleRate;
@property NSArray* octavesArray;
@property NSArray* noteNameMap;
@end
