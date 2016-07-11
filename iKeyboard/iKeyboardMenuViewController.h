//
//  iKeyboardMenuViewController.h
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "AppDelegate.h"
#import "iKeyboardNormalModeViewController.h"

@interface iKeyboardMenuViewController : UIViewController<CBCentralManagerDelegate,keyboDelegate>
-(void) keyboViewDismissed:(NSInteger *)pageIDforFirst;

@property CBCentralManager* cbManager;
@property AppDelegate* appDelegate;
@property iKeyboardNormalModeViewController* normalModeViewController;
@property NSInteger* pageID;
@property UIActivityIndicatorView *spinner;
@property UIView *mistView;
-(void) bluetoothReady;
-(void) bluetoothConnect;
@end
