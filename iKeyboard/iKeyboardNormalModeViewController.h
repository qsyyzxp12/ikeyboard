//
//  iKeyboardNormalModeViewController.h
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "AppDelegate.h"

@interface iKeyboardNormalModeViewController : UIViewController<UIGestureRecognizerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CBPeripheralDelegate>

//UI
@property UIView* settingPageView;
@property UIView* plusPageView;
@property UIView* photoPickView;
@property UIImageView* wholeKeyboardImageView;
@property UIImageView* frameImageView;
@property UIImageView* littleKeyboImageView;
@property UIImageView* instrumentImageView;
@property UIImageView* tablatureImageView;
@property UIScrollView* instrumentMenuScrollView;
@property UIScrollView* tablatureMenuScrollView;
@property UIScrollView* tablatureScrollView;
@property UIView* mistView;
@property UIView* leftMistBar;
@property UIView* rightMistBar;

@property NSMutableArray* whiteKeyImageViewArray;
@property NSMutableArray* octavesArray;
@property NSArray* keyViewArray;
@property NSMutableArray* resetArray;
@property NSArray* highlightedKeyImageViewArray;
@property NSMutableArray* sheetButtonArray;
@property NSArray* photoButtonArray;

//No.
@property int instrumentNo;
@property int lowerOctaveNo;
@property int sheetNo;

//Name map
@property NSArray* instrumentNameMap;
@property NSMutableArray* sheetNameMap;
@property NSArray* noteNameArray;
@property NSArray* halfStepArray;

//Screen Size control
@property int keyboardHeight;
@property int keyboard_left_padding;
@property int keyboard_right_padding;
@property int keyboard_padding; //include left, right, button padding and the gap size between wkeys.
@property CGSize blackKeySize;
@property CGVector blackKeyOffsetVector;

@property UIActivityIndicatorView* spinner;
@property NSMutableArray* keyBeingTappedFrameArray;
@property int* keyBeingTappedIndexArray;
@property UILongPressGestureRecognizer *tapGestureRecognizer;
@property UILongPressGestureRecognizer *tapGestureRecognizer2;
@property UILongPressGestureRecognizer *tapGestureRecognizer3;
@property BOOL showingSettingPage;
@property BOOL showingPlusPage;
@property int instrumentSelectedNo;
@property int sheetSelectedNo;
@property int* keyPressingArray;

@property UIImagePickerController* imagePicker;
@property NSMutableArray* photoArray;

//Bluttooth
@property AppDelegate* appDelegate;
@property int audioPlayerReady;
@end
