//
//  iKeyboardNormalModeViewController.h
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface iKeyboardNormalModeViewController : UIViewController


@property UIImageView *wholeKeyboardImageView;
@property UIImageView *frameImageView;
@property UIImageView *keyboardBgImageView;
@property NSMutableArray* whiteKeyImageViewArray;
@property int octaveNo;
@property AVAudioPlayer* soundPlayer;

@end
